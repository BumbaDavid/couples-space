import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, dynamic> dateTimesToTimestamps(
  Map<String, dynamic> input,
  List<String> dateTimeFields,
) {
  final result = Map<String, dynamic>.from(input);
  for (final field in dateTimeFields) {
    final value = result[field];
    if (value is String) {
      result[field] = Timestamp.fromDate(DateTime.parse(value));
    }
  }
  return result;
}

Map<String, dynamic> timestampsToDateTimes(
  Map<String, dynamic> input,
  List<String> dateTimeFields,
) {
  final result = Map<String, dynamic>.from(input);
  for (final field in dateTimeFields) {
    final value = result[field];
    if (value is Timestamp) {
      result[field] = value.toDate().toLocal().toIso8601String();
    }
  }
  return result;
}
