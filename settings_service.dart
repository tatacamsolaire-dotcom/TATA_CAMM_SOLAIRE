
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _pinKey = 'pin_code';
  static const _darkKey = 'dark_mode';
  static const _langKey = 'lang_code';
  static const _thresholdKey = 'low_stock_threshold';

  Future<void> setPin(String? pin) async {
    final sp = await SharedPreferences.getInstance();
    if (pin == null || pin.isEmpty) {
      await sp.remove(_pinKey);
    } else {
      await sp.setString(_pinKey, pin);
    }
  }

  Future<String?> getPin() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_pinKey);
  }

  Future<void> setDarkMode(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_darkKey, value);
  }

  Future<bool> getDarkMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_darkKey) ?? false;
  }

  Future<void> setLang(String code) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_langKey, code);
  }

  Future<String> getLang() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_langKey) ?? 'fr';
  }

  Future<void> setThreshold(int value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_thresholdKey, value);
  }

  Future<int> getThreshold() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_thresholdKey) ?? 5;
  }
}
