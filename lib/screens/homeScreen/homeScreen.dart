import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innerspace_coworking/screens/booking/bookingScreen.dart';
import 'package:provider/provider.dart';
import 'package:innerspace_coworking/constatnt/colors.dart';
import 'package:innerspace_coworking/screens/homeScreen/widget/amenitiesCard.dart';
import 'package:innerspace_coworking/screens/mapScreen.dart';
import 'package:innerspace_coworking/screens/booking/myBookingScreen.dart';
import 'package:innerspace_coworking/screens/notification/notificationScreen.dart';

import '../../models/branchModel.dart';
import '../../providers/branch_provider.dart';
import 'branchDetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchC = TextEditingController();
  RangeValues _priceRange = const RangeValues(50, 500);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Fetch branches when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BranchProvider>().fetchBranches();
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 19, 12, 26),
              Color.fromARGB(255, 79, 80, 84),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            _buildModernHeader(),

            // Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Category Tabs
                    _buildCategoryTabs(),

                    // Quick Filters
                    Consumer<BranchProvider>(
                      builder: (context, provider, child) {
                        return _QuickFilters(
                          cities: provider.cities,
                          selectedCity: provider.selectedCity,
                          onCitySelected: (city) => provider.selectCity(city),
                          showOnlyUnder200: provider.showOnlyUnder200,
                          onToggleUnder200: (value) =>
                              provider.toggleUnder200(value),
                          onClear: () {
                            provider.clearFilters();
                            _priceRange = const RangeValues(50, 500);
                            _searchC.clear();
                          },
                        );
                      },
                    ),

                    // Spaces List
                    Expanded(
                      child: Consumer<BranchProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF667eea),
                              ),
                            );
                          }

                          if (provider.error.isNotEmpty) {
                            return _ErrorState(
                              error: provider.error,
                              onRetry: () => provider.fetchBranches(),
                            );
                          }

                          final filteredBranches = provider.filteredBranches;

                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: filteredBranches.isEmpty
                                  ? _EmptyState(
                                      onReset: () {
                                        provider.clearFilters();
                                        _searchC.clear();
                                        _priceRange =
                                            const RangeValues(50, 500);
                                      },
                                    )
                                  : RefreshIndicator(
                                      onRefresh: () => provider.fetchBranches(),
                                      color: const Color(0xFF667eea),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 24),
                                        itemCount: filteredBranches.length,
                                        itemBuilder: (context, i) {
                                          final branch = filteredBranches[i];
                                          return AnimatedContainer(
                                            duration: Duration(
                                                milliseconds: 200 + (i * 100)),
                                            curve: Curves.easeOutBack,
                                            child: _BranchCard(
                                              branch: branch,
                                              key: ValueKey(branch.id),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          );
                        },
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

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 19, 12, 26),
            Color.fromARGB(255, 79, 80, 84),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // Logo and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image(
                        image: AssetImage(
                            "assets/coworkingLogo-removebg-preview.png"),
                        color: Colors.white,
                      )),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationsScreen()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login reqered...!")),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Location',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'New York, USA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Consumer<BranchProvider>(
                        builder: (context, provider, child) {
                          return TextField(
                            controller: _searchC,
                            onChanged: (value) =>
                                provider.setSearchQuery(value),
                            decoration: InputDecoration(
                              hintText: 'Search Here',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              suffixIcon: _searchC.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchC.clear();
                                        provider.setSearchQuery('');
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.grey[500],
                                        size: 18,
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: _openFilterSheet,
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['All', 'Hot Desk', 'Private Office', 'Meeting Room'];
    int selectedIndex = 0;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? ColorsData.primaryColor : Colors.white,
              elevation: isSelected ? 4 : 2,
              shadowColor: isSelected
                  ? const Color(0xFF667eea).withOpacity(0.3)
                  : Colors.black12,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() {}),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<BranchProvider>(
          builder: (context, provider, child) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: ColorsData.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Filters',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // City Filter
                        Text(
                          'City',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: 'Any',
                              isSelected: provider.selectedCity == null,
                              onTap: () => provider.selectCity(null),
                            ),
                            ...provider.cities.map((c) => _FilterChip(
                                  label: c,
                                  isSelected: provider.selectedCity == c,
                                  onTap: () => provider.selectCity(c),
                                )),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Price Range
                        Text(
                          'Price per hour',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: ColorsData.primaryColor,
                            thumbColor: ColorsData.primaryColor,
                            overlayColor:
                                const Color(0xFF667eea).withOpacity(0.2),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            labels: RangeLabels(
                              '₹${_priceRange.start.toStringAsFixed(0)}',
                              '₹${_priceRange.end.toStringAsFixed(0)}',
                            ),
                            onChanged: (v) {
                              setModalState(() => _priceRange = v);
                              provider.setMaxPrice(v.end);
                            },
                          ),
                        ),

                        // Under 200 Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Show only under ₹200/hr',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Switch(
                                value: provider.showOnlyUnder200,
                                onChanged: (v) => provider.toggleUnder200(v),
                                activeColor: const Color(0xFF667eea),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  provider.clearFilters();
                                  setModalState(() {
                                    _priceRange = const RangeValues(50, 500);
                                  });
                                  _searchC.clear();
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsData.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: isSelected ? ColorsData.primaryColor : Colors.grey[100],
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;
  final bool showOnlyUnder200;
  final ValueChanged<bool> onToggleUnder200;
  final VoidCallback onClear;

  const _QuickFilters({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.showOnlyUnder200,
    required this.onToggleUnder200,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ChipButton(
                    icon: Icons.location_city,
                    label: selectedCity ?? 'City: Any',
                    onTap: () => _showCityPicker(context),
                  ),
                  const SizedBox(width: 8),
                  _ChipToggle(
                    label: '≤ ₹200/hr',
                    value: showOnlyUnder200,
                    onChanged: onToggleUnder200,
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose city',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.all_inclusive, size: 20),
                ),
                title: const Text('Any'),
                onTap: () => Navigator.pop(context, null),
              ),
              ...cities.map((c) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: ColorsData.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(c),
                    onTap: () => Navigator.pop(context, c),
                  )),
            ],
          ),
        ),
      ),
    );

    onCitySelected(choice);
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF667eea)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ChipToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: value ? ColorsData.primaryColor : Colors.white,
      elevation: 2,
      shadowColor:
          value ? const Color(0xFF667eea).withOpacity(0.3) : Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: value ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchModel branch;

  const _BranchCard({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BranchDetailsScreen(branch: branch),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        branch.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF667eea),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[100],
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Price tag
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${branch.pricePerHour}/hr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // Favorite button
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Branch name
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      branch.city,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      branch.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Amenities
                    AmenitiesCard(amenites: branch.amenities),

                    const SizedBox(height: 16),

                    // Book button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BookingScreen(branch: branch)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login reqered...!")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsData.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF667eea).withOpacity(0.3),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No spaces found",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
