import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class FindUsScreen extends StatefulWidget {
  const FindUsScreen({super.key});

  @override
  State<FindUsScreen> createState() => _FindUsScreenState();
}

class _FindUsScreenState extends State<FindUsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_MachineLocation> _allLocations = [
    _MachineLocation(
      id: 'CB-EKM-01',
      name: 'BiteBox Max #01',
      district: 'Ernakulam',
      address: 'Lulu Cyber Tower 1, Ground Floor Lobby, Infopark',
      landmark: 'Near elevators',
      status: _MachineStatus.stocked,
      latLng: '9.9833,76.3500',
    ),
    _MachineLocation(
      id: 'CB-EKM-02',
      name: 'BiteBox Mini #12',
      district: 'Ernakulam',
      address: 'CUSAT Campus, Science Faculty block block A',
      landmark: 'Next to library entry',
      status: _MachineStatus.stocked,
      latLng: '10.0438,76.3244',
    ),
    _MachineLocation(
      id: 'CB-EKM-03',
      name: 'BiteBox Max #08',
      district: 'Ernakulam',
      address: 'Aster Medcity, South Block Waiting Hall',
      landmark: 'Beside cafeteria entrance',
      status: _MachineStatus.lowStock,
      latLng: '10.0631,76.2731',
    ),
    _MachineLocation(
      id: 'CB-CLT-01',
      name: 'BiteBox Max #03',
      district: 'Calicut',
      address: 'UL Cyberpark, Main Entrance Lobby, Nellikode',
      landmark: 'Adjacent to reception desk',
      status: _MachineStatus.stocked,
      latLng: '11.2618,75.8361',
    ),
    _MachineLocation(
      id: 'CB-CLT-02',
      name: 'BiteBox Slim #04',
      district: 'Calicut',
      address: 'NIT Calicut, Mechanical Eng. Dept Lounge',
      landmark: 'Beside student notice board',
      status: _MachineStatus.offline,
      latLng: '11.3216,75.9336',
    ),
    _MachineLocation(
      id: 'CB-KTM-01',
      name: 'BiteBox Mini #06',
      district: 'Kottayam',
      address: 'CMS College, Science Block Corridor',
      landmark: 'Under the main central dome lobby',
      status: _MachineStatus.stocked,
      latLng: '9.5935,76.5186',
    ),
    _MachineLocation(
      id: 'CB-TVM-01',
      name: 'BiteBox Max #05',
      district: 'Thiruvananthapuram',
      address: 'Nila Building Ground Floor, Technopark Phase 1',
      landmark: 'Next to bank ATM lobby',
      status: _MachineStatus.stocked,
      latLng: '8.5566,76.8821',
    ),
    _MachineLocation(
      id: 'CB-TVM-02',
      name: 'BiteBox Max #09',
      district: 'Thiruvananthapuram',
      address: 'Ganga Building Lobby, Technopark Phase 3',
      landmark: 'Near the food court stairs',
      status: _MachineStatus.stocked,
      latLng: '8.5492,76.8837',
    ),
    _MachineLocation(
      id: 'CB-TVM-03',
      name: 'BiteBox Mini #15',
      district: 'Thiruvananthapuram',
      address: 'Kerala Government Secretariat, South Block Main Corridor',
      landmark: 'Near the visitor waiting area',
      status: _MachineStatus.stocked,
      latLng: '8.5009,76.9507',
    ),
  ];

  List<_MachineLocation> get _filteredLocations {
    if (_searchQuery.isEmpty) return _allLocations;
    final query = _searchQuery.toLowerCase();
    return _allLocations.where((loc) {
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
                    _filteredLocations.isEmpty
                        ? _buildNoResults()
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
                            itemCount: _filteredLocations.length,
                            itemBuilder: (context, index) {
                              return _buildLocationCard(
                                _filteredLocations[index],
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

  Widget _buildLocationCard(_MachineLocation loc) {
    Color statusColor;
    String statusText;

    switch (loc.status) {
      case _MachineStatus.stocked:
        statusColor = Colors.green;
        statusText = 'Online & Stocked';
        break;
      case _MachineStatus.lowStock:
        statusColor = Colors.amber.shade700;
        statusText = 'Low Stock';
        break;
      case _MachineStatus.offline:
        statusColor = Colors.red;
        statusText = 'Maintenance';
        break;
    }

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

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Vending Machines Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for another keyword or district.',
            style: TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

enum _MachineStatus { stocked, lowStock, offline }

class _MachineLocation {
  final String id;
  final String name;
  final String district;
  final String address;
  final String landmark;
  final _MachineStatus status;
  final String latLng;

  _MachineLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.landmark,
    required this.status,
    required this.latLng,
  });
}
