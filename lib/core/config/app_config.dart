import 'package:flutter/widgets.dart';

abstract final class AppConfig {
  static const designSize = Size(430, 932);
  /// YTS v2. Override at build time if the chosen mirror is unreachable.
  static const apiBaseUrl = String.fromEnvironment(
    'MOVIES_API_BASE_URL', defaultValue: 'https://yts.pw/api/v2/',
  );
  static const userCollection = 'users';
  /// Public YTS does NOT accept Firebase ID tokens. Leave disabled.
  static const sendFirebaseTokenToApi = false;
  static const fontFamily = String.fromEnvironment('MOVIES_FONT_FAMILY');
}
