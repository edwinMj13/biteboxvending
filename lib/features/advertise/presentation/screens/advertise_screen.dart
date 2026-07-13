import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class AdvertiseScreen extends StatelessWidget {
  const AdvertiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner
          _buildBannerSection(context, isDesktop),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 20,
              vertical: 60,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    const ScreenTitle(
                      title: 'Advertise With BiteBox',
                      subtitle:
                          'Get your brand directly in front of thousands of tech employees, college students, hospital visitors, and government office staff daily.',
                      centerText: true,
                    ),
                    const SizedBox(height: 56),

                    // Channels Section
                    Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      children: [
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: _buildChannelCard(
                            context,
                            icon: Icons.aspect_ratio_rounded,
                            title: 'Full Machine Vinyl Wraps',
                            description:
                                'Transform our physical machines into a custom billboard for your brand. Located in high-footfall spots, your custom vinyl skin ensures continuous visual exposure.',
                            points: [
                              'High-quality vinyl printing and application',
                              'Unmissable 3D physical presence',
                              'Perfect for brand launches and logo familiarity',
                            ],
                          ),
                        ),
                        if (isDesktop) const SizedBox(width: 32),
                        if (!isDesktop) const SizedBox(height: 32),
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: _buildChannelCard(
                            context,
                            icon: Icons.tv_rounded,
                            title: 'Digital Screen Advertising',
                            description:
                                'Display interactive images, loops, and video ads directly on our vending screens during user checkout cycles or idle states.',
                            points: [
                              'Vibrant, high-definition digital layouts',
                              'Scheduled loops targeting specific hours',
                              'Direct call-to-actions synced with purchases',
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),

                    // Statistics Section
                    const Text(
                      'Why Vending Advertisements Work',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Automated retail units hold active attention during select-and-buy cycles.',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildStatsRow(context, isDesktop),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          const FooterSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: AppTheme.darkColor(context),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADVERTISE HUB',
                style: TextStyle(
                  color: AppTheme.primary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Advertise on BiteBox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> points,
  }) {
    final primaryColor = AppTheme.primary(context);
    return Container(
      decoration: AppTheme.cardDecoration(context).copyWith(
        border: Border.all(
          color: primaryColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            ...points.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDesktop) {
    final benefits = [
      _BenefitData(
        value: '100%',
        title: 'Captive Gaze',
        desc: 'Customers look directly at the machine while selecting and purchasing.',
      ),
      _BenefitData(
        value: '5K+',
        title: 'Impressions/Day',
        desc: 'Continuous exposure from passersby and regular campus/office visitors.',
      ),
      _BenefitData(
        value: '80%',
        title: 'Repeat Visits',
        desc: 'Snack purchases create habitual interaction pathways for your brand.',
      ),
    ];

    final primaryColor = AppTheme.primary(context);

    if (!isDesktop) {
      return Column(
        children: benefits.map((b) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.cardDecoration(context).copyWith(
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Text(
                      b.value,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.desc,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return Flex(
      direction: isDesktop ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: benefits.map((b) {
        return Container(
          width: isDesktop ? 300 : double.infinity,
          margin: EdgeInsets.only(bottom: isDesktop ? 0 : 24),
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration(context),
          child: Column(
            children: [
              Text(
                b.value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                b.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                b.desc,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BenefitData {
  final String value;
  final String title;
  final String desc;
  _BenefitData({required this.value, required this.title, required this.desc});
}
