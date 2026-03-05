import 'package:flutter/foundation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/query_config.dart';
import '../domain/query_state.dart';

class QueryController extends ChangeNotifier {
  QueryController({required QueryConfig config, ApiClient? client})
      : _config = config,
        _client = client ?? ApiClient();

  final QueryConfig _config;
  final ApiClient _client;

  QueryState _state = const QueryState.idle();
  QueryState get state => _state;

  Future<String?> search(String rawInput) async {
    final normalized = _config.normalize(rawInput);
    final validationError = _config.validate(rawInput, normalized);

    if (validationError != null) {
      _state = _state.copyWith(
        status: QueryStatus.error,
        errorMessage: validationError.message,
      );
      notifyListeners();
      return validationError.message;
    }

    _state = _state.copyWith(
      status: QueryStatus.loading,
      clearError: true,
    );
    notifyListeners();

    try {
      final json = await _client.getJson(
        _config.buildUrl(normalized),
        requestLabel: _config.requestLabel,
        notFoundMessage: _config.notFoundMessage,
        badRequestMessage: _config.badRequestMessage,
        unavailableMessage: _config.unavailableMessage,
      );

      final result = _config.parseResult(json);
      _state = QueryState(
        status: QueryStatus.success,
        result: result,
      );
      notifyListeners();
      return null;
    } on AppFailure catch (failure) {
      _state = _state.copyWith(
        status: QueryStatus.error,
        errorMessage: failure.message,
      );
      notifyListeners();
      return failure.message;
    } catch (_) {
      const message = 'Erro inesperado. Tente novamente.';
      _state = _state.copyWith(
        status: QueryStatus.error,
        errorMessage: message,
      );
      notifyListeners();
      return message;
    }
  }

  void clearResult() {
    _state = const QueryState.idle();
    notifyListeners();
  }
}
