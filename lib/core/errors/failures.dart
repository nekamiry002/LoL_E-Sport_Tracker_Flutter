class ServerFailure implements Exception {
  const ServerFailure([this.message = 'Server error']);
  final String message;

  @override
  String toString() => 'ServerFailure: $message';
}
