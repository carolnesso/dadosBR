import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/app_failure.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(
    String url, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw const AppFailure(
        FailureType.timeout,
        'Tempo de resposta excedido. Tente novamente.',
      );
    } on SocketException {
      throw const AppFailure(
        FailureType.network,
        'Sem conexao com a internet.',
      );
    } catch (_) {
      throw const AppFailure(
        FailureType.unexpected,
        'Nao foi possivel concluir a consulta.',
      );
    }

    if (response.statusCode == 404) {
      throw const AppFailure(FailureType.notFound, 'Nenhum resultado encontrado.');
    }

    if (response.statusCode >= 500) {
      throw const AppFailure(
        FailureType.server,
        'Servico indisponivel no momento. Tente novamente.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppFailure(
        FailureType.server,
        'Erro na consulta (HTTP ${response.statusCode}).',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const AppFailure(
        FailureType.parse,
        'Resposta invalida da API.',
      );
    } catch (_) {
      throw const AppFailure(
        FailureType.parse,
        'Falha ao interpretar o retorno da API.',
      );
    }
  }
}
