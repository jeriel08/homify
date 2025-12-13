import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

class FavoritesState {
  final Map<String, PropertyEntity> items;
  const FavoritesState({this.items = const {}});

  bool contains(String id) => items.containsKey(id);
  List<PropertyEntity> get values => items.values.toList(growable: false);
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  @override
  FavoritesState build() {
    _hydrate();
    return const FavoritesState();
  }

  Future<void> _hydrate() async {
    try {
      final auth = ref.read(authStateProvider);
      final uid = auth.value?.uid;
      if (uid == null) return;

      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();
      final Map<String, PropertyEntity> map = {};

      for (final doc in snap.docs) {
        final data = doc.data();
        map[doc.id] = PropertyEntity(
          id: data['property_id'] ?? doc.id,
          ownerUid: data['owner_uid'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          type: PropertyType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => PropertyType.bedspacer,
          ),
          rentChargeMethod: RentChargeMethod.values.firstWhere(
            (e) => e.name == data['rent_charge_method'],
            orElse: () => RentChargeMethod.perUnit,
          ),
          rentAmount: (data['rent_amount'] as num?)?.toDouble() ?? 0,
          amenities: List<String>.from(data['amenities'] ?? []),
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
          imageUrls: List<String>.from(data['image_urls'] ?? []),
          createdAt: DateTime.now(),
          isVerified: data['is_verified'] ?? false,
          favoritesCount: data['favorites_count'] ?? 0,
        );
      }
      if (map.isNotEmpty) {
        state = FavoritesState(items: map);
      }
    } catch (_) {
      // ignore hydration errors
    }
  }

  void toggle(PropertyEntity property) {
    final map = Map<String, PropertyEntity>.from(state.items);
    final wasFavorite = map.containsKey(property.id);
    if (wasFavorite) {
      map.remove(property.id);
    } else {
      map[property.id] = property;
    }
    state = FavoritesState(items: map);
    _persist(property, add: !wasFavorite);
  }

  void remove(String id) {
    if (!state.items.containsKey(id)) return;
    final removed = state.items[id];
    final map = Map<String, PropertyEntity>.from(state.items)..remove(id);
    state = FavoritesState(items: map);
    if (removed != null) {
      _persist(removed, add: false);
    }
  }

  Future<void> _persist(PropertyEntity property, {required bool add}) async {
    try {
      final auth = ref.read(authStateProvider);
      final uid = auth.value?.uid;
      if (uid == null) return;

      final batch = _db.batch();

      // 1. Update User's Favorites Collection
      final userFavDoc = _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(property.id);

      if (add) {
        batch.set(userFavDoc, {
          'property_id': property.id,
          'owner_uid': property.ownerUid,
          'name': property.name,
          'description': property.description,
          'type': property.type.name,
          'rent_charge_method': property.rentChargeMethod.name,
          'rent_amount': property.rentAmount,
          'amenities': property.amenities,
          'latitude': property.latitude,
          'longitude': property.longitude,
          'image_urls': property.imageUrls,
          'is_verified': property.isVerified,
          'favorites_count': property.favoritesCount, // Snapshot at time of fav
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        batch.delete(userFavDoc);
      }

      // 2. Update Property's Global Favorites Count
      final propertyDoc = _db.collection('properties').doc(property.id);
      batch.update(propertyDoc, {
        'favorites_count': FieldValue.increment(add ? 1 : -1),
      });

      await batch.commit();
    } catch (e) {
      // Revert state if persistence fails?
      // For now, just log or ignore as per original code
      // debugPrint('Error updating favorites: $e');
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  () {
    return FavoritesNotifier();
  },
);
