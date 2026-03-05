import 'package:flutter/services.dart';

class DigitMaskInputFormatter extends TextInputFormatter {
  DigitMaskInputFormatter({required this.mask, required this.maxDigits});

  final String mask;
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final clipped = digitsOnly.substring(0, digitsOnly.length.clamp(0, maxDigits));
    final formatted = _applyMask(clipped);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  String _applyMask(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    var digitIndex = 0;

    for (var i = 0; i < mask.length; i++) {
      final char = mask[i];
      if (char == '#') {
        if (digitIndex >= digits.length) break;
        buffer.write(digits[digitIndex]);
        digitIndex++;
      } else {
        if (digitIndex >= digits.length) break;
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}

class LowerCaseDomainInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = newValue.text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9.-]'), '');

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
      composing: TextRange.empty,
    );
  }
}
