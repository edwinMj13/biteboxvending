import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/content_providers.dart';
import '../../core/content/site_content_models.dart';
import '../../core/theme/app_theme.dart';
import 'brand_icons.dart';

class FooterSection extends ConsumerWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(contactProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          color: AppTheme.darkColor(context),
          // On mobile the floating bottom dock overlaps the page, so leave
          // room for it below the footer content.
          padding: EdgeInsets.fromLTRB(
            24,
            48,
            24,
            isDesktop ? 48 : 48 + 90 + MediaQuery.of(context).padding.bottom,
          ),
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
                            Expanded(child: _buildContactColumn(context, contact)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBrandColumn(context),
                            const SizedBox(height: 32),
                            _buildLinksColumn(context),
                            const SizedBox(height: 32),
                            _buildContactColumn(context, contact),
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
                                _buildSocialRow(contact),
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
                                _buildSocialRow(contact),
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

  Widget _buildContactColumn(BuildContext context, ContactInfo contact) {
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
            Expanded(
              child: Text(
                contact.address,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone_outlined, color: AppTheme.primary(context), size: 18),
            const SizedBox(width: 8),
            Text(
              contact.phone,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.email_outlined, color: AppTheme.primary(context), size: 18),
            const SizedBox(width: 8),
            Text(
              contact.email,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildSocialRow(ContactInfo contact) {
    final buttons = [
      BrandCircleButton(
        brand: Brand.whatsapp,
        onPressed: () => _launchUrl(contact.whatsappUrl()),
      ),
      if (contact.instagramUrl.isNotEmpty)
        BrandCircleButton(
          brand: Brand.instagram,
          onPressed: () => _launchUrl(contact.instagramUrl),
        ),
      if (contact.facebookUrl.isNotEmpty)
        BrandCircleButton(
          brand: Brand.facebook,
          onPressed: () => _launchUrl(contact.facebookUrl),
        ),
    ];

    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          buttons[i],
        ],
      ],
    );
  }
}
