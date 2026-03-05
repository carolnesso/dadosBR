import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/registro_br/data/registro_br_search_handler.dart';
import 'package:dadosbr/features/search/domain/search_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RegistroBrSearchHandler', () {
    test('normalize trims and lowercases domain', () {
      final handler = RegistroBrSearchHandler();

      expect(handler.normalize('  EXEMPLO.COM.BR  '), 'exemplo.com.br');
    });

    test('validate returns emptyInput for blank value', () {
      final handler = RegistroBrSearchHandler();

      final failure = handler.validate('   ', '');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for domain without .br', () {
      final handler = RegistroBrSearchHandler();

      final failure = handler.validate('example.com', 'example.com');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for spaces', () {
      final handler = RegistroBrSearchHandler();

      final failure = handler.validate('meu dominio.com.br', 'meu dominio.com.br');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for consecutive dots', () {
      final handler = RegistroBrSearchHandler();

      final failure = handler.validate('empresa..com.br', 'empresa..com.br');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid .br domain', () {
      final handler = RegistroBrSearchHandler();

      final failure = handler.validate('empresa.com.br', 'empresa.com.br');

      expect(failure, isNull);
    });

    test('fetch maps dto to SearchResultData', () async {
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

      final handler = RegistroBrSearchHandler(client: ApiClient(client: mockClient));

      final result = await handler.fetch('empresa.com.br');

      expect(result.title, 'Resultado Registro.br');
      expect(_fieldValue(result, 'Dominio'), 'empresa.com.br');
      expect(_fieldValue(result, 'Status do dominio'), 'published');
      expect(_fieldValue(result, 'Hosts (DNS)'), 'ns1.exemplo.net, ns2.exemplo.net');
      expect(_fieldValue(result, 'Status da publicacao'), 'published');
      expect(_fieldValue(result, 'Data de expiracao'), '2028-01-31T00:00:00Z');
    });
  });
}

String _fieldValue(SearchResultData result, String label) {
  return result.fields.firstWhere((field) => field.label == label).value;
}
