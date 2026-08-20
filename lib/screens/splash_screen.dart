import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF67E8F9), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.hub_rounded, size: 52, color: Colors.white),
            ).animate().scale(duration: 550.ms).fadeIn(),
            const SizedBox(height: 20),
            const Text(AppConstants.appName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Shizuku • Config • Diagnostic Server', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 28),
            const CircularProgressIndicator().animate(onPlay: (c) => c.repeat()).rotate(duration: 1200.ms),
          ],
        ),
      ),
    );
  }
}
