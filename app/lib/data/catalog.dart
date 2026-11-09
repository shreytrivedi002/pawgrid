import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'catalog_digest.dart';

class ContentCatalog {
  ContentCatalog._(this.levels, this.journey, this.daily, this.practice);
  final Map<String, PuzzleDefinition> levels;
  final List<String> journey, practice;
  final Map<String, String> daily;
  factory ContentCatalog.parse(String payload, String expectedHash) {
    if (sha256.convert(utf8.encode(payload)).toString() !=
        expectedHash.trim()) {
      throw const FormatException('Catalog checksum mismatch');
    }
    final json = jsonDecode(payload) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1 ||
        json['rulesetVersion'] != 'territory-v1') {
      throw const FormatException('Unsupported catalog');
    }
    final levels = <String, PuzzleDefinition>{};
    for (final raw in json['levels'] as List) {
      final p = PuzzleDefinition.fromJson((raw as Map).cast<String, dynamic>());
      if (levels.containsKey(p.levelId) ||
          const ExactSolver().validate(p).isNotEmpty) {
        throw FormatException('Invalid puzzle: ${p.levelId}');
      }
      levels[p.levelId] = p;
    }
    final journey = (json['journey'] as List).cast<String>();
    final daily = (json['daily'] as Map).cast<String, String>();
    final practice = (json['practice'] as List).cast<String>();
    if ([
      ...journey,
      ...daily.values,
      ...practice,
    ].any((id) => !levels.containsKey(id))) {
      throw const FormatException('Missing catalog definition');
    }
    return ContentCatalog._(
      Map.unmodifiable(levels),
      List.unmodifiable(journey),
      Map.unmodifiable(daily),
      List.unmodifiable(practice),
    );
  }
  static Future<ContentCatalog> load() async {
    try {
      return ContentCatalog.parse(
        await rootBundle.loadString('assets/content/catalog.json'),
        bundledCatalogDigest,
      );
    } on Object {
      final backup = await rootBundle.load(
        'assets/content/catalog.fallback.gz',
      );
      return ContentCatalog.parse(
        utf8.decode(
          gzip.decode(
            backup.buffer.asUint8List(
              backup.offsetInBytes,
              backup.lengthInBytes,
            ),
          ),
        ),
        bundledCatalogDigest,
      );
    }
  }
}
