import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final primaryBgColor = isEnabled
        ? (_isHovered ? AppTheme.primaryDark(context) : AppTheme.primary(context))
        : Colors.grey.shade400;

    final secondaryBorderColor = isEnabled
        ? (_isHovered ? AppTheme.primaryDark(context) : AppTheme.primary(context))
        : Colors.grey.shade400;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isPrimary ? Colors.white : AppTheme.primary(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 20,
            color: widget.isPrimary ? Colors.white : AppTheme.primary(context),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: widget.isPrimary
                ? Colors.white
                : (isEnabled ? AppTheme.primary(context) : Colors.grey.shade500),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: 52,
        child: widget.isPrimary
            ? ElevatedButton(
                onPressed: isEnabled ? widget.onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBgColor,
                  elevation: _isHovered ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: content,
              )
            : OutlinedButton(
                onPressed: isEnabled ? widget.onPressed : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: secondaryBorderColor, width: 2),
                  backgroundColor: _isHovered
                      ? AppTheme.primary(context).withOpacity(0.05)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: content,
              ),
      ),
    );
  }
}
