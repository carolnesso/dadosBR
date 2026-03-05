import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/cnpj/presentation/cnpj_query_config.dart';
import 'package:dadosbr/features/query/domain/query_state.dart';
import 'package:dadosbr/features/query/presentation/query_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CnpjQueryConfig', () {
    final config = CnpjQueryConfig.config;

    test('normalize removes non-digits', () {
      expect(config.normalize('11.444.777/0001-61'), '11444777000161');
    });

    test('validate returns emptyInput for blank value', () {
      final failure = config.validate('   ', '');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for invalid characters', () {
      final failure = config.validate('11.444.777/0001-6A', '1144477700016');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for wrong length', () {
      final failure = config.validate('11.444.777/0001', '114447770001');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for invalid check digits', () {
      final failure = config.validate('11.444.777/0001-62', '11444777000162');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid CNPJ', () {
      final failure = config.validate('11.444.777/0001-61', '11444777000161');
      expect(failure, isNull);
    });

    test('controller search maps dto to QueryResultData', () async {
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

      final controller = QueryController(
        config: config,
        client: ApiClient(client: mockClient),
      );
      addTearDown(controller.dispose);

      final message = await controller.search('11.444.777/0001-61');

      expect(message, isNull);
      expect(controller.state.status, QueryStatus.success);
      expect(controller.state.result!.title, 'Resultado CNPJ');
      expect(controller.state.result!.fields['Razao social'], 'Empresa Exemplo LTDA');
      expect(controller.state.result!.fields['Nome fantasia'], 'Empresa Exemplo');
      expect(controller.state.result!.fields['CNPJ'], '11.444.777/0001-61');
      expect(
        controller.state.result!.fields['Endereco'],
        'Rua Exemplo, 123, Sao Paulo, SP, 01000-000',
      );
      expect(controller.state.result!.fields['Capital social'], '100000.00');
      expect(
        controller.state.result!.fields['Natureza juridica'],
        'Sociedade Empresaria Limitada',
      );
      expect(
        controller.state.result!.fields['CNAE principal'],
        'Desenvolvimento de software',
      );
      expect(
        controller.state.result!.fields['CNAEs secundarios'],
        'Consultoria em tecnologia da informacao | Suporte tecnico',
      );
    });
  });
}
