import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static String? get _font =>
      AppConfig.fontFamily.isEmpty ? null : AppConfig.fontFamily;

  static TextStyle get heading => TextStyle(
        fontFamily: _font,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.onBackground,
      );

  static TextStyle get title => TextStyle(
        fontFamily: _font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      );

  static TextStyle get body => TextStyle(
        fontFamily: _font,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: _font,
        fontSize: 12,
        color: AppColors.onSurfaceMuted,
      );

  static TextStyle get button => TextStyle(
        fontFamily: _font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onAccent,
      );
}
