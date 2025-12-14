import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/core/services/places_service.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/home/presentation/providers/explorer_provider.dart';
import 'package:homify/features/home/presentation/providers/bottom_nav_provider.dart';
import 'package:homify/features/home/presentation/widgets/explore_property_details_sheet.dart';
import 'package:homify/features/home/presentation/widgets/property_info_card.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;

  // Custom Info Window controller
  final CustomInfoWindowController _infoWindowController =
      CustomInfoWindowController();

  // Search state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<_SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Bottom sheet state - only show when user taps info card
  bool _showBottomSheet = false;
  PropertyEntity? _selectedForBottomSheet;

  // Route/Direction state
  Set<Polyline> _routePolylines = {};
  bool _isLoadingRoute = false; // Loading state for direction

  // Selected marker state for highlighting
  String? _selectedMarkerId;

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _infoWindowController.dispose();
    super.dispose();
  }

  /// Handle direction button tap - fetch route and show polyline
  Future<void> _handleDirectionTap() async {
    if (_selectedForBottomSheet == null) return;

    final property = _selectedForBottomSheet!;

    // Show loading indicator
    setState(() => _isLoadingRoute = true);

    // Get user's current location
    final currentPos = await LocationService.getCurrentPosition();
    if (currentPos == null) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ToastHelper.error(context, 'Could not get your current location');
      }
      return;
    }

    // Fetch route from Geoapify
    final routePoints = await PlacesService.getRoute(
      originLat: currentPos.latitude,
      originLon: currentPos.longitude,
      destLat: property.latitude,
      destLon: property.longitude,
    );

    if (routePoints.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ToastHelper.error(context, 'Could not find route');
      }
      return;
    }

    // Create polyline
    final polyline = Polyline(
      polylineId: const PolylineId('direction_route'),
      color: primary,
      width: 5,
      points: routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
    );

    if (mounted) {
      setState(() {
        _routePolylines = {polyline};
        _isLoadingRoute = false; // Clear loading state
      });

      // Zoom to show the route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(
            routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          ),
          50,
        ),
      );
    }
  }

  /// Calculate LatLngBounds from a list of LatLng points
  LatLngBounds _boundsFromLatLngList(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;
    for (final point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty || query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);

      final results = <_SearchResult>[];

      // 1. Search in properties
      final exploreState = ref.read(exploreProvider);
      final propertyMatches = _searchProperties(query, exploreState.properties);
      results.addAll(propertyMatches);

      // 2. Search via Geoapify
      final placePredictions = await PlacesService.getAutocompletePredictions(
        query,
      );
      for (final place in placePredictions) {
        results.add(
          _SearchResult(
            type: _SearchResultType.place,
            title: place.mainText,
            subtitle: place.secondaryText,
            latitude: place.latitude,
            longitude: place.longitude,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  List<_SearchResult> _searchProperties(
    String query,
    List<PropertyEntity> properties,
  ) {
    final lowerQuery = query.toLowerCase();
    final results = <_SearchResult>[];

    for (final property in properties) {
      if (property.name.toLowerCase().contains(lowerQuery)) {
        results.add(
          _SearchResult(
            type: _SearchResultType.property,
            title: property.name,
            subtitle: '₱${property.rentAmount.toStringAsFixed(0)} / month',
            latitude: property.latitude,
            longitude: property.longitude,
            markerId: property.id,
          ),
        );
      }
    }

    return results;
  }

  void _onResultSelected(_SearchResult result) {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchResults = [];
      _searchController.text = result.title;
      _selectedMarkerId = result.markerId; // Track selected marker
    });

    if (result.latitude != null && result.longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(result.latitude!, result.longitude!),
          16,
        ),
      );
    }

    // If it's a property, show the info window
    if (result.type == _SearchResultType.property && result.markerId != null) {
      final exploreState = ref.read(exploreProvider);

      // Find the property by ID
      PropertyEntity? property;
      try {
        property = exploreState.properties.firstWhere(
          (p) => p.id == result.markerId,
        );
      } catch (e) {
        // Property not found
        return;
      }

      // Show info window for this property
      _infoWindowController.addInfoWindow!(
        PropertyInfoCard(
          property: property,
          onTap: () {
            _infoWindowController.hideInfoWindow!();
            setState(() {
              _showBottomSheet = true;
              _selectedForBottomSheet = property;
            });
            ref.read(bottomNavVisibilityProvider.notifier).state = false;
          },
          onClose: () {
            _infoWindowController.hideInfoWindow!();
            setState(() => _selectedMarkerId = null);
          },
        ),
        LatLng(property.latitude, property.longitude),
      );
    }
  }

  // Create markers with custom info window
  Set<Marker> _createMarkersWithInfoWindow(List<PropertyEntity> properties) {
    return properties.map((property) {
      final isSelected = _selectedMarkerId == property.id;

      return Marker(
        markerId: MarkerId(property.id),
        position: LatLng(property.latitude, property.longitude),
        // Dynamic marker color - selected shows blue, unselected shows red
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          // Set selected marker for highlighting
          setState(() => _selectedMarkerId = property.id);

          // Show custom info window above marker
          _infoWindowController.addInfoWindow!(
            PropertyInfoCard(
              property: property,
              onTap: () {
                // User tapped info card - show bottom sheet
                _infoWindowController.hideInfoWindow!();
                setState(() {
                  _showBottomSheet = true;
                  _selectedForBottomSheet = property;
                });
                ref.read(bottomNavVisibilityProvider.notifier).state = false;
              },
              onClose: () {
                _infoWindowController.hideInfoWindow!();
                setState(() => _selectedMarkerId = null);
              },
            ),
            LatLng(property.latitude, property.longitude),
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final exploreState = ref.watch(exploreProvider);

    if (exploreState.isLoading && exploreState.initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exploreState.errorMessage != null &&
        exploreState.initialPosition == null) {
      return Center(child: Text('Error: ${exploreState.errorMessage}'));
    }

    // Listen for error messages
    ref.listen(exploreProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        ToastHelper.error(context, next.errorMessage!);
      }
    });

    // Get properties from provider to build markers with info window
    final properties = exploreState.properties;
    final markersWithInfoWindow = _createMarkersWithInfoWindow(properties);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard from pushing up UI
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  exploreState.initialPosition ??
                  const LatLng(14.5995, 120.9842),
              zoom: 14.0,
            ),
            markers: markersWithInfoWindow,
            polylines: {...exploreState.polylines, ..._routePolylines},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            padding: const EdgeInsets.only(bottom: 70, top: 80),
            onMapCreated: (controller) {
              _mapController = controller;
              _infoWindowController.googleMapController = controller;
            },
            onCameraMove: (position) {
              _infoWindowController.onCameraMove!();
            },
            onTap: (_) {
              _infoWindowController.hideInfoWindow!();
              setState(() {
                _searchResults = [];
                _showBottomSheet = false;
                _selectedForBottomSheet = null;
                _routePolylines = {}; // Clear route when tapping away
                _selectedMarkerId = null; // Reset marker selection
              });
              FocusScope.of(context).unfocus();
              ref.read(bottomNavVisibilityProvider.notifier).state = true;
            },
          ),

          // Custom Info Window overlay
          CustomInfoWindow(
            controller: _infoWindowController,
            height: 100,
            width: 280,
            offset: 50,
          ),

          // Route Loading Progress Bar
          if (_isLoadingRoute)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: surface.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),

          // Search Bar - at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Search Results Dropdown
          if (_searchResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                onTapDown: (_) {},
                behavior: HitTestBehavior.opaque,
                child: _buildSearchResults(),
              ),
            ),

          // My Location Button - hidden when modal sheet is active
          if (!_showBottomSheet)
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'my_location_explore',
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black),
                onPressed: () {
                  if (_mapController != null &&
                      exploreState.initialPosition != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLng(exploreState.initialPosition!),
                    );
                  }
                },
              ),
            ),

          // Property Details Sheet - only shows when user taps info card
          if (_showBottomSheet && _selectedForBottomSheet != null)
            ExplorePropertyDetailsSheet(
              property: _selectedForBottomSheet!,
              onClose: () {
                setState(() {
                  _showBottomSheet = false;
                  _selectedForBottomSheet = null;
                  _routePolylines = {}; // Clear route when closing
                });
                ref.read(bottomNavVisibilityProvider.notifier).state = true;
              },
              onDirectionTap: _handleDirectionTap,
            ),

          // Loading indicator
          if (exploreState.isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search properties or places...',
          hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
          prefixIcon: Icon(LucideIcons.search, color: textSecondary, size: 20),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(LucideIcons.x, color: textSecondary, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(color: textPrimary, fontSize: 14),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            final isProperty = result.type == _SearchResultType.property;

            return InkWell(
              onTap: () => _onResultSelected(result),
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(12) : Radius.zero,
                bottom: index == _searchResults.length - 1
                    ? const Radius.circular(12)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isProperty
                            ? primary.withValues(alpha: 0.15)
                            : surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isProperty ? LucideIcons.house : LucideIcons.mapPin,
                        color: primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              if (isProperty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Property',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  result.title,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (result.subtitle.isNotEmpty)
                            Text(
                              result.subtitle,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Helper classes for search results
enum _SearchResultType { property, place }

class _SearchResult {
  final _SearchResultType type;
  final String title;
  final String subtitle;
  final double? latitude;
  final double? longitude;
  final String? markerId;

  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    this.latitude,
    this.longitude,
    this.markerId,
  });
}
