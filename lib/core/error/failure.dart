/// A base class for all failures in the app
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// A specific failure for server/database errors
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// A specific failure for local cache errors
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
