import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/ui/formatters/app_input_formatters.dart';
import '../../query/domain/query_config.dart';
import '../../query/domain/query_result_data.dart';
import '../data/models/cep_dto.dart';

class CepQueryConfig {
  static final config = QueryConfig(
    id: 'cep',
    title: 'Consulta de CEP',
    description: 'Insira os dados pedidos para a pesquisa selecionada',
    fieldLabel: 'CEP',
    hint: 'CEP',
    keyboardType: TextInputType.number,
    inputFormatters: [DigitMaskInputFormatter(mask: '#####-###', maxDigits: 8)],
    maxLength: 9,
    normalize: (input) => input.replaceAll(RegExp(r'[^0-9]'), ''),
    validate: (rawInput, normalized) {
      if (rawInput.trim().isEmpty) {
        return const AppFailure(
          FailureType.emptyInput,
          'Informe um CEP para consultar.',
        );
      }

      if (RegExp(r'[^0-9\s-]').hasMatch(rawInput)) {
        return const AppFailure(
          FailureType.invalidInput,
          'CEP deve conter apenas numeros.',
        );
      }

      if (normalized.length != 8) {
        return const AppFailure(
          FailureType.invalidInput,
          'CEP invalido. Use 8 digitos numericos.',
        );
      }

      return null;
    },
    buildUrl: (normalized) => 'https://brasilapi.com.br/api/cep/v2/$normalized',
    fetchJson: (normalized, client) async {
      try {
        return await client.getJson(
          'https://brasilapi.com.br/api/cep/v2/$normalized',
          requestLabel: 'consulta de CEP',
          notFoundMessage: 'CEP nao encontrado. Verifique os digitos e tente novamente.',
          badRequestMessage: 'CEP invalido para consulta na API.',
          unavailableMessage:
              'Servico de CEP indisponivel no momento. Tente novamente em instantes.',
        );
      } on AppFailure catch (failure) {
        if (failure.type != FailureType.timeout && failure.type != FailureType.server) {
          rethrow;
        }

        final fallback = await client.getJson(
          'https://viacep.com.br/ws/$normalized/json/',
          requestLabel: 'consulta de CEP',
          notFoundMessage: 'CEP nao encontrado. Verifique os digitos e tente novamente.',
          badRequestMessage: 'CEP invalido para consulta na API.',
          unavailableMessage:
              'Servico de CEP indisponivel no momento. Tente novamente em instantes.',
        );

        final notFound = fallback['erro'] == true ||
            fallback['erro']?.toString().toLowerCase() == 'true';

        if (notFound) {
          throw const AppFailure(
            FailureType.notFound,
            'CEP nao encontrado. Verifique os digitos e tente novamente.',
          );
        }

        return {
          'street': fallback['logradouro'],
          'neighborhood': fallback['bairro'],
          'city': fallback['localidade'],
          'state': fallback['uf'],
          'cep': fallback['cep'] ?? normalized,
        };
      }
    },
    parseResult: (json) {
      final dto = CepDto.fromJson(json);
      return QueryResultData(
        title: 'Resultado CEP',
        imageAssetPath: _flagPath(dto.state),
        fields: {
          'Rua': dto.street,
          'Bairro': dto.neighborhood,
          'Cidade': dto.city,
          'Estado': dto.state,
          'CEP': dto.cep,
        },
        shareText: '''
Consulta de CEP
Rua: ${dto.street}
Bairro: ${dto.neighborhood}
Cidade: ${dto.city}
Estado: ${dto.state}
CEP: ${dto.cep}
''',
      );
    },
    requestLabel: 'consulta de CEP',
    notFoundMessage: 'CEP nao encontrado. Verifique os digitos e tente novamente.',
    badRequestMessage: 'CEP invalido para consulta na API.',
    unavailableMessage:
        'Servico de CEP indisponivel no momento. Tente novamente em instantes.',
  );

  static String? _flagPath(String uf) {
    if (uf.length != 2) return null;
    return 'assets/flags/${uf.toUpperCase()}.png';
  }
}
