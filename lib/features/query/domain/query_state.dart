import 'query_result_data.dart';

enum QueryStatus { idle, loading, success, error }

class QueryState {
  const QueryState({
    required this.status,
    this.result,
    this.errorMessage,
  });

  const QueryState.idle() : this(status: QueryStatus.idle);

  final QueryStatus status;
  final QueryResultData? result;
  final String? errorMessage;

  bool get hasResult => result != null;

  QueryState copyWith({
    QueryStatus? status,
    QueryResultData? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return QueryState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
