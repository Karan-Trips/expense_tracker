abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AIFailure extends Failure {
  const AIFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
