import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/content_providers.dart';
import '../admin_config.dart';
import '../admin_theme.dart';
import '../sections/contact_details_section.dart';
import '../sections/enquiries_section.dart';
import '../sections/home_stats_section.dart';
import '../sections/machines_section.dart';

/// Admin home: one tab per editable part of the public website.
/// To add a new editable section, create a widget in lib/admin/sections/
/// and add it to [_tabs].
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _AdminTab(
      'Contact Details',
      'Contact',
      'Phone, WhatsApp, emails, address and social links shown on the website.',
      Icons.contact_phone_outlined,
      ContactDetailsSection(),
    ),
    _AdminTab(
      'Home Numbers',
      'Numbers',
      'The "BiteBox in Numbers" figures on the home page.',
      Icons.insights_rounded,
      HomeStatsSection(),
    ),
    _AdminTab(
      'Machine Locations',
      'Machines',
      'Vending machines listed on the Find Us page.',
      Icons.storefront_outlined,
      MachinesSection(),
    ),
    _AdminTab(
      'Franchise Enquiries',
      'Enquiries',
      'Enquiries sent from the Franchise page, newest first.',
      Icons.inbox_outlined,
      EnquiriesSection(),
    ),
  ];

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final tab = _tabs[_selectedIndex];
    final enquiryCount =
        ref.watch(enquiriesProvider).valueOrNull?.length ?? 0;

    final badges = {3: enquiryCount};

    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 40 : 16,
        isDesktop ? 32 : 16,
        isDesktop ? 40 : 16,
        // Leave room for the floating bottom dock on mobile.
        isDesktop ? 40 : 120,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isDesktop) ...[
                Text(
                  tab.subtitle,
                  style: const TextStyle(color: AdminColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],
              if (isDesktop) ...[
                Text(
                  tab.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tab.subtitle,
                  style: const TextStyle(color: AdminColors.muted),
                ),
                const SizedBox(height: 28),
              ],
              // Keyed so each tab gets fresh state when switching.
              KeyedSubtree(key: ValueKey(_selectedIndex), child: tab.child),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 260,
              child: _Sidebar(
                tabs: _tabs,
                selectedIndex: _selectedIndex,
                badges: badges,
                onSelect: _select,
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Mobile: frosted top bar + floating bottom dock, like the public site.
    return Scaffold(
      extendBody: true,
      appBar: _MobileTopBar(title: tab.title),
      body: content,
      bottomNavigationBar: _MobileDock(
        tabs: _tabs,
        selectedIndex: _selectedIndex,
        badges: badges,
        onSelect: _select,
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _MobileTopBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AdminColors.background.withValues(alpha: 0.88),
              border: Border(
                bottom: BorderSide(
                  color: AdminColors.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AdminColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BITEBOX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AdminColors.danger.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Sign out',
            icon: const Icon(
              Icons.logout_rounded,
              color: AdminColors.danger,
              size: 20,
            ),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ),
      ],
    );
  }
}

/// Floating rounded tab bar, matching the public site's mobile dock.
class _MobileDock extends StatelessWidget {
  final List<_AdminTab> tabs;
  final int selectedIndex;
  final Map<int, int> badges;
  final ValueChanged<int> onSelect;

  const _MobileDock({
    required this.tabs,
    required this.selectedIndex,
    required this.badges,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AdminColors.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AdminColors.sidebar.withValues(alpha: 0.12),
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
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    _DockItem(
                      tab: tabs[i],
                      selected: i == selectedIndex,
                      badge: badges[i] ?? 0,
                      onTap: () => onSelect(i),
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

class _DockItem extends StatelessWidget {
  final _AdminTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _DockItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AdminColors.primaryDark : AdminColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AdminColors.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(tab.icon, color: color, size: 22),
                ),
                if (badge > 0)
                  Positioned(
                    right: 6,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: AdminColors.accent,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tab.shortTitle,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<_AdminTab> tabs;
  final int selectedIndex;
  final Map<int, int> badges;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.badges,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BITEBOX',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'MANAGE WEBSITE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (var i = 0; i < tabs.length; i++)
              _SidebarItem(
                tab: tabs[i],
                selected: i == selectedIndex,
                badge: badges[i] ?? 0,
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AdminColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          AdminConfig.allowedPhones.first,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _AdminTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? AdminColors.primary.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AdminColors.sidebarHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  tab.icon,
                  size: 20,
                  color: selected ? AdminColors.primary : Colors.white60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tab.title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminTab {
  final String title;
  final String shortTitle; // Label under the mobile dock icon
  final String subtitle;
  final IconData icon;
  final Widget child;
  const _AdminTab(
    this.title,
    this.shortTitle,
    this.subtitle,
    this.icon,
    this.child,
  );
}
