import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/home/presentation/widgets/property_carousel.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  // DUMMY DATA: Replace this with ref.watch(homeFeedProvider) later
  final List<PropertyEntity> dummyProperties = [
    PropertyEntity(
      id: '1',
      ownerUid: 'owner1',
      name: 'Modern Studio in Poblacion',
      description: 'Desc',
      type: PropertyType.apartment,
      rentChargeMethod: RentChargeMethod.perUnit,
      rentAmount: 8500,
      amenities: [],
      latitude: 0,
      longitude: 0,
      imageUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
      ],
      createdAt: DateTime.now(),
      isVerified: true,
      favoritesCount: 12,
    ),
    PropertyEntity(
      id: '2',
      ownerUid: 'owner2',
      name: 'Cozy Bedspacer for Students',
      description: 'Desc',
      type: PropertyType.bedspacer,
      rentChargeMethod: RentChargeMethod.perBed,
      rentAmount: 2500,
      amenities: [],
      latitude: 0,
      longitude: 0,
      imageUrls: ['https://images.unsplash.com/photo-1555854877-bab0e564b8d5'],
      createdAt: DateTime.now(),
      isVerified: true,
      favoritesCount: 5,
    ),
    PropertyEntity(
      id: '3',
      ownerUid: 'owner2',
      name: 'Cozy Bedspacer for Students',
      description: 'Desc',
      type: PropertyType.bedspacer,
      rentChargeMethod: RentChargeMethod.perBed,
      rentAmount: 2500,
      amenities: [],
      latitude: 0,
      longitude: 0,
      imageUrls: ['https://images.unsplash.com/photo-1555854877-bab0e564b8d5'],
      createdAt: DateTime.now(),
      isVerified: true,
      favoritesCount: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Using the colors from your typography file or pending card
    const primaryColor = Color(0xFFE05725);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            80,
          ), // Bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Where do you want to live?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const Gap(24),

              // 2. Near You Carousel
              _buildHeader(context, "Near You"),
              const Gap(16),
              PropertyCarousel(properties: dummyProperties),

              const Gap(24),

              // 3. You Might Like Feed
              _buildHeader(context, "You might like"),
              const Gap(16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dummyProperties.length,
                itemBuilder: (context, index) {
                  final property = dummyProperties[index];
                  return TenantPropertyCard(
                    property: property,
                    isFavorite: false, // TODO: Hook up to riverpod provider
                    onFavorite: () {
                      // TODO: Toggle favorite logic
                    },
                    onTap: () {
                      // TODO: Go to details page
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

  Widget _buildHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF32190D),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              color: Color(0xFFE05725),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
