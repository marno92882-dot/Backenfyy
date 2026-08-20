import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../core/utils.dart';

class LogViewer extends StatelessWidget {
  final List<LogEntry> entries;
  const LogViewer({super.key, required this.entries});

  IconData _icon(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return Icons.check_circle_outline;
      case LogLevel.warning:
        return Icons.warning_amber_rounded;
      case LogLevel.error:
        return Icons.error_outline;
      case LogLevel.info:
        return Icons.info_outline;
    }
  }

  Color _color(BuildContext context, LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return Colors.greenAccent;
      case LogLevel.warning:
        return Colors.orangeAccent;
      case LogLevel.error:
        return Theme.of(context).colorScheme.error;
      case LogLevel.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('Belum ada log.'));
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: entries.length,
      itemBuilder: (_, index) {
        final e = entries[entries.length - 1 - index];
        return ListTile(
          dense: true,
          leading: Icon(_icon(e.level), color: _color(context, e.level)),
          title: Text(e.message),
          subtitle: Text(formatTime(e.timestamp)),
        );
      },
    );
  }
}
