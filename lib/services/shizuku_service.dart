import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shizuku_api/shizuku_api.dart';

class ShizukuService extends ChangeNotifier {
  final ShizukuApi _api = ShizukuApi();
  Timer? _timer;
  bool _binderRunning = false;
  bool _permissionGranted = false;
  bool _checking = false;

  bool get isReady => _binderRunning && _permissionGranted;
  bool get binderRunning => _binderRunning;
  bool get permissionGranted => _permissionGranted;
  bool get isChecking => _checking;

  Future<void> startMonitoring({Duration interval = const Duration(seconds: 5)}) async {
    await refresh();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_checking) return;
    _checking = true;
    try {
      _binderRunning = (await _api.pingBinder()) ?? false;
      _permissionGranted = _binderRunning && ((await _api.checkPermission()) ?? false);
    } catch (_) {
      _binderRunning = false;
      _permissionGranted = false;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  Future<bool> requestPermission() async {
    try {
      final ok = (await _api.requestPermission()) ?? false;
      await refresh();
      return ok && isReady;
    } catch (_) {
      await refresh();
      return false;
    }
  }

  Future<String?> runCommand(String command) async {
    if (!isReady) throw StateError('Shizuku belum siap.');
    return _api.runCommand(command);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
