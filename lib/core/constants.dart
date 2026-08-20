class AppConstants {
  static const appName = 'PC Logo';
  static const version = '1.0.0+1';

  static const whatsappChannel = 'https://whatsapp.com/channel/REPLACE_ME';
  static const telegramChannel = 'https://t.me/REPLACE_ME';

  static const normalPackage = 'com.dts.freefireth';
  static const maxPackage = 'com.dts.freefiremax';
  static const normalConfigPath =
      '/storage/emulated/0/Android/data/com.dts.freefireth/files/localconfig.json';
  static const maxConfigPath =
      '/storage/emulated/0/Android/data/com.dts.freefiremax/files/localconfig.json';

  static const preferredPort = 5030;
  static const minRandomPort = 1024;
  static const maxRandomPort = 65535;
  static const shizukuPollSeconds = 5;

  // Optional endpoint for sending sanitized diagnostic metadata only.
  // Do not use this for game credentials, decrypted bodies, or authentication tokens.
  static const vercelDiagnosticsEndpoint = '';
}
