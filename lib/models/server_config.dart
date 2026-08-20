import '../core/constants.dart';

enum GameVariant { normal, max }

class ServerConfig {
  final int port;
  final GameVariant game;
  final String configPath;

  const ServerConfig({
    required this.port,
    required this.game,
    required this.configPath,
  });

  String get packageName =>
      game == GameVariant.normal ? AppConstants.normalPackage : AppConstants.maxPackage;

  String get serverUrl => 'http://0.0.0.0:$port/';

  Map<String, dynamic> toJson() => {'serverUrl': serverUrl};
}
