import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static const String _keyVpsUrl   = 'vps_url';
  static const String _keyApiKey   = 'api_key';

  static const String defaultVpsUrl = 'https://YOUR_VPS_IP';
  static const String defaultApiKey = '';

  static Future<String> getVpsUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVpsUrl) ?? defaultVpsUrl;
  }

  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey) ?? defaultApiKey;
  }

  static Future<void> save({required String vpsUrl, required String apiKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVpsUrl, vpsUrl);
    await prefs.setString(_keyApiKey, apiKey);
  }
}
