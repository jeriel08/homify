import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/features/admin/domain/repositories/admin_repository.dart';
import 'package:homify/features/admin/domain/usecases/get_admin_stats.dart';
import 'package:homify/features/admin/domain/usecases/get_graph_data.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the Remote Data Source
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AdminRemoteDataSourceImpl(firestore);
});

/// Provides the Repository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final remoteDataSource = ref.watch(adminRemoteDataSourceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return AdminRepositoryImpl(
    remoteDataSource: remoteDataSource,
    authRepository: authRepository,
  );
});

/// Provides the GetAdminStats Usecase
final getAdminStatsUsecaseProvider = Provider<GetAdminStats>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAdminStats(repository);
});

/// Provides the GetGraphData Usecase
final getGraphDataUsecaseProvider = Provider<GetGraphData>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetGraphData(repository);
});

// -------------------------------------------------------------------
// 2. Chart Filter Provider
// -------------------------------------------------------------------

/// Holds the state of the selected filter chip (e.g., "This Week").
final adminGraphFilterProvider = StateProvider<String>((ref) {
  return 'This Week'; // Default value
});

// -------------------------------------------------------------------
// 3. KPI Card Data Provider
// -------------------------------------------------------------------

/// Fetches the statistics for the KPI cards.
final adminStatsProvider = FutureProvider<AdminStatsModel>((ref) async {
  // 1. Get the usecase from our new DI provider
  final getAdminStats = ref.watch(getAdminStatsUsecaseProvider);

  // 2. Call the usecase
  final result = await getAdminStats();

  // 3. Handle the result (Either Failure or Success)
  return result.fold(
    (failure) {
      // If it's a failure, throw an exception. The UI's .when()
      // .error() state will catch this.
      throw Exception(failure.message);
    },
    (stats) {
      // If it's a success, return the data.
      return stats;
    },
  );
});

// -------------------------------------------------------------------
// 4. Chart Data Provider
// -------------------------------------------------------------------

/// Fetches the data for the registration chart.
/// It `watches` the filter provider, so it will re-run
/// whenever the filter changes.
final adminGraphDataProvider = FutureProvider<List<ChartData>>((ref) async {
  // 1. Get the usecase
  final getGraphData = ref.watch(getGraphDataUsecaseProvider);

  // 2. Get the currently selected filter
  final filter = ref.watch(adminGraphFilterProvider);

  // 3. Call the usecase with the filter
  final result = await getGraphData(filter);

  // 4. Handle the result
  return result.fold(
    (failure) {
      throw Exception(failure.message);
    },
    (chartData) {
      return chartData;
    },
  );
});

// -------------------------------------------------------------------
// 5. All Properties Provider
// -------------------------------------------------------------------

final allPropertiesProvider = StreamProvider<List<PropertyWithUser>>((ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.getAllProperties().map((either) {
    return either.fold((failure) => [], (properties) => properties);
  });
});

// -------------------------------------------------------------------
// 6. All Users Provider
// -------------------------------------------------------------------

final allUsersProvider = StreamProvider<List<UserEntity>>((ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.getAllUsers().map((either) {
    return either.fold((failure) => [], (users) => users);
  });
});
