import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/content/content_providers.dart';
import '../../../../core/content/site_content_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class FindUsScreen extends ConsumerStatefulWidget {
  const FindUsScreen({super.key});

  @override
  ConsumerState<FindUsScreen> createState() => _FindUsScreenState();
}

class _FindUsScreenState extends ConsumerState<FindUsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Machines are managed from the admin portal ("Machine Locations" tab).
  List<MachineLocation> _filter(List<MachineLocation> allLocations) {
    if (_searchQuery.isEmpty) return allLocations;
    final query = _searchQuery.toLowerCase();
    return allLocations.where((loc) {
      return loc.name.toLowerCase().contains(query) ||
          loc.district.toLowerCase().contains(query) ||
          loc.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final machines = ref.watch(machinesProvider);
    final allLocations = machines.valueOrNull ?? const <MachineLocation>[];
    final filteredLocations = _filter(allLocations);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner
          _buildBannerSection(isDesktop),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 20,
              vertical: 60,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenTitle(
                      title: 'Find A Vending Unit',
                      subtitle:
                          'Locate the nearest BiteBox unit and view live restocking statuses.',
                    ),
                    const SizedBox(height: 32),

                    // Search & Filters Bar
                    _buildSearchBar(isDesktop),
                    const SizedBox(height: 32),

                    // Grid / List
                    machines.isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : allLocations.isEmpty
                        ? _buildNoResults(
                            title: 'No Vending Machines Yet',
                            message: 'Machine locations will appear here soon.',
                          )
                        : filteredLocations.isEmpty
                        ? _buildNoResults(
                            title: 'No Vending Machines Found',
                            message:
                                'Try searching for another keyword or district.',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width >= 600 ? 2 : 1),
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: filteredLocations.length,
                            itemBuilder: (context, index) {
                              return _buildLocationCard(
                                filteredLocations[index],
                              );
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

  Widget _buildBannerSection(bool isDesktop) {
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
                'FIND US NOW',
                style: TextStyle(
                  color: AppTheme.secondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Interactive Machine Locator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      width: isDesktop ? 400 : double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by campus, city, tower...',
          prefixIcon: Icon(Icons.search, color: AppTheme.primary(context)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primary(context), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(MachineLocation loc) {
    final statusText = loc.status.label;
    final Color statusColor = switch (loc.status) {
      MachineStatus.stocked => Colors.green,
      MachineStatus.lowStock => Colors.amber.shade700,
      MachineStatus.offline => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    loc.district,
                    style: TextStyle(
                      color: AppTheme.primary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              loc.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                loc.address,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📍 ${loc.landmark}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults({required String title, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
