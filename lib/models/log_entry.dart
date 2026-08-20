import 'package:flutter/foundation.dart';

enum LogLevel { info, success, warning, error }

@immutable
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}
