import 'dart:convert';
import '../core/utils.dart';
import '../models/server_config.dart';
import 'shizuku_service.dart';

class ConfigService {
  final ShizukuService shizuku;

  ConfigService(this.shizuku);

  Future<void> writeConfig(ServerConfig config) async {
    final json = jsonEncode(config.toJson());
    final encoded = base64EncodeUtf8(json);
    final command = 'mkdir -p ${shellQuote(_parent(config.configPath))} && '
        'echo ${shellQuote(encoded)} | base64 -d > ${shellQuote(config.configPath)}';
    final result = await shizuku.runCommand(command);
    if (result == null) throw StateError('Shizuku tidak mengembalikan hasil penulisan config.');
  }

  Future<void> deleteConfig(String path) async {
    final result = await shizuku.runCommand('rm -f ${shellQuote(path)}');
    if (result == null) throw StateError('Shizuku tidak mengembalikan hasil penghapusan config.');
  }

  Future<String?> readConfig(String path) async {
    return shizuku.runCommand('cat ${shellQuote(path)} 2>/dev/null || true');
  }

  String _parent(String path) => path.substring(0, path.lastIndexOf('/'));
}
