class AdminStatsModel {
  final int pendingApprovals;
  final int totalProperties;
  final int totalTenants;
  final int totalOwners;

  // We add a 'dummy' constructor for skeletonizer
  AdminStatsModel({
    required this.pendingApprovals,
    required this.totalProperties,
    required this.totalTenants,
    required this.totalOwners,
  });

  /// A factory for creating a 'dummy' version for loading.
  factory AdminStatsModel.dummy() {
    return AdminStatsModel(
      pendingApprovals: 0,
      totalProperties: 0,
      totalTenants: 0,
      totalOwners: 0,
    );
  }
}
