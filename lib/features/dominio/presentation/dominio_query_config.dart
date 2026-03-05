import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/ui/formatters/app_input_formatters.dart';
import '../../query/domain/query_config.dart';
import '../../query/domain/query_result_data.dart';
import '../../registro_br/data/models/registro_br_dto.dart';

class DominioQueryConfig {
  static final config = QueryConfig(
    id: 'dominio',
    title: 'Consulta de Dominio',
    description: 'Insira os dados pedidos para a pesquisa selecionada',
    fieldLabel: 'Dominio',
    hint: 'empresa.com.br',
    keyboardType: TextInputType.text,
    inputFormatters: [LowerCaseDomainInputFormatter()],
    maxLength: 253,
    normalize: (input) => input.trim().toLowerCase(),
    validate: (rawInput, normalized) {
      if (rawInput.trim().isEmpty) {
        return const AppFailure(
          FailureType.emptyInput,
          'Informe um dominio para consultar.',
        );
      }

      if (RegExp(r'\s').hasMatch(rawInput)) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Nao use espacos.',
        );
      }

      if (!normalized.endsWith('.br')) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Informe um dominio terminado em .br.',
        );
      }

      if (normalized.length > 253) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Tamanho maximo permitido: 253 caracteres.',
        );
      }

      if (RegExp(r'[^a-z0-9.-]').hasMatch(normalized)) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Use apenas letras, numeros, ponto e hifen.',
        );
      }

      if (normalized.contains('..')) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Pontos consecutivos nao sao permitidos.',
        );
      }

      final label = r'[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?';
      final regex = RegExp('^$label(?:\\.$label)*\\.br');
      final fullMatch = regex.firstMatch(normalized)?.group(0);

      if (fullMatch != normalized) {
        return const AppFailure(
          FailureType.invalidInput,
          'Dominio invalido. Exemplo: empresa.com.br',
        );
      }

      return null;
    },
    buildUrl: (normalized) => 'https://brasilapi.com.br/api/registrobr/v1/$normalized',
    parseResult: (json) {
      final dto = RegistroBrDto.fromJson(json);
      final hostsText = dto.hosts.isEmpty ? '-' : dto.hosts.join(', ');

      return QueryResultData(
        title: 'Resultado Registro.br',
        fields: {
          'Dominio': dto.domain,
          'Status do dominio': dto.status,
          'Hosts (DNS)': hostsText,
          'Status da publicacao': dto.publicationStatus,
          'Data de expiracao': dto.expiresAt,
        },
        shareText: '''
Consulta Registro.br
Dominio: ${dto.domain}
Status do dominio: ${dto.status}
Hosts: $hostsText
Status da publicacao: ${dto.publicationStatus}
Data de expiracao: ${dto.expiresAt}
''',
      );
    },
    requestLabel: 'consulta de dominio Registro.br',
    notFoundMessage: 'Dominio nao encontrado no Registro.br.',
    badRequestMessage: 'Dominio invalido para consulta na API.',
    unavailableMessage:
        'Servico de dominio indisponivel no momento. Tente novamente em instantes.',
  );
}
