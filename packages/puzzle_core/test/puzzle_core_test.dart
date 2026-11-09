import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

void main() {
  final raw =
      (jsonDecode(
                File(
                  '../../test-fixtures/Pawgrid_sample_level.json',
                ).readAsStringSync(),
              )
              as Map)
          .cast<String, dynamic>();
  final p = PuzzleDefinition.fromJson(raw);
  final catalog =
      jsonDecode(File('../../content/catalog.json').readAsStringSync()) as Map;
  final all = (catalog['levels'] as List)
      .map((j) => PuzzleDefinition.fromJson((j as Map).cast<String, dynamic>()))
      .toList();
  test('reference fixture, exact hash, and token-only completion', () {
    expect(
      p.computedHash,
      '9fe7ca82f62756eedc1ed9f6c4851746802bf18aade40f69bdc4cd25194d78b2',
    );
    expect(const ExactSolver().validate(p), isEmpty);
    expect(const ExactSolver().solve(p), [
      [1, 4, 2, 0, 3],
    ]);
    final solved = List.filled(25, CellMark.unknown);
    for (var r = 0; r < 5; r++) {
      solved[r * 5 + p.solution[r]] = CellMark.token;
    }
    expect(Rules.isWon(p, solved), isTrue);
  });
  test('all constraints; distant diagonal is not touching', () {
    List<CellMark> pair(int a, int b) => List.generate(
      25,
      (i) => i == a || i == b ? CellMark.token : CellMark.unknown,
    );
    expect(Rules.conflicts(p, pair(0, 4)).map((c) => c.code), contains('row'));
    expect(
      Rules.conflicts(p, pair(0, 20)).map((c) => c.code),
      contains('column'),
    );
    expect(
      Rules.conflicts(p, pair(2, 14)).map((c) => c.code),
      contains('region'),
    );
    expect(
      Rules.conflicts(p, pair(12, 18)).map((c) => c.code),
      contains('touching'),
    );
    expect(
      Rules.conflicts(p, pair(12, 24)).map((c) => c.code),
      isNot(contains('touching')),
    );
    expect(Rules.isWon(p, List.filled(25, CellMark.unknown)), isFalse);
  });
  test(
    'malformed, disconnected, corrupt and ambiguous definitions rejected',
    () {
      PuzzleDefinition parse(Map<String, dynamic> changes) =>
          PuzzleDefinition.fromJson({...raw, ...changes});
      expect(
        const ExactSolver().validate(parse({'contentHash': 'broken'})),
        contains('hash'),
      );
      expect(Rules.validateSchema(parse({'n': 3})), contains('size'));
      final regions = p.regions.map((r) => r.toList()).toList()..[4][4] = 0;
      expect(
        Rules.validateSchema(parse({'regions': regions})),
        contains('disconnected region'),
      );
      expect(
        () => parse({
          'givens': [
            {'row': 0, 'col': 0, 'mark': 'Other'},
          ],
        }),
        throwsFormatException,
      );
      expect(
        Rules.validateSchema(
          parse({
            'givens': [
              {'row': 0, 'col': 0, 'mark': 'Token'},
              {'row': 0, 'col': 0, 'mark': 'Token'},
            ],
          }),
        ),
        contains('duplicate given'),
      );
      final q0 = parse({'regions': List.generate(5, (r) => List.filled(5, r))});
      final q = parse({'regions': q0.regions, 'contentHash': q0.computedHash});
      expect(const ExactSolver().validate(q), contains('not unique'));
    },
  );
  test(
    'all 298 definitions independently solved and every human deduction proven',
    () {
      expect(all.length, 298);
      expect((catalog['journey'] as List).length, 200);
      for (final q in all) {
        expect(const ExactSolver().validate(q), isEmpty, reason: q.levelId);
        final state = q.initialMarks();
        for (final d in const HumanDeductionEngine().trace(q)) {
          expect(state[d.cell], CellMark.unknown);
          expect(
            d.mark == CellMark.token,
            q.solution[d.cell ~/ q.n] == d.cell % q.n,
            reason: '${q.levelId} ${d.tactic}',
          );
          state[d.cell] = d.mark;
        }
        expect(Rules.isWon(q, state), isTrue, reason: q.levelId);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'contradictory marks produce no hint; tentative marks are preserved',
    () {
      final marks = p.initialMarks()
        ..[0] = CellMark.token
        ..[1] = CellMark.token;
      expect(const HumanDeductionEngine().next(p, marks), isNull);
      expect(marks[0], CellMark.token);
      expect(marks[1], CellMark.token);
    },
  );
  test('100,000 randomized immutable session commands, undo and save/load', () {
    final rng = Random(44);
    var session = PuzzleSession.start(p);
    for (var i = 0; i < 100000; i++) {
      final before = session, snapshot = session.marks.toList();
      switch (rng.nextInt(6)) {
        case 0:
          session = session.undo(p);
        case 1:
          if (i % 23 == 0) session = PuzzleSession.start(p);
        case 2:
          session = PuzzleSession.fromJson(
            p,
            jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>,
          );
        default:
          session = session.tap(
            p,
            rng.nextInt(25),
            rng.nextBool() ? InputMode.mark : InputMode.place,
          );
      }
      expect(before.marks, snapshot);
      if (i % 97 == 0)
        expect(
          PuzzleSession.fromJson(p, session.toJson()).marks,
          session.marks,
        );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
  test('fixed clues resist user commands and altered saves', () {
    final q = all.first,
        s = PuzzleSession.start(all.first),
        cell = q.givens.first.row * q.n + q.givens.first.col;
    expect(identical(s.tap(q, cell, InputMode.mark), s), isTrue);
    expect(
      () => PuzzleSession.fromJson(q, {
        ...s.toJson(),
        'marks': List.filled(q.n * q.n, 0),
      }),
      throwsFormatException,
    );
  });
  test('token replacement and undo restore exact previous mark', () {
    var s = PuzzleSession.start(
      p,
    ).tap(p, 1, InputMode.place).tap(p, 1, InputMode.mark);
    expect(s.marks[1], CellMark.excluded);
    s = s.undo(p);
    expect(s.marks[1], CellMark.token);
    expect(PuzzleSession.fromJson(p, s.toJson()).history.length, 1);
  });
  test(
    'exhaustive solution enumeration matches 72 independent Python vectors 4x4–9x9',
    () {
      final cases =
          jsonDecode(
                File(
                  '../../test-fixtures/solver_parity.json',
                ).readAsStringSync(),
              )
              as List;
      for (final vector in cases) {
        final board = PuzzleDefinition.fromJson(
          (vector['level'] as Map).cast<String, dynamic>(),
        );
        final expected = (vector['solutions'] as List)
            .map((r) => (r as List).cast<int>())
            .toList();
        expect(
          const ExactSolver().solve(board, limit: 1000000),
          expected,
          reason: board.levelId,
        );
        expect(
          const ExactSolver().solve(board).length,
          min(2, expected.length),
        );
      }
    },
  );
  test(
    'eight rotations/reflections preserve fixture rules, connectivity and uniqueness',
    () {
      for (var rotation = 0; rotation < 4; rotation++) {
        for (final reflect in [false, true]) {
          (int, int) transform(int r, int c) {
            for (var turn = 0; turn < rotation; turn++) {
              final old = r;
              r = c;
              c = p.n - 1 - old;
            }
            if (reflect) c = p.n - 1 - c;
            return (r, c);
          }

          final regions = List.generate(p.n, (_) => List.filled(p.n, 0)),
              solution = List.filled(p.n, 0);
          for (var r = 0; r < p.n; r++) {
            for (var c = 0; c < p.n; c++) {
              final point = transform(r, c);
              regions[point.$1][point.$2] = p.regions[r][c];
            }
            final point = transform(r, p.solution[r]);
            solution[point.$1] = point.$2;
          }
          final next = {
            ...raw,
            'levelId': 'symmetry-$rotation-$reflect',
            'regions': regions,
            'solutionColumnsByRow': solution,
          };
          final candidate = PuzzleDefinition.fromJson(next);
          expect(
            const ExactSolver().validate(
              PuzzleDefinition.fromJson({
                ...next,
                'contentHash': candidate.computedHash,
              }),
            ),
            isEmpty,
          );
        }
      }
    },
  );
}
