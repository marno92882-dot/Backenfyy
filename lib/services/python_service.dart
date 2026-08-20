import 'dart:convert';
import 'package:flutter/services.dart';

/// Loads the bundled diagnostic Python source for inspection/export.
/// Android builds do not include a Python interpreter by default, so the real
/// on-device server is implemented in Dart (RequestHandler) instead of pretending
/// to execute Python through a non-existent runtime.
class PythonService {
  Future<String> loadBundledScript() async {
    return rootBundle.loadString('assets/diagnostic_server.py');
  }

  Future<List<int>> loadBundledScriptBytes() async {
    final source = await loadBundledScript();
    return utf8.encode(source);
  }
}
