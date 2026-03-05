import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onSubmitted,
    this.maxLength,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLength;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          enableSuggestions: false,
          onSubmitted: onSubmitted,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: AppTextStyles.caption,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
