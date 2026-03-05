import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/cnpj/data/cnpj_search_handler.dart';
import 'package:dadosbr/features/search/domain/search_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CnpjSearchHandler', () {
    test('normalize removes non-digits', () {
      final handler = CnpjSearchHandler();

      expect(handler.normalize('11.444.777/0001-61'), '11444777000161');
    });

    test('validate returns emptyInput for blank value', () {
      final handler = CnpjSearchHandler();

      final failure = handler.validate('   ', '');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for invalid characters', () {
      final handler = CnpjSearchHandler();

      final failure = handler.validate('11.444.777/0001-6A', '1144477700016');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for wrong length', () {
      final handler = CnpjSearchHandler();

      final failure = handler.validate('11.444.777/0001', '114447770001');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for invalid check digits', () {
      final handler = CnpjSearchHandler();

      final failure = handler.validate('11.444.777/0001-62', '11444777000162');

      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid CNPJ', () {
      final handler = CnpjSearchHandler();

      final failure = handler.validate('11.444.777/0001-61', '11444777000161');

      expect(failure, isNull);
    });

    test('fetch maps dto to SearchResultData', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://brasilapi.com.br/api/cnpj/v1/11444777000161');
        return http.Response(
          jsonEncode({
            'razao_social': 'Empresa Exemplo LTDA',
            'nome_fantasia': 'Empresa Exemplo',
            'cnpj': '11.444.777/0001-61',
            'logradouro': 'Rua Exemplo',
            'numero': '123',
            'municipio': 'Sao Paulo',
            'uf': 'SP',
            'cep': '01000-000',
            'capital_social': '100000.00',
            'natureza_juridica': 'Sociedade Empresaria Limitada',
            'cnae_fiscal_descricao': 'Desenvolvimento de software',
            'cnaes_secundarios': [
              {'descricao': 'Consultoria em tecnologia da informacao'},
              {'descricao': 'Suporte tecnico'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final handler = CnpjSearchHandler(client: ApiClient(client: mockClient));

      final result = await handler.fetch('11444777000161');

      expect(result.title, 'Resultado CNPJ');
      expect(_fieldValue(result, 'Razao social'), 'Empresa Exemplo LTDA');
      expect(_fieldValue(result, 'Nome fantasia'), 'Empresa Exemplo');
      expect(_fieldValue(result, 'CNPJ'), '11.444.777/0001-61');
      expect(
        _fieldValue(result, 'Endereco'),
        'Rua Exemplo, 123, Sao Paulo, SP, 01000-000',
      );
      expect(_fieldValue(result, 'Capital social'), '100000.00');
      expect(
        _fieldValue(result, 'Natureza juridica'),
        'Sociedade Empresaria Limitada',
      );
      expect(_fieldValue(result, 'CNAE principal'), 'Desenvolvimento de software');
      expect(
        _fieldValue(result, 'CNAEs secundarios'),
        'Consultoria em tecnologia da informacao | Suporte tecnico',
      );
    });
  });
}

String _fieldValue(SearchResultData result, String label) {
  return result.fields.firstWhere((field) => field.label == label).value;
}
