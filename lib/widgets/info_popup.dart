import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class InfoPopup extends StatelessWidget {
  const InfoPopup({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link tidak dapat dibuka.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('PC Logo'),
      content: const Text(
        'PC Logo membantu mengelola koneksi Shizuku, memilih game, membuat localconfig.json, dan menjalankan server diagnostik lokal dengan log real-time.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back / Close')),
        OutlinedButton.icon(
          onPressed: () => _open(context, AppConstants.whatsappChannel),
          icon: const Icon(Icons.chat),
          label: const Text('Support WhatsApp Channel'),
        ),
        FilledButton.icon(
          onPressed: () => _open(context, AppConstants.telegramChannel),
          icon: const Icon(Icons.send),
          label: const Text('Support Telegram Channel'),
        ),
      ],
    );
  }
}
