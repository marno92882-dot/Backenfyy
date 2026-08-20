import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/log_entry.dart';
import '../services/vercel_service.dart';

/// Centralized request/server logic for the diagnostic local server.
///
/// Safety boundary:
/// - This implementation does NOT decrypt, modify, replay, or bypass game login traffic.
/// - /Ping and /health are real diagnostic endpoints.
/// - /MajorLogin is deliberately rejected with 501 instead of intercepting credentials.
/// - Only sanitized metadata may be sent to the optional Vercel endpoint.
class RequestHandler {
  final void Function(LogEntry entry) onLog;
  final VercelService vercelService;
  HttpServer? _server;
  bool _running = false;

  RequestHandler({required this.onLog, VercelService? vercelService})
      : vercelService = vercelService ?? VercelService();

  bool get isRunning => _running;
  HttpServer? get server => _server;

  Future<void> start(int port) async {
    if (_running) return;
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
      _running = true;
      _log(LogLevel.success, 'Server diagnostik aktif pada port $port');
      unawaited(_serve(_server!));
    } catch (e) {
      _log(LogLevel.error, 'Gagal start server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _running = false;
    if (server != null) await server.close(force: true);
    _log(LogLevel.info, 'Server dihentikan');
  }

  Future<void> _serve(HttpServer server) async {
    try {
      await for (final request in server) {
        unawaited(handleRequest(request));
      }
    } catch (e) {
      if (_running) _log(LogLevel.error, 'Loop server error: $e');
    }
  }

  Future<void> handleRequest(HttpRequest request) async {
    final started = DateTime.now();
    final path = request.uri.path;
    final method = request.method;
    _log(LogLevel.info, '$method $path masuk');

    try {
      if (path == '/Ping' || path == '/health') {
        await _respondJson(request.response, 200, {
          'ok': true,
          'service': 'PC Logo diagnostic server',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });
      } else if (path == '/MajorLogin') {
        // Never handle or alter authentication traffic here.
        await _respondJson(request.response, 501, {
          'ok': false,
          'error': 'MajorLogin interception is not supported by this build.',
        });
        _log(LogLevel.warning, '/MajorLogin rejected safely (no credential interception)');
      } else {
        await _respondJson(request.response, 404, {
          'ok': false,
          'error': 'Not found',
        });
      }

      final elapsed = DateTime.now().difference(started).inMilliseconds;
      _log(LogLevel.success, 'Response ${request.response.statusCode} ${method} $path (${elapsed}ms)');
      unawaited(vercelService.sendSanitizedEvent({
        'kind': 'http_event',
        'method': method,
        'path': path,
        'status': request.response.statusCode,
        'elapsedMs': elapsed,
      }).catchError((_) {}));
    } catch (e) {
      _log(LogLevel.error, 'Request error $method $path: $e');
      if (!request.response.headersSent) {
        await _respondJson(request.response, 500, {'ok': false, 'error': 'Internal server error'});
      }
    }
  }

  Future<void> _respondJson(HttpResponse response, int status, Map<String, dynamic> body) async {
    response.statusCode = status;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(body));
    await response.close();
  }

  void _log(LogLevel level, String message) {
    onLog(LogEntry(timestamp: DateTime.now(), level: level, message: message));
  }
}
