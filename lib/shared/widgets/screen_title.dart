import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centerText;

  const ScreenTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.centerText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.darkColor(context),
            letterSpacing: 0.5,
          ),
          textAlign: centerText ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary(context),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
            textAlign: centerText ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }
}
