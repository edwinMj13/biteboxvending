import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          color: AppTheme.darkColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildBrandColumn(context)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildLinksColumn(context)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildContactColumn(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBrandColumn(context),
                            const SizedBox(height: 32),
                            _buildLinksColumn(context),
                            const SizedBox(height: 32),
                            _buildContactColumn(context),
                          ],
                        ),
                  Divider(color: AppTheme.greyColor(context), height: 48),
                  LayoutBuilder(
                    builder: (context, footerConstraints) {
                      final isFooterWide = footerConstraints.maxWidth >= 650;
                      return isFooterWide
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '© 2026 BiteBox 24/7. All rights reserved.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildSocialIconButton(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      tooltip: 'WhatsApp Us',
                                      url: 'https://wa.me/918129037133',
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSocialIconButton(
                                      icon: Icons.camera_alt_outlined,
                                      tooltip: 'Instagram',
                                      url:
                                          'https://www.instagram.com/biteboxkochi',
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '© 2026 BiteBox 24/7. All rights reserved.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildSocialIconButton(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      tooltip: 'WhatsApp Us',
                                      url: 'https://wa.me/918129037133',
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSocialIconButton(
                                      icon: Icons.camera_alt_outlined,
                                      tooltip: 'Instagram',
                                      url:
                                          'https://www.instagram.com/biteboxkochi',
                                    ),
                                  ],
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BITEBOX',
                style: TextStyle(
                  color: AppTheme.darkColor(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '24/7',
              style: TextStyle(
                color: AppTheme.primary(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 250,
          child: Text(
            'Smart vending solutions providing fresh snacks and cold beverages all day, all night. Smart, cashless, and reliable.',
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(context, 'Smart Vending Solutions', '/'),
        _buildFooterLink(context, 'Franchise Opportunities', '/franchise'),
        _buildFooterLink(context, 'Advertise With Us', '/advertise'),
        _buildFooterLink(context, 'Location Map Finder', '/find-us'),
      ],
    );
  }

  Widget _buildContactColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get in Touch',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppTheme.primary(context),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Kochi, Kerala, India',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone_outlined, color: AppTheme.primary(context), size: 18),
            const SizedBox(width: 8),
            const Text(
              '+91 81290 37133',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.email_outlined, color: AppTheme.primary(context), size: 18),
            const SizedBox(width: 8),
            const Text(
              'biteboxkochi@gmail.com',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required IconData icon,
    required String tooltip,
    required String url,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
