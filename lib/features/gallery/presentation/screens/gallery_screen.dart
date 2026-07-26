import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  final List<_GalleryImageItem> _items = const [
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.34.jpeg',
      title: 'Teal Machine Front View',
      description: 'Modern vending layout offering premium snacks and beverages.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.34 (1).jpeg',
      title: 'Smart Vending Terminal',
      description: 'Sleek interface and payment display for a smooth checkout process.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.35.jpeg',
      title: 'Restocked Beverage Grid',
      description: 'Fresh sodas, juices, and cold water ready for instant dispensing.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.35 (1).jpeg',
      title: 'Cashless Payment Terminal',
      description: 'UPI and card checkout options for rapid vending purchases.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.35 (2).jpeg',
      title: 'BiteBox Double Unit Setup',
      description: 'Expanded capacity installation offering dual snack and drink shelves.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.35 (3).jpeg',
      title: 'Campus Lounge Install',
      description: 'A popular spot for college students to refuel between lectures.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.36.jpeg',
      title: 'BiteBox Mini Unit',
      description: 'Compact footprint design suited for tight office and corridor spaces.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.36 (1).jpeg',
      title: 'Restocking Process',
      description: 'Operators carefully replenishing the system with fresh, quality snacks.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.36 (2).jpeg',
      title: 'Digital Vending Terminal',
      description: 'Interactive high-contrast display panel for simple snack selection.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.48.36 (3).jpeg',
      title: 'Tech Park Installation',
      description: 'Convenient automated retail options in Kochi Infopark corridors.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 12.59.53.jpeg',
      title: 'Lulu Cyber Tower Launch',
      description: 'Inaugurating a new smart vending point for corporate employees.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 13.00.17.jpeg',
      title: 'Corridor Vending Access',
      description: 'Easily accessible smart snacks in high-traffic campus walkways.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 13.00.18.jpeg',
      title: 'BiteBox Metro Station Install',
      description: 'Providing quick energy snacks for passengers on the go.',
    ),
    _GalleryImageItem(
      assetPath: 'assets/gallery_images/WhatsApp Image 2026-06-20 at 13.00.18 (1).jpeg',
      title: 'Corporate Cafe Spot',
      description: 'Deploying automated canteen options for late-night office work.',
    ),
  ];

  void _showImageDialog(BuildContext context, _GalleryImageItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final primaryColor = AppTheme.primary(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: AppTheme.darkColor(context),
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(color: Colors.white.withOpacity(0.12)),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         item.title,
              //         style: TextStyle(
              //           color: AppTheme.primary(context),
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //       Text(
              //         item.description,
              //         style: const TextStyle(
              //           color: Colors.white70,
              //           fontSize: 13,
              //           height: 1.4,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner
          _buildBannerSection(context, isDesktop),

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
                      title: 'Our Gallery',
                      subtitle:
                          'A visual look at BiteBox installations, launches, and customer engagement across campuses and offices.',
                      centerText: true,
                    ),
                    const SizedBox(height: 48),

                    // Grid Layout for Images
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildImageCard(context, item);
                      },
                    ),
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
                'GALLERY AND CLIPS',
                style: TextStyle(
                  color: AppTheme.primary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'BiteBox In Action',
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

  Widget _buildImageCard(BuildContext context, _GalleryImageItem item) {
    final primaryColor = AppTheme.primary(context);
    return Container(
      decoration: AppTheme.cardDecoration(context).copyWith(
        border: Border.all(
          color: primaryColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showImageDialog(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         item.title,
            //         style: const TextStyle(
            //           fontSize: 15,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.black87,
            //         ),
            //       ),
            //       const SizedBox(height: 6),
            //       Text(
            //         item.description,
            //         style: const TextStyle(
            //           fontSize: 11,
            //           color: Colors.black54,
            //           height: 1.4,
            //         ),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //       const SizedBox(height: 10),
            //       Row(
            //         children: [
            //           Icon(Icons.zoom_in_rounded, size: 14, color: primaryColor),
            //           const SizedBox(width: 4),
            //           Text(
            //             'Click to view',
            //             style: TextStyle(
            //               fontSize: 10,
            //               fontWeight: FontWeight.bold,
            //               color: primaryColor,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _GalleryImageItem {
  final String assetPath;
  final String title;
  final String description;

  const _GalleryImageItem({
    required this.assetPath,
    required this.title,
    required this.description,
  });
}
