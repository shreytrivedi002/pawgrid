import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puzzle_core/puzzle_core.dart';
import '../data/catalog.dart';
import '../feedback/audio_gateway.dart';
import '../data/database.dart';

class AppServices {
  const AppServices(
    this.catalog,
    this.repository,
    this.initialSettings,
    this.initialProgress,
    this.initialBalance, {
    this.audio = const SilentGameAudio(),
  });
  final GameAudioGateway audio;
  final ContentCatalog catalog;
  final GameRepository repository;
  final Map<String, dynamic> initialSettings;
  final Map<String, LevelProgressData> initialProgress;
  final int initialBalance;
}

final servicesProvider = Provider<AppServices>(
  (ref) => throw StateError('Not initialized'),
);
final appProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class PlacementFeedback {
  const PlacementFeedback(this.sequence, this.cell, this.issue);
  final int sequence, cell;
  final PlacementIssue issue;
}

class AppState {
  AppState({
    required Map<String, dynamic> settings,
    required Map<String, LevelProgressData> progress,
    this.balance = 0,
    this.lastReward = 0,
    this.selectedCell = 0,
    this.gameEpoch = 0,
    this.placementFeedback,
    this.game,
    this.busy = false,
    this.paused = true,
    this.error,
  }) : settings = Map.unmodifiable(settings),
       progress = Map.unmodifiable(progress);
  final Map<String, dynamic> settings;
  final Map<String, LevelProgressData> progress;
  final int balance, lastReward, selectedCell, gameEpoch;
  final PlacementFeedback? placementFeedback;
  final SavedGame? game;
  final bool busy, paused;
  final String? error;
  bool enabled(String key, {bool fallback = false}) =>
      settings[key] as bool? ?? fallback;
  InputMode get inputMode =>
      settings['inputMode'] == 'place' ? InputMode.place : InputMode.mark;
  String get equipped => settings['equipped'] as String? ?? 'moss';
  AppState copyWith({
    Map<String, dynamic>? settings,
    Map<String, LevelProgressData>? progress,
    int? balance,
    int? lastReward,
    int? selectedCell,
    int? gameEpoch,
    PlacementFeedback? placementFeedback,
    bool clearFeedback = false,
    SavedGame? game,
    bool? busy,
    bool? paused,
    String? error,
    bool clearGame = false,
  }) => AppState(
    settings: settings ?? this.settings,
    progress: progress ?? this.progress,
    balance: balance ?? this.balance,
    lastReward: lastReward ?? this.lastReward,
    selectedCell: selectedCell ?? this.selectedCell,
    gameEpoch: gameEpoch ?? this.gameEpoch,
    placementFeedback: clearFeedback
        ? null
        : placementFeedback ?? this.placementFeedback,
    game: clearGame ? null : game ?? this.game,
    busy: busy ?? this.busy,
    paused: paused ?? this.paused,
    error: error,
  );
}

class AppController extends Notifier<AppState> {
  final Stopwatch _clock = Stopwatch();
  int _baseMs = 0;
  int _gameGeneration = 0;
  int _feedbackSequence = 0;
  Future<void>? _saveInFlight;
  Future<void> _inputTail = Future<void>.value();
  AppServices get services => ref.read(servicesProvider);
  ContentCatalog get catalog => services.catalog;
  @override
  AppState build() {
    ref.onDispose(_clock.stop);
    return AppState(
      settings: services.initialSettings,
      progress: services.initialProgress,
      balance: services.initialBalance,
    );
  }

  int get nextJourneyIndex {
    for (var i = 0; i < catalog.journey.length; i++) {
      if (!state.progress.containsKey(catalog.journey[i])) return i;
    }
    return catalog.journey.length - 1;
  }

  int get elapsedMs => _baseMs + _clock.elapsedMilliseconds;
  PuzzleDefinition? get puzzle =>
      state.game == null ? null : catalog.levels[state.game!.levelId];

  Future<bool> open(String id, String mode, {bool restart = false}) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    _gameGeneration++;
    try {
      final p = catalog.levels[id]!;
      final saved = restart ? null : await services.repository.load(p, mode);
      final game = saved ?? SavedGame(id, mode, PuzzleSession.start(p));
      await services.repository.save(p, mode, game.session, reset: restart);
      _baseMs = game.session.activeMs;
      _clock
        ..stop()
        ..reset();
      if (!Rules.isWon(p, game.session.marks)) _clock.start();
      state = state.copyWith(
        game: game,
        busy: false,
        paused: false,
        lastReward: 0,
        selectedCell: 0,
        gameEpoch: _gameGeneration,
        clearFeedback: true,
        settings: {
          ...state.settings,
          'lastGame': {'levelId': id, 'mode': mode},
        },
        error: saved?.recovered == true
            ? 'Recovered your previous verified save.'
            : null,
      );
      return true;
    } on Object {
      state = state.copyWith(
        busy: false,
        error:
            'Your saved garden could not be opened safely. Try again; your data has been kept.',
      );
      return false;
    }
  }

  Future<void> _commit(PuzzleSession next) {
    if (state.busy || state.game == null) return Future<void>.value();
    final saving = _persist(next);
    _saveInFlight = saving;
    return saving.whenComplete(() {
      if (identical(_saveInFlight, saving)) _saveInFlight = null;
    });
  }

  Future<void> _persist(PuzzleSession next) async {
    if (state.busy || state.game == null) return;
    state = state.copyWith(busy: true);
    final game = state.game!, p = puzzle!;
    final captured = next.withTime(elapsedMs);
    try {
      final won = Rules.isWon(p, captured.marks);
      if (won) _clock.stop();
      final granted = await services.repository.save(
        p,
        game.mode,
        captured,
        completedUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final progress = won
          ? await services.repository.progress()
          : state.progress;
      final balance = won ? await services.repository.balance() : state.balance;
      state = state.copyWith(
        game: SavedGame(game.levelId, game.mode, captured),
        busy: false,
        progress: progress,
        balance: balance,
        lastReward: granted,
      );
    } on Object {
      if (!state.paused && !Rules.isWon(p, game.session.marks)) _clock.start();
      state = state.copyWith(
        busy: false,
        error:
            'This move could not be saved. Free some storage and try again. Your last saved board is safe.',
      );
    }
  }

  Future<void> _queueInput(
    PuzzleSession Function(PuzzleDefinition, PuzzleSession) command,
  ) {
    if (state.paused || state.game == null || puzzle == null) {
      return Future<void>.value();
    }
    final generation = _gameGeneration;
    final levelId = state.game!.levelId, hash = puzzle!.contentHash;
    final queued = _inputTail.then((_) async {
      await _saveInFlight;
      if (generation != _gameGeneration ||
          state.game?.levelId != levelId ||
          puzzle?.contentHash != hash) {
        return;
      }
      final current = state.game!.session;
      final next = command(puzzle!, current);
      if (!identical(next, current)) {
        state = state.copyWith(clearFeedback: true);
        await _commit(next);
      }
    });
    _inputTail = queued;
    return queued;
  }

  void selectCell(int cell) {
    if (puzzle == null ||
        cell < 0 ||
        cell >= puzzle!.n * puzzle!.n ||
        state.selectedCell == cell) {
      return;
    }
    state = state.copyWith(selectedCell: cell);
  }

  PuzzleSession _placement(PuzzleDefinition p, PuzzleSession s, int cell) {
    final issue = const PlacementPolicy().check(p, s.marks, cell);
    if (issue != null) {
      state = state.copyWith(
        placementFeedback: PlacementFeedback(++_feedbackSequence, cell, issue),
      );
      return s;
    }
    return s.placeCreature(p, cell);
  }

  Future<void> tap(int cell, {bool quick = false}) => _queueInput(
    (p, s) => quick ? _placement(p, s, cell) : s.tap(p, cell, InputMode.mark),
  );
  Future<void> placeCreature(int cell) =>
      _queueInput((p, s) => _placement(p, s, cell));
  Future<void> clearCell(int cell) =>
      _queueInput((p, s) => s.change(p, cell, CellMark.unknown));
  Future<void> paintCrosses(Iterable<int> cells, CellMark mark) {
    final stroke = List<int>.unmodifiable(cells);
    return _queueInput((p, s) => s.paintCrosses(p, stroke, mark));
  }

  Future<void> undo() => _queueInput((p, s) => s.undo(p));

  Future<void> tick() async {
    if (!state.paused &&
        !state.busy &&
        _clock.isRunning &&
        state.game != null) {
      await _commit(state.game!.session);
    }
  }

  Future<void> pause(bool paused) async {
    if (paused) {
      _clock.stop();
      state = state.copyWith(paused: true);
      if (!state.busy && state.game != null) await _commit(state.game!.session);
    } else {
      if (puzzle != null && !Rules.isWon(puzzle!, state.game!.session.marks)) {
        _clock.start();
      }
      state = state.copyWith(paused: false);
    }
  }

  Future<void> applyHint(Deduction d) async {
    if (state.busy || puzzle == null) return;
    final current = const HumanDeductionEngine().next(
      puzzle!,
      state.game!.session.marks,
    );
    if (current == null || current.cell != d.cell || current.mark != d.mark) {
      return;
    }
    await _commit(
      state.game!.session.change(puzzle!, d.cell, d.mark, hint: true),
    );
  }

  Future<void> setting(String key, dynamic value) async {
    try {
      await services.repository.setSetting(key, value);
      state = state.copyWith(settings: {...state.settings, key: value});
    } on Object {
      state = state.copyWith(
        error: 'That preference could not be saved. Please try again.',
      );
    }
  }

  Future<void> equip(String id, int cost) async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      final unlocked = await services.repository.unlock(id, cost);
      state = state.copyWith(
        busy: false,
        settings: await services.repository.settings(),
        balance: await services.repository.balance(),
        error: unlocked
            ? null
            : 'Solve a few more gardens to earn this companion.',
      );
    } on Object {
      state = state.copyWith(
        busy: false,
        error: 'Your companion could not be saved. Please try again.',
      );
    }
  }

  Future<void> deleteData() async {
    _clock
      ..stop()
      ..reset();
    await services.repository.deleteAll();
    state = AppState(settings: {}, progress: {});
  }
}
