import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Social platforms with their official logo and colours.
enum Brand {
  whatsapp('WhatsApp', Color(0xFF25D366)),
  instagram('Instagram', Color(0xFFE1306C)),
  facebook('Facebook', Color(0xFF1877F2));

  final String label;
  final Color color;
  const Brand(this.label, this.color);

  FaIconData get icon => switch (this) {
        Brand.whatsapp => FontAwesomeIcons.whatsapp,
        Brand.instagram => FontAwesomeIcons.instagram,
        Brand.facebook => FontAwesomeIcons.facebook,
      };

  /// Background used for filled buttons (Instagram uses its gradient).
  Gradient get gradient => switch (this) {
        Brand.instagram => const LinearGradient(
            colors: [
              Color(0xFFFEDA75),
              Color(0xFFFA7E1E),
              Color(0xFFD62976),
              Color(0xFF962FBF),
              Color(0xFF4F5BD5),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        _ => LinearGradient(colors: [color, color]),
      };
}

/// Official brand logo. Leave [color] null for the brand's own colours.
///
/// Font Awesome logos must be drawn with [FaIcon], not [Icon]; the standard
/// Icon widget clips them.
class BrandLogo extends StatelessWidget {
  final Brand brand;
  final double size;
  final Color? color;

  const BrandLogo(this.brand, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    if (color == null && brand == Brand.instagram) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => brand.gradient.createShader(bounds),
        child: FaIcon(brand.icon, size: size, color: Colors.white),
      );
    }
    return FaIcon(brand.icon, size: size, color: color ?? brand.color);
  }
}

/// Full-width (or natural-width) button filled with the brand colour.
class BrandButton extends StatefulWidget {
  final Brand brand;
  final String text;
  final VoidCallback onPressed;
  final bool expand;

  const BrandButton({
    super.key,
    required this.brand,
    required this.text,
    required this.onPressed,
    this.expand = false,
  });

  @override
  State<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<BrandButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.expand ? double.infinity : null,
        height: 52,
        decoration: BoxDecoration(
          gradient: brand.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: brand.color.withValues(alpha: _hovered ? 0.45 : 0.25),
              blurRadius: _hovered ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BrandLogo(brand, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round logo button, e.g. for the footer.
class BrandCircleButton extends StatelessWidget {
  final Brand brand;
  final VoidCallback onPressed;
  final double size;

  const BrandCircleButton({
    super.key,
    required this.brand,
    required this.onPressed,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: brand.label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: brand.gradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: BrandLogo(brand, size: size * 0.5, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
