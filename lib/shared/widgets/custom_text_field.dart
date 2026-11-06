import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? prefix; // Used instead of [prefixIcon], e.g. a brand logo
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  /// Shows "(optional)" next to the label.
  final bool isOptional;

  /// Blocks characters as they are typed (e.g. letters in a phone field).
  final List<TextInputFormatter>? inputFormatters;

  /// When set, limits the length and shows a "12/500" counter.
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  /// Validate as the user types (after their first edit), so errors appear
  /// and clear without waiting for the submit button.
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.prefix,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
    this.onSubmitted,
    this.isOptional = false,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (isOptional)
                const TextSpan(
                  text: '  (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF393E46),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            errorMaxLines: 2,
            prefixIcon: prefix != null
                ? SizedBox(width: 48, child: Center(child: prefix))
                : prefixIcon != null
                ? Icon(prefixIcon, size: 20)
                : null,
          ),
        ),
      ],
    );
  }
}
