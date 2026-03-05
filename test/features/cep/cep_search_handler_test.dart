import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/cep/data/cep_search_handler.dart';
import 'package:dadosbr/features/search/domain/search_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CepSearchHandler', () {
    test('normalize removes non-digits', () {
      final handler = CepSearchHandler();

      expect(handler.normalize('01.310-100'), '01310100');
    });

    test('validate returns emptyInput for blank value', () {
      final handler = CepSearchHandler();

      final failure = handler.validate('   ', '');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for invalid characters', () {
      final handler = CepSearchHandler();

      final failure = handler.validate('01310-10A', '0131010');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for wrong length', () {
      final handler = CepSearchHandler();

      final failure = handler.validate('01310-10', '0131010');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid CEP', () {
      final handler = CepSearchHandler();

      final failure = handler.validate('01310-100', '01310100');

      expect(failure, isNull);
    });

    test('fetch maps dto to SearchResultData', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://brasilapi.com.br/api/cep/v2/01310100');
        return http.Response(
          jsonEncode({
            'street': 'Avenida Paulista',
            'neighborhood': 'Bela Vista',
            'city': 'Sao Paulo',
            'state': 'SP',
            'cep': '01310-100',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final handler = CepSearchHandler(client: ApiClient(client: mockClient));

      final result = await handler.fetch('01310100');

      expect(result.title, 'Resultado CEP');
      expect(result.imageAssetPath, 'assets/flags/SP.png');
      expect(_fieldValue(result, 'Rua'), 'Avenida Paulista');
      expect(_fieldValue(result, 'Bairro'), 'Bela Vista');
      expect(_fieldValue(result, 'Cidade'), 'Sao Paulo');
      expect(_fieldValue(result, 'Estado'), 'SP');
      expect(_fieldValue(result, 'CEP'), '01310-100');
    });
  });
}

String _fieldValue(SearchResultData result, String label) {
  return result.fields.firstWhere((field) => field.label == label).value;
}
