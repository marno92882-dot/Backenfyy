import 'package:dio/dio.dart';
import '../core/constants.dart';

class VercelService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)));

  Future<void> sendSanitizedEvent(Map<String, dynamic> event) async {
    final endpoint = AppConstants.vercelDiagnosticsEndpoint.trim();
    if (endpoint.isEmpty) return;
    await _dio.post(endpoint, data: event, options: Options(contentType: 'application/json'));
  }
}
