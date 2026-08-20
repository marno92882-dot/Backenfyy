import 'package:flutter/material.dart';

class ServerStatusCard extends StatelessWidget {
  final bool ready;
  final bool running;
  final int? port;

  const ServerStatusCard({super.key, required this.ready, required this.running, required this.port});

  @override
  Widget build(BuildContext context) {
    final title = !ready ? 'Shizuku diperlukan' : running ? 'Server aktif' : 'Siap dijalankan';
    final subtitle = !ready
        ? 'Sambungkan Shizuku untuk melanjutkan'
        : running
            ? 'Port ${port ?? '-'}'
            : 'Server diagnostik berhenti';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ready ? Colors.greenAccent.withOpacity(.14) : Colors.orangeAccent.withOpacity(.14),
          child: Icon(ready ? Icons.check_circle : Icons.warning_amber_rounded),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
