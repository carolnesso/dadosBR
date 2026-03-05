import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/ui/formatters/app_input_formatters.dart';
import '../../query/domain/query_config.dart';
import '../../query/domain/query_result_data.dart';
import '../data/models/cnpj_dto.dart';

class CnpjQueryConfig {
  static final config = QueryConfig(
    id: 'cnpj',
    title: 'Consulta de CNPJ',
    description: 'Insira os dados pedidos para a pesquisa selecionada',
    fieldLabel: 'CNPJ',
    hint: '00.000.000/0000-00',
    keyboardType: TextInputType.number,
    inputFormatters: [
      DigitMaskInputFormatter(mask: '##.###.###/####-##', maxDigits: 14),
    ],
    maxLength: 18,
    normalize: (input) => input.replaceAll(RegExp(r'[^0-9]'), ''),
    validate: (rawInput, normalized) {
      if (rawInput.trim().isEmpty) {
        return const AppFailure(
          FailureType.emptyInput,
          'Informe um CNPJ para consultar.',
        );
      }

      if (RegExp(r'[^0-9\s./-]').hasMatch(rawInput)) {
        return const AppFailure(
          FailureType.invalidInput,
          'CNPJ deve conter apenas numeros.',
        );
      }

      if (normalized.length != 14) {
        return const AppFailure(
          FailureType.invalidInput,
          'CNPJ invalido. Use 14 digitos numericos.',
        );
      }

      if (!_isValidCnpj(normalized)) {
        return const AppFailure(
          FailureType.invalidInput,
          'CNPJ invalido. Verifique os digitos informados.',
        );
      }

      return null;
    },
    buildUrl: (normalized) => 'https://brasilapi.com.br/api/cnpj/v1/$normalized',
    parseResult: (json) {
      final dto = CnpjDto.fromJson(json);
      final endereco = _buildAddress(dto);
      final cnaes = dto.cnaesSecundarios.isEmpty ? '-' : dto.cnaesSecundarios.join(' | ');

      return QueryResultData(
        title: 'Resultado CNPJ',
        fields: {
          'Razao social': dto.razaoSocial,
          'Nome fantasia': dto.nomeFantasia,
          'CNPJ': dto.cnpj,
          'Endereco': endereco,
          'Capital social': dto.capitalSocial,
          'Natureza juridica': dto.naturezaJuridica,
          'CNAE principal': dto.cnaePrincipal,
          'CNAEs secundarios': cnaes,
        },
        shareText: '''
Consulta de CNPJ
Razao social: ${dto.razaoSocial}
Nome fantasia: ${dto.nomeFantasia}
CNPJ: ${dto.cnpj}
Endereco: $endereco
Capital social: ${dto.capitalSocial}
Natureza juridica: ${dto.naturezaJuridica}
CNAE principal: ${dto.cnaePrincipal}
CNAEs secundarios: $cnaes
''',
      );
    },
    requestLabel: 'consulta de CNPJ',
    notFoundMessage: 'CNPJ nao encontrado na base consultada.',
    badRequestMessage: 'CNPJ invalido para consulta na API.',
    unavailableMessage:
        'Servico de CNPJ indisponivel no momento. Tente novamente em instantes.',
  );

  static String _buildAddress(CnpjDto dto) {
    final parts = [dto.logradouro, dto.numero, dto.municipio, dto.uf, dto.cep]
        .where((item) => item != '-')
        .toList();

    if (parts.isEmpty) return '-';
    return parts.join(', ');
  }

  static bool _isValidCnpj(String value) {
    if (value.length != 14) return false;
    if (value.split('').toSet().length == 1) return false;

    final numbers = value.split('').map(int.parse).toList();
    final firstVerifier =
        _calculateVerifier(numbers, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    final secondVerifier =
        _calculateVerifier(numbers, [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);

    return numbers[12] == firstVerifier && numbers[13] == secondVerifier;
  }

  static int _calculateVerifier(List<int> numbers, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      sum += numbers[i] * weights[i];
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}
