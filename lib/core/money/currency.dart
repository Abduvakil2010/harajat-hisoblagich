/// Supported currencies.
///
/// All amounts in HisobAI are stored as integer *minor units* (1/100 of the
/// currency unit) to avoid floating point rounding errors. Adding a new
/// currency only requires a new enum value here plus a translation key.
enum Currency {
  uzs('UZS', 'soʻm', 2, 0),
  usd('USD', r'$', 2, 2);

  const Currency(
    this.code,
    this.symbol,
    this.minorDigits,
    this.displayDecimals,
  );

  /// ISO 4217 code.
  final String code;

  /// Short symbol used in compact UI.
  final String symbol;

  /// Number of fractional digits stored (minor units).
  final int minorDigits;

  /// Number of fractional digits shown by default in the UI.
  final int displayDecimals;

  int get minorFactor {
    var f = 1;
    for (var i = 0; i < minorDigits; i++) {
      f *= 10;
    }
    return f;
  }

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code.toUpperCase(),
    orElse: () =>
        throw ArgumentError.value(code, 'code', 'Unsupported currency'),
  );

  static Currency? tryParse(String? code) {
    if (code == null) return null;
    for (final c in Currency.values) {
      if (c.code == code.toUpperCase()) return c;
    }
    return null;
  }
}
