import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../errors/app_failure.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(
    String url, {
    Duration timeout = const Duration(seconds: 12),
    String requestLabel = 'consulta',
    String? notFoundMessage,
    String? badRequestMessage,
    String? unavailableMessage,
  }) async {
    const headers = {'Accept': 'application/json'};
    final stopwatch = Stopwatch()..start();

    _logRequest(url: url, headers: headers, timeout: timeout);

    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);
      _logResponse(
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } on TimeoutException {
      _logError(url, 'timeout after ${stopwatch.elapsedMilliseconds}ms');
      throw AppFailure(
        FailureType.timeout,
        'A $requestLabel demorou demais para responder. Tente novamente.',
      );
    } on HandshakeException {
      _logError(url, 'handshake after ${stopwatch.elapsedMilliseconds}ms');
      throw const AppFailure(
        FailureType.network,
        'Falha de seguranca na conexao. Verifique data/hora do aparelho e tente novamente.',
      );
    } on SocketException {
      _logError(url, 'network after ${stopwatch.elapsedMilliseconds}ms');
      throw const AppFailure(
        FailureType.network,
        'Sem conexao com a internet. Verifique sua rede e tente novamente.',
      );
    } on http.ClientException catch (error) {
      _logError(url, 'client exception: $error');
      throw AppFailure(
        FailureType.network,
        'Nao foi possivel conectar ao servidor para a $requestLabel.',
      );
    } catch (error) {
      _logError(url, 'unexpected: $error');
      throw AppFailure(
        FailureType.unexpected,
        'Nao foi possivel concluir a $requestLabel.',
      );
    }

    final responseMessage = _extractApiErrorMessage(response.body);

    if (response.statusCode == 404) {
      throw AppFailure(
        FailureType.notFound,
        responseMessage ??
            notFoundMessage ??
            'Nenhum resultado encontrado para essa consulta.',
      );
    }

    if (response.statusCode == 400 || response.statusCode == 422) {
      throw AppFailure(
        FailureType.invalidInput,
        responseMessage ??
            badRequestMessage ??
            'Os dados informados sao invalidos para essa consulta.',
      );
    }

    if (response.statusCode == 408 || response.statusCode == 504) {
      throw AppFailure(
        FailureType.timeout,
        'Servidor demorou para responder a $requestLabel. Tente novamente em instantes.',
      );
    }

    if (response.statusCode == 429) {
      throw AppFailure(
        FailureType.server,
        responseMessage ??
            'Muitas tentativas em pouco tempo. Aguarde e tente novamente.',
      );
    }

    if (response.statusCode >= 500) {
      throw AppFailure(
        FailureType.server,
        responseMessage ??
            unavailableMessage ??
            'Servico indisponivel no momento para $requestLabel. Tente novamente.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppFailure(
        FailureType.server,
        responseMessage ?? 'Falha na $requestLabel (HTTP ${response.statusCode}).',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        _logDecoded(decoded);
        return decoded;
      }
      throw const AppFailure(
        FailureType.parse,
        'Resposta invalida da API.',
      );
    } on AppFailure {
      rethrow;
    } catch (error) {
      _logError(url, 'parse: $error');
      throw AppFailure(
        FailureType.parse,
        'Recebemos uma resposta invalida ao processar a $requestLabel.',
      );
    }
  }

  void _logRequest({
    required String url,
    required Map<String, String> headers,
    required Duration timeout,
  }) {
    if (!kDebugMode) return;
    debugPrint('--- API REQUEST START ---');
    debugPrint('[API] METHOD GET');
    debugPrint('[API] URL $url');
    debugPrint('[API] HEADERS $headers');
    debugPrint('[API] TIMEOUT ${timeout.inSeconds}s');
  }

  void _logResponse({
    required String url,
    required int statusCode,
    required String body,
    required int elapsedMs,
  }) {
    if (!kDebugMode) return;
    debugPrint('[API] URL $url');
    debugPrint('[API] STATUS $statusCode');
    debugPrint('[API] ELAPSED ${elapsedMs}ms');
    debugPrint('[API] RAW BODY ${_truncate(body)}');
    debugPrint('--- API REQUEST END ---');
  }

  void _logDecoded(Map<String, dynamic> decoded) {
    if (!kDebugMode) return;
    debugPrint('[API] DECODED JSON ${_truncate(jsonEncode(decoded))}');
  }

  void _logError(String url, String message) {
    if (!kDebugMode) return;
    debugPrint('[API][ERROR] GET $url -> $message');
    debugPrint('--- API REQUEST END ---');
  }

  String _truncate(String value, {int max = 5000}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}...(truncated)';
  }

  String? _extractApiErrorMessage(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      const candidates = [
        'message',
        'mensagem',
        'error',
        'erro',
        'detail',
        'details',
      ];

      for (final key in candidates) {
        final value = decoded[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
