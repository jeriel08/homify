import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/features/properties/data/models/property_model.dart';

// -------------------------------------------------------------------
// 1. The Abstract Class (The "Contract")
// -------------------------------------------------------------------
abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getAdminStats();
  Future<List<ChartData>> getGraphData(String filter);
  Stream<List<PropertyModel>> getPendingPropertiesStream();
  Stream<List<PropertyModel>> getAllPropertiesStream();
  Stream<List<UserModel>> getAllUsersStream();
}

// -------------------------------------------------------------------
// 2. The Implementation (The "Worker")
// -------------------------------------------------------------------
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  // We'll need our collection names
  late final CollectionReference _userCollection;
  late final CollectionReference _propertyCollection;

  AdminRemoteDataSourceImpl(this._firestore) {
    _userCollection = _firestore.collection('users');
    _propertyCollection = _firestore.collection('properties');
  }

  /// Fetches all KPI card statistics in parallel
  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      // We use .count() for extreme efficiency.
      // This is 4 document reads, not thousands.
      final pendingQuery = _propertyCollection
          .where('is_verified', isEqualTo: false)
          .count();
      final propertiesQuery = _propertyCollection.count();
      final tenantsQuery = _userCollection
          .where('account_type', isEqualTo: 'tenant')
          .count();
      final ownersQuery = _userCollection
          .where('account_type', isEqualTo: 'owner')
          .count();

      // Run all 4 queries in parallel
      final results = await Future.wait([
        pendingQuery.get(),
        propertiesQuery.get(),
        tenantsQuery.get(),
        ownersQuery.get(),
      ]);

      // Package the results
      return AdminStatsModel(
        pendingApprovals: results[0].count ?? 0,
        totalProperties: results[1].count ?? 0,
        totalTenants: results[2].count ?? 0,
        totalOwners: results[3].count ?? 0,
      );
    } catch (e) {
      // In a real app, you'd re-throw a custom exception
      if (kDebugMode) {
        print('Error in getAdminStats: $e');
      }
      rethrow;
    }
  }

  /// Fetches and processes user registration data for the chart
  @override
  Future<List<ChartData>> getGraphData(String filter) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    // 1. Determine date range from filter
    switch (filter) {
      case 'Last Week':
        startDate = now.subtract(Duration(days: now.weekday + 6));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      case 'This Week':
      default:
        // Sunday is 7, Monday is 1. We want to start from Monday.
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
    }

    // Normalize start date to beginning of the day
    startDate = DateTime(startDate.year, startDate.month, startDate.day);

    try {
      // 2. Fetch all users registered in that range
      final querySnapshot = await _userCollection
          .where(
            'created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // 3. Process the data in Dart
      // We'll group users by the day they registered
      final Map<String, double> dailyCounts = {};

      // Initialize all days in the filter range to 0
      // This ensures the graph shows "0" for days with no signups
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final day = startDate.add(Duration(days: i));
        final dayLabel = _formatDay(day, filter);
        dailyCounts[dayLabel] = 0;
      }

      // Now, count the actual users
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['created_at'] as Timestamp).toDate();
        final dayLabel = _formatDay(createdAt, filter);

        // Increment the count for that day
        dailyCounts.update(dayLabel, (value) => value + 1, ifAbsent: () => 1);
      }

      // 4. Convert the map to our List<ChartData>
      return dailyCounts.entries
          .map((entry) => ChartData(entry.key, entry.value))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in getGraphData: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<PropertyModel>> getPendingPropertiesStream() {
    try {
      return _firestore
          .collection('properties')
          .where('is_verified', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PropertyModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      // Stream.error is a good way to propagate this
      return Stream.error(
        ServerFailure('Failed to stream pending properties.'),
      );
    }
  }

  @override
  Stream<List<PropertyModel>> getAllPropertiesStream() {
    try {
      return _firestore
          .collection('properties')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PropertyModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      return Stream.error(ServerFailure('Failed to stream all properties.'));
    }
  }

  @override
  Stream<List<UserModel>> getAllUsersStream() {
    try {
      return _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => UserModel.fromSnapshot(doc))
                .toList(),
          );
    } catch (e) {
      return Stream.error(ServerFailure('Failed to stream all users.'));
    }
  }

  /// Helper to format the X-axis labels for the chart
  String _formatDay(DateTime date, String filter) {
    // You can customize this (e.g., using the 'intl' package)
    switch (filter) {
      case 'Last Month':
        // This logic is simple; for a real app, you'd group by week
        return 'Week ${((date.day - 1) / 7).floor() + 1}';
      case 'This Week':
      case 'Last Week':
      default:
        // Returns "Mon", "Tue", "Wed", etc.
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[date.weekday - 1];
    }
  }
}
