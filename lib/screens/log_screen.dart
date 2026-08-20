import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../widgets/log_viewer.dart';

class LogScreen extends StatelessWidget {
  final List<LogEntry> entries;
  final VoidCallback onClear;
  const LogScreen({super.key, required this.entries, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [IconButton(onPressed: onClear, tooltip: 'Clear log', icon: const Icon(Icons.delete_sweep_outlined))],
      ),
      body: LogViewer(entries: entries),
    );
  }
}
