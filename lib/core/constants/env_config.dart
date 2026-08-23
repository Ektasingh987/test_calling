import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get agoraAppId => dotenv.env['AGORA_APP_ID'] ?? '';
  static String get agoraToken => dotenv.env['AGORA_TOKEN'] ?? '';
  static String get agoraChannelName =>
      dotenv.env['AGORA_CHANNEL_NAME'] ?? 'gaongram_main';
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://gaongram.com/api/v1';
  static String? get authToken => dotenv.env['AUTH_TOKEN'];
}
