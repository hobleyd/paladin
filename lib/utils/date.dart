import 'package:intl/intl.dart';

String getFormattedDateTime(int secondsSinceEpoch) {
  final DateTime lastRead = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
  return DateFormat('MMMM d, y HH:mm').format(lastRead);
}