import 'package:shared_preferences/shared_preferences.dart';

/// Simple, non-sensitive preferences only. Firebase persists its own session.
class CacheHelper {
  CacheHelper(this._prefs);
  final SharedPreferencesAsync _prefs;

  static const _onboardingKey = 'onboarding_completed';
  static const _languageKey = 'language';
  static const _themeKey = 'theme_mode';

  Future<bool> isOnboardingCompleted() async =>
      await _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted(bool completed) =>
      _prefs.setBool(_onboardingKey, completed);

  Future<String?> getLanguage() => _prefs.getString(_languageKey);
  Future<void> setLanguage(String code) => _prefs.setString(_languageKey, code);

  Future<String?> getThemeMode() => _prefs.getString(_themeKey);
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeKey, mode);
}
