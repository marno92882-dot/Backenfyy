import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../core/constants.dart';

class PortService {
  Future<int> findAvailablePort() async {
    if (await _isAvailable(AppConstants.preferredPort)) {
      return AppConstants.preferredPort;
    }

    final random = Random.secure();
    for (var attempt = 0; attempt < 100; attempt++) {
      final port = AppConstants.minRandomPort +
          random.nextInt(AppConstants.maxRandomPort - AppConstants.minRandomPort + 1);
      if (await _isAvailable(port)) return port;
    }

    for (var port = AppConstants.minRandomPort; port <= AppConstants.maxRandomPort; port++) {
      if (await _isAvailable(port)) return port;
    }
    throw StateError('Tidak menemukan port yang tersedia.');
  }

  Future<bool> _isAvailable(int port) async {
    ServerSocket? socket;
    try {
      socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port, shared: false);
      return true;
    } catch (_) {
      return false;
    } finally {
      await socket?.close();
    }
  }
}
