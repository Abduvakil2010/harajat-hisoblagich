import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../core/localization/l10n.dart';
import '../../core/money/currency.dart';
import '../../core/money/money_format.dart';

/// Amount input with a currency toggle. Validation produces localized
/// messages and requires the amount to be > 0.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.currency,
    this.onCurrencyChanged,
    this.label,
    this.autofocus = false,
    this.large = false,
    this.allowZero = false,
  });

  final TextEditingController controller;
  final Currency currency;
  final ValueChanged<Currency>? onCurrencyChanged;
  final String? label;
  final bool autofocus;
  final bool large;

  /// Optional field: empty or zero input is accepted.
  final bool allowZero;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
      ],
      textInputAction: TextInputAction.next,
      style: large ? context.text.displaySmall : context.text.titleMedium,
      decoration: InputDecoration(
        labelText: label ?? l.amount,
        hintText: '0',
        suffixIcon: onCurrencyChanged == null
            ? Padding(
                padding: const EdgeInsets.only(right: Insets.lg),
                child: Center(
                  widthFactor: 1,
                  child: Text(currency.code, style: context.text.titleSmall),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: Insets.xs),
                child: CurrencyToggle(
                  value: currency,
                  onChanged: onCurrencyChanged!,
                ),
              ),
      ),
      validator: (v) {
        final parsed = MoneyFormat.parseMinor(v ?? '', currency);
        if ((v ?? '').trim().isEmpty) {
          return allowZero ? null : l.validationAmountRequired;
        }
        if (parsed == null) return l.validationAmountInvalid;
        if (!allowZero && parsed <= 0) return l.validationAmountPositive;
        return null;
      },
    );
  }
}

/// Compact UZS / USD segmented toggle.
class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Currency value;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in Currency.values)
            GestureDetector(
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c == value
                      ? context.colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.sm - 3),
                ),
                child: Text(
                  c.code,
                  style: context.text.labelMedium?.copyWith(
                    color: c == value
                        ? Colors.white
                        : context.palette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tappable read-only field that opens a date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.clearable = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Radii.field,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(now.year + 30),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
          suffixIcon: clearable && value != null
              ? IconButton(
                  tooltip: context.l10n.clear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(
          value == null ? context.l10n.notSet : context.dates.day(value!),
          style: context.text.bodyLarge,
        ),
      ),
    );
  }
}

/// Grid of selectable icons.
class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.keys,
    required this.selected,
    required this.color,
    required this.iconOf,
    required this.onSelected,
  });

  final List<String> keys;
  final String selected;
  final Color color;
  final IconData Function(String) iconOf;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final k in keys)
          InkResponse(
            onTap: () => onSelected(k),
            radius: 26,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: k == selected
                    ? color.withValues(alpha: 0.22)
                    : context.palette.surface2,
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(
                  color: k == selected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                iconOf(k),
                color: k == selected ? color : context.palette.textSecondary,
                size: 22,
              ),
            ),
          ),
      ],
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<int> colors;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final c in colors)
          GestureDetector(
            onTap: () => onSelected(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(c),
                shape: BoxShape.circle,
                border: Border.all(
                  color: c == selected
                      ? context.colors.onSurface
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
