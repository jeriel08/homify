// lib/theme/typography.dart
import 'package:flutter/material.dart';

class HomifyTypography {
  // ----- Private constructor -------------------------------------------------
  HomifyTypography._();

  // ----- Font family --------------------------------------------------------
  static const String _font = 'Poppins';

  // ----- Helper -------------------------------------------------------------
  static TextStyle _style({
    required double size,
    required double height,
    required double spacing,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: _font,
    fontSize: size,
    height: height / size, // Flutter wants height as a factor
    letterSpacing: spacing,
    fontWeight: weight,
  );

  // ----- Titles -------------------------------------------------------------
  static final title1 = _style(size: 72, height: 88, spacing: -0.8);
  static final title2 = _style(size: 64, height: 76, spacing: -0.8);
  static final title3 = _style(size: 56, height: 68, spacing: -0.8);

  // ----- Headings -----------------------------------------------------------
  static final heading1 = _style(size: 56, height: 68, spacing: -0.5);
  static final heading2 = _style(size: 48, height: 58, spacing: -0.4);
  static final heading3 = _style(size: 40, height: 48, spacing: -0.3);
  static final heading4 = _style(size: 32, height: 38, spacing: -0.2);
  static final heading5 = _style(size: 24, height: 30, spacing: -0.15);
  static final heading6 = _style(size: 20, height: 24, spacing: 0);

  // ----- Labels -------------------------------------------------------------
  static final label1 = _style(size: 16, height: 22, spacing: -0.18);
  static final label2 = _style(size: 14, height: 20, spacing: -0.16);
  static final label3 = _style(size: 12, height: 16, spacing: -0.12);

  // ----- Body ---------------------------------------------------------------
  static final body1 = _style(size: 18, height: 28, spacing: 0);
  static final body2 = _style(size: 16, height: 24, spacing: 0);
  static final body3 = _style(size: 14, height: 20, spacing: 0);
  static final body4 = _style(size: 12, height: 16, spacing: 0);

  // ----- Caption ------------------------------------------------------------
  static final caption1 = _style(size: 10, height: 12, spacing: 0);
  static final caption2 = _style(size: 9, height: 10, spacing: -0.18);

  // ----- Weight variants (optional) -----------------------------------------
  static TextStyle bold(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w700);
  static TextStyle medium(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle semibold(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w600);
}
