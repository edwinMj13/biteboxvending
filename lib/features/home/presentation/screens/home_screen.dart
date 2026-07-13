import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          _buildHeroSection(context, ref, isDesktop),

          // Features Section
          _buildFeaturesSection(context, isDesktop),

          // How it Works Section
          _buildHowItWorksSection(context, isDesktop),

          // Stats Section
          _buildStatsSection(context, isDesktop),

          // Shared Footer
          const FooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    WidgetRef ref,
    bool isDesktop,
  ) {
    final primaryColor = AppTheme.primary(context);
    final secondaryColor = AppTheme.secondary(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkColor(context),
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Glowing Background Blob 1
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Glowing Background Blob 2
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;

                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text Column
                      isWide
                          ? Expanded(
                              flex: 6,
                              child: _buildHeroTextContent(context, ref, true),
                            )
                          : _buildHeroTextContent(context, ref, false),

                      if (isWide) const SizedBox(width: 48),

                      // Graphic representation (Interactive Vending Mockup)
                      isWide
                          ? Expanded(
                              flex: 5,
                              child: _buildHeroGraphic(context, true),
                            )
                          : _buildHeroGraphic(context, false),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTextContent(
    BuildContext context,
    WidgetRef ref,
    bool isWide,
  ) {
    return Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: AppTheme.secondary(context),
        //     borderRadius: BorderRadius.circular(20),
        //     boxShadow: [
        //       BoxShadow(
        //         color: AppTheme.secondary(context).withOpacity(0.3),
        //         blurRadius: 10,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: const Text(
        //     '⚡ SMART VENDING FOR KERALA',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 11,
        //       letterSpacing: 0.5,
        //     ),
        //   ),
        // ),
        const SizedBox(height: 24),
        Text(
          'Bite Right.\nDay or Night.',
          style: TextStyle(
            fontSize: isWide ? 54 : 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.15,
            fontFamily: 'Outfit',
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'BiteBox 24/7 brings a smart, automated retail experience to colleges, hospitals, government offices, corporate hubs, and public spots. Fresh treats, chilled sodas, and healthy snacks are just a tap away.',
          style: TextStyle(
            fontSize: isWide ? 17 : 14,
            color: Colors.grey.shade300,
            height: 1.5,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            CustomButton(
              text: 'Find a Vending Machine',
              onPressed: () {
                context.go('/find-us');
              },
            ),
            CustomButton(
              text: 'Partner with Us',
              isPrimary: false,
              onPressed: () {
                context.go('/franchise');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroGraphic(BuildContext context, bool isWide) {
    return Padding(
      padding: EdgeInsets.only(top: isWide ? 0 : 40),
      child: InteractiveVendingMockup(isWide: isWide),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    final features = [
      _FeatureItem(
        icon: Icons.qr_code_scanner_rounded,
        title: 'UPI Cashless Checkout',
        description:
            'Pay easily with GooglePay, PhonePe, Paytm, or cards. Scan the QR, pick your treat, and pay in seconds.',
      ),
      _FeatureItem(
        icon: Icons.flash_on_rounded,
        title: 'Instant Dispense',
        description:
            'Equipped with advanced optical sensors to verify that items drop correctly every time you complete a transaction.',
      ),
      _FeatureItem(
        icon: Icons.autorenew_rounded,
        title: 'Auto-Refund Fail-safe',
        description:
            'If a snack gets stuck or fails to drop, our automated system registers it and initiates a quick refund request process.',
      ),
      _FeatureItem(
        icon: Icons.restaurant_menu_rounded,
        title: 'Curated Refreshments',
        description:
            'We load the best snacks: cold energy drinks, imported chocolates, potato chips, and healthy fruit bars.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 60,
      ),
      decoration: AppTheme.sectionDecoration(context),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const ScreenTitle(
                title: 'Smart Features of BiteBox 24/7',
                subtitle:
                    'Engineered for maximum reliability and customer satisfaction, keeping you fueled round-the-clock.',
                centerText: true,
              ),
              const SizedBox(height: 40),
              !isDesktop
                  ? SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: features.length,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, index) {
                          final feature = features[index];
                          return Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
                            decoration: AppTheme.cardDecoration(context).copyWith(
                              border: Border.all(
                                color: AppTheme.primary(context).withOpacity(0.18),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary(context).withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary(context).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      feature.icon,
                                      color: AppTheme.primary(context),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    feature.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      feature.description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, gridConstraints) {
                        final crossCount = gridConstraints.maxWidth >= 1000 ? 4 : 2;
                        final aspect = gridConstraints.maxWidth >= 1000 ? 0.8 : 1.0;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: aspect,
                          ),
                          itemCount: features.length,
                          itemBuilder: (context, index) {
                            final feature = features[index];
                            return Container(
                              decoration: AppTheme.cardDecoration(context),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        feature.icon,
                                        color: AppTheme.primary(context),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      feature.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Text(
                                        feature.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context, bool isDesktop) {
    final steps = [
      _StepItem(
        number: '01',
        title: 'Choose Vending Item',
        description: 'Browse the catalog on our bright touchscreen display.',
      ),
      _StepItem(
        number: '02',
        title: 'Scan QR / Pay',
        description:
            'Scan the UPI barcode generated directly on the machine screen.',
      ),
      _StepItem(
        number: '03',
        title: 'Grab and Enjoy',
        description:
            'Sensors verify the drop, the door unlocks, and your snack is ready!',
      ),
    ];

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
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
                title: 'How Easy Is It?',
                subtitle:
                    'No coins, no dollar bills, no hassle. Buy your snacks in under 15 seconds.',
                centerText: true,
              ),
              const SizedBox(height: 40),
              !isDesktop
                  ? Column(
                      children: List.generate(steps.length, (index) {
                        final step = steps[index];
                        final isLast = index == steps.length - 1;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary(context),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary(context).withOpacity(0.35),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      step.number,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2.5,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primary(context),
                                          AppTheme.secondary(context),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: AppTheme.accentCardDecoration(context).copyWith(
                                  border: Border.all(
                                    color: AppTheme.secondary(context).withOpacity(0.4),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      step.description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    )
                  : LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final isWide = sectionConstraints.maxWidth >= 980;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: steps.map((step) {
                            return Container(
                              width: isWide ? 300 : double.infinity,
                              margin: EdgeInsets.only(bottom: isWide ? 0 : 24),
                              padding: const EdgeInsets.all(24),
                              decoration: AppTheme.accentCardDecoration(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.number,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    step.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDesktop) {
    final stats = [
      _StatItem(value: '50+', label: 'Active Machines'),
      _StatItem(value: '10K+', label: 'Daily Happy Customers'),
      _StatItem(value: '150+', label: 'Products Stocked'),
      _StatItem(value: '4+', label: 'Districts Covered'),
    ];

    return Container(
      decoration: AppTheme.bannerDecoration(context),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 60,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'BiteBox in Numbers',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A fast-growing automated retail network providing convenience state-wide.',
                style: const TextStyle(fontSize: 15, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              !isDesktop
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                stat.value,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.secondary(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stat.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: stats.map((stat) {
                        return Container(
                          width: 220,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Text(
                                stat.value,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.secondary(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stat.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class InteractiveVendingMockup extends StatefulWidget {
  final bool isWide;
  const InteractiveVendingMockup({super.key, required this.isWide});

  @override
  State<InteractiveVendingMockup> createState() => _InteractiveVendingMockupState();
}

class _InteractiveVendingMockupState extends State<InteractiveVendingMockup> {
  int _selectedIndex = -1;
  bool _isPaying = false;
  bool _isDispensing = false;

  final List<Map<String, dynamic>> _mockSnacks = [
    {'name': 'Chilled Pepsi', 'price': '₹40', 'icon': Icons.local_drink_rounded},
    {'name': 'Choco Cookies', 'price': '₹30', 'icon': Icons.cookie_rounded},
    {'name': 'Mango Nectar', 'price': '₹35', 'icon': Icons.local_drink_outlined},
    {'name': 'Salted Chips', 'price': '₹20', 'icon': Icons.lunch_dining_rounded},
    {'name': 'Mineral Water', 'price': '₹20', 'icon': Icons.water_drop_rounded},
    {'name': 'Swiss Bar', 'price': '₹45', 'icon': Icons.brightness_7_rounded},
  ];

  void _selectItem(int index) {
    if (_isDispensing) return;
    setState(() {
      _selectedIndex = index;
      _isPaying = true;
      _isDispensing = false;
    });
  }

  void _simulatePayment() {
    if (!_isPaying || _isDispensing) return;
    setState(() {
      _isDispensing = true;
      _isPaying = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDispensing = false;
          _selectedIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = widget.isWide ? 260.0 : 220.0;
    final sizeHeight = widget.isWide ? 400.0 : 340.0;
    final primaryColor = AppTheme.primary(context);
    final accentColor = AppTheme.secondary(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.isWide ? 340 : 260,
            height: widget.isWide ? 340 : 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.12),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: sizeWidth,
            height: sizeHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _selectedIndex >= 0 ? primaryColor.withOpacity(0.6) : Colors.white.withOpacity(0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _selectedIndex >= 0 ? primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isDispensing ? Colors.orangeAccent : Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isDispensing
                              ? 'DISPENSING ITEM...'
                              : (_selectedIndex >= 0
                                  ? 'SCAN QR & PAY'
                                  : 'READY: BITEBOX 24/7'),
                          style: TextStyle(
                            color: _isDispensing
                                ? Colors.orangeAccent
                                : (_selectedIndex >= 0 ? accentColor : Colors.greenAccent),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _mockSnacks.length,
                      itemBuilder: (context, index) {
                        final snack = _mockSnacks[index];
                        final isItemSelect = _selectedIndex == index;

                        return GestureDetector(
                          onTap: () => _selectItem(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isItemSelect
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isItemSelect ? primaryColor : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  snack['icon'] as IconData,
                                  color: isItemSelect ? accentColor : Colors.white70,
                                  size: widget.isWide ? 22 : 18,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  snack['name'].toString().split(' ')[1],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  snack['price'].toString(),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedIndex >= 0
                      ? GestureDetector(
                          onTap: _simulatePayment,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isDispensing
                                  ? Colors.orangeAccent.withOpacity(0.15)
                                  : primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isDispensing ? Colors.orangeAccent : primaryColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    _isDispensing ? Icons.check_circle_rounded : Icons.qr_code_2_rounded,
                                    color: _isDispensing ? Colors.green : Colors.black,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isDispensing ? 'SUCCESS!' : _mockSnacks[_selectedIndex]['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isDispensing ? 'Dispensing treat...' : 'Click QR to simulate pay',
                                        style: TextStyle(
                                          color: _isDispensing ? Colors.orangeAccent : Colors.white70,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_rounded, color: Colors.white60, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'TAP AN ITEM TO VEND',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _StepItem {
  final String number;
  final String title;
  final String description;
  _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });
}

class _StatItem {
  final String value;
  final String label;
  _StatItem({required this.value, required this.label});
}
