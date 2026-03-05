import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/dominio/presentation/dominio_query_config.dart';
import 'package:dadosbr/features/query/domain/query_state.dart';
import 'package:dadosbr/features/query/presentation/query_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('DominioQueryConfig', () {
    final config = DominioQueryConfig.config;

    test('normalize trims and lowercases domain', () {
      expect(config.normalize('  EXEMPLO.COM.BR  '), 'exemplo.com.br');
    });

    test('validate returns emptyInput for blank value', () {
      final failure = config.validate('   ', '');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for domain without .br', () {
      final failure = config.validate('example.com', 'example.com');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for spaces', () {
      final failure = config.validate('meu dominio.com.br', 'meu dominio.com.br');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for consecutive dots', () {
      final failure = config.validate('empresa..com.br', 'empresa..com.br');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid .br domain', () {
      final failure = config.validate('empresa.com.br', 'empresa.com.br');
      expect(failure, isNull);
    });

    test('controller search maps dto to QueryResultData', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://brasilapi.com.br/api/registrobr/v1/empresa.com.br');
        return http.Response(
          jsonEncode({
            'domain': 'empresa.com.br',
            'status': 'published',
            'hosts': ['ns1.exemplo.net', 'ns2.exemplo.net'],
            'publication-status': 'published',
            'expires-at': '2028-01-31T00:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final controller = QueryController(
        config: config,
        client: ApiClient(client: mockClient),
      );
      addTearDown(controller.dispose);

      final message = await controller.search('empresa.com.br');

      expect(message, isNull);
      expect(controller.state.status, QueryStatus.success);
      expect(controller.state.result!.title, 'Resultado Registro.br');
      expect(controller.state.result!.fields['Dominio'], 'empresa.com.br');
      expect(controller.state.result!.fields['Status do dominio'], 'published');
      expect(controller.state.result!.fields['Hosts (DNS)'], 'ns1.exemplo.net, ns2.exemplo.net');
      expect(controller.state.result!.fields['Status da publicacao'], 'published');
      expect(controller.state.result!.fields['Data de expiracao'], '2028-01-31T00:00:00Z');
    });
  });
}
