enum FailureType {
  emptyInput,
  invalidInput,
  notFound,
  timeout,
  network,
  server,
  parse,
  unexpected,
}

class AppFailure implements Exception {
  const AppFailure(this.type, this.message);

  final FailureType type;
  final String message;

  @override
  String toString() => message;
}
