import 'package:flutter/widgets.dart';

/// Spacing & shape tokens (4-pt grid).
abstract final class Insets {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Horizontal page gutter.
  static const page = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class Radii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const field = BorderRadius.all(Radius.circular(md));
  static const chip = BorderRadius.all(Radius.circular(sm));
}
