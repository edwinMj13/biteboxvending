import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MainLayoutScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutScreen({super.key, required this.navigationShell});

  final List<_NavigationTabItem> _tabs = const [
    _NavigationTabItem(title: 'HOME', icon: Icons.home_rounded),
    _NavigationTabItem(title: 'FRANCHISE', icon: Icons.store_rounded),
    _NavigationTabItem(title: 'ADVERTISE', icon: Icons.ad_units_rounded),
    _NavigationTabItem(title: 'FIND US', icon: Icons.pin_drop_rounded),
    _NavigationTabItem(
      title: 'GET IN TOUCH',
      icon: Icons.contact_support_rounded,
    ),
    _NavigationTabItem(title: 'GALLERY', icon: Icons.photo_library_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = navigationShell.currentIndex;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      extendBody: !isDesktop,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withOpacity(0.85),
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primary(context).withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary(context).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'BITE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondary(context).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'BOX',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary(context).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.support_agent_rounded,
                      color: AppTheme.primary(context),
                      size: 22,
                    ),
                    onPressed: () {
                      navigationShell.goBranch(4);
                    },
                  ),
                ),
              ],
            )
          : null,
      body: isDesktop
          ? Column(
              children: [
                // Top Web Navbar
                _buildWebNavbar(context, ref, selectedIndex),
                // Main Panel Content
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: !isDesktop
          ? _buildMobileDock(context, ref, selectedIndex)
          : null,
    );
  }

  Widget _buildWebNavbar(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
  ) {
    return Container(
      height: 80,
      color: AppTheme.darkColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo Area
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BITEBOX',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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
                  fontSize: 15,
                ),
              ),
            ],
          ),

          // Menu Tabs List
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = selectedIndex == index;

              return _NavbarMenuItem(
                tab: tab,
                isSelected: isSelected,
                onTap: () {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              );
            }),
          ),

          // Right action bar (Theme + Helpline)
          Row(
            children: [
              // Theme Toggle Button
              InkWell(
                onTap: () {
                  final current = ref.read(themePresetProvider);
                  ref
                      .read(themePresetProvider.notifier)
                      .state = current == AppThemePreset.greenYellow
                      ? AppThemePreset.yellowGreen
                      : AppThemePreset.greenYellow;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: AppTheme.primary(context),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ref.watch(themePresetProvider) ==
                                AppThemePreset.greenYellow
                            ? "Green & Yellow"
                            : "Yellow & Green",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Support Helpline
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    color: AppTheme.primary(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '24/7 Helpline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+91 81290 37133',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDock(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
  ) {
    int dockIndex = 3; // Default is 'Menu' (represented by index 3)
    if (selectedIndex == 0) {
      dockIndex = 0;
    } else if (selectedIndex == 3) {
      dockIndex = 1;
    } else if (selectedIndex == 1) {
      dockIndex = 2;
    }

    final primaryColor = AppTheme.primary(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: dockIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _buildDockItem(
                  context,
                  icon: Icons.pin_drop_outlined,
                  activeIcon: Icons.pin_drop_rounded,
                  label: 'Locations',
                  isSelected: dockIndex == 1,
                  onTap: () => navigationShell.goBranch(3),
                ),
                _buildDockItem(
                  context,
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store_rounded,
                  label: 'Franchise',
                  isSelected: dockIndex == 2,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _buildDockItem(
                  context,
                  icon: Icons.menu_rounded,
                  activeIcon: Icons.menu_open_rounded,
                  label: 'Menu',
                  isSelected: dockIndex == 3,
                  onTap: () => _showMobileMenuSheet(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = AppTheme.primary(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? primaryColor : Colors.grey.shade600,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileMenuSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentTheme = ref.watch(themePresetProvider);
            final primaryColor = AppTheme.primary(context);

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: primaryColor.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore BiteBox',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      _buildMenuGridItem(
                        context,
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        color: primaryColor,
                        onTap: () {
                          Navigator.pop(context);
                          navigationShell.goBranch(5);
                        },
                      ),
                      _buildMenuGridItem(
                        context,
                        icon: Icons.ad_units_outlined,
                        label: 'Advertise',
                        color: AppTheme.secondary(context),
                        onTap: () {
                          Navigator.pop(context);
                          navigationShell.goBranch(2);
                        },
                      ),
                      _buildMenuGridItem(
                        context,
                        icon: Icons.contact_support_outlined,
                        label: 'Support',
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.pop(context);
                          navigationShell.goBranch(4);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.12),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, color: primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Theme Options',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Toggle active brand colors',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(themePresetProvider.notifier).state =
                                currentTheme == AppThemePreset.greenYellow
                                ? AppThemePreset.yellowGreen
                                : AppThemePreset.greenYellow;
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            currentTheme == AppThemePreset.greenYellow
                                ? 'Green/Yellow'
                                : 'Yellow/Green',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            color: AppTheme.primary(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '24/7 Smart Helpline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '+91 81290 37133',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            navigationShell.goBranch(4);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary(context),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuGridItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavbarMenuItem extends StatefulWidget {
  final _NavigationTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavbarMenuItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavbarMenuItem> createState() => _NavbarMenuItemState();
}

class _NavbarMenuItemState extends State<_NavbarMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.isSelected
        ? AppTheme.primary(context).withOpacity(0.12)
        : (_isHovered ? Colors.white.withOpacity(0.04) : Colors.transparent);

    final textColor = widget.isSelected
        ? AppTheme.primary(context)
        : (_isHovered ? Colors.white : Colors.white70);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: activeBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.tab.icon, color: textColor, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.tab.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationTabItem {
  final String title;
  final IconData icon;

  const _NavigationTabItem({required this.title, required this.icon});
}
