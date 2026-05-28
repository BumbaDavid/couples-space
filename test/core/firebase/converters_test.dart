import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couples_space/core/firebase/converters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dateTimesToTimestamps converts ISO strings to Timestamps', () {
    final input = {
      'title': 'x',
      'createdAt': '2026-01-01T12:00:00.000Z',
      'updatedAt': '2026-01-02T12:00:00.000Z',
    };
    final out = dateTimesToTimestamps(input, ['createdAt', 'updatedAt']);
    expect(out['title'], 'x');
    expect(out['createdAt'], isA<Timestamp>());
    expect(
      (out['createdAt'] as Timestamp).toDate().toUtc().toIso8601String(),
      '2026-01-01T12:00:00.000Z',
    );
  });

  test('timestampsToDateTimes converts Timestamps to ISO strings', () {
    final input = {
      'title': 'x',
      'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 12)),
    };
    final out = timestampsToDateTimes(input, ['createdAt']);
    expect(out['createdAt'], '2026-01-01T12:00:00.000Z');
  });
}
