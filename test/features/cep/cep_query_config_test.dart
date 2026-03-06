import 'dart:convert';

import 'package:dadosbr/core/errors/app_failure.dart';
import 'package:dadosbr/core/network/api_client.dart';
import 'package:dadosbr/features/cep/presentation/cep_query_config.dart';
import 'package:dadosbr/features/query/domain/query_state.dart';
import 'package:dadosbr/features/query/presentation/query_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CepQueryConfig', () {
    final config = CepQueryConfig.config;

    test('normalize removes non-digits', () {
      expect(config.normalize('01.310-100'), '01310100');
    });

    test('validate returns emptyInput for blank value', () {
      final failure = config.validate('   ', '');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.emptyInput);
    });

    test('validate returns invalidInput for invalid characters', () {
      final failure = config.validate('01310-10A', '0131010');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns invalidInput for wrong length', () {
      final failure = config.validate('01310-10', '0131010');
      expect(failure, isNotNull);
      expect(failure!.type, FailureType.invalidInput);
    });

    test('validate returns null for valid CEP', () {
      final failure = config.validate('01310-100', '01310100');
      expect(failure, isNull);
    });

    test('controller search maps dto to QueryResultData', () async {
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

      final controller = QueryController(
        config: config,
        client: ApiClient(client: mockClient),
      );
      addTearDown(controller.dispose);

      final message = await controller.search('01310-100');

      expect(message, isNull);
      expect(controller.state.status, QueryStatus.success);
      expect(controller.state.result!.title, 'Resultado CEP');
      expect(controller.state.result!.imageAssetPath, 'assets/flags/SP.png');
      expect(controller.state.result!.fields['Rua'], 'Avenida Paulista');
      expect(controller.state.result!.fields['Bairro'], 'Bela Vista');
      expect(controller.state.result!.fields['Cidade'], 'Sao Paulo');
      expect(controller.state.result!.fields['Estado'], 'SP');
      expect(controller.state.result!.fields['CEP'], '01310-100');
    });

    test('controller falls back to ViaCEP when BrasilAPI returns 504', () async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();

        if (url == 'https://brasilapi.com.br/api/cep/v2/66666666') {
          return http.Response('<html>Gateway time-out</html>', 504);
        }

        if (url == 'https://viacep.com.br/ws/66666666/json/') {
          return http.Response(
            jsonEncode({
              'cep': '66666-666',
              'logradouro': 'Rua Fallback',
              'bairro': 'Centro',
              'localidade': 'Cidade Fallback',
              'uf': 'PA',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('not found', 404);
      });

      final controller = QueryController(
        config: config,
        client: ApiClient(client: mockClient),
      );
      addTearDown(controller.dispose);

      final message = await controller.search('66666-666');

      expect(message, isNull);
      expect(controller.state.status, QueryStatus.success);
      expect(controller.state.result!.fields['Rua'], 'Rua Fallback');
      expect(controller.state.result!.fields['Bairro'], 'Centro');
      expect(controller.state.result!.fields['Cidade'], 'Cidade Fallback');
      expect(controller.state.result!.fields['Estado'], 'PA');
      expect(controller.state.result!.fields['CEP'], '66666-666');
    });

    test('controller returns notFound when fallback says CEP does not exist', () async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();

        if (url == 'https://brasilapi.com.br/api/cep/v2/99999999') {
          return http.Response('<html>Gateway time-out</html>', 504);
        }

        if (url == 'https://viacep.com.br/ws/99999999/json/') {
          return http.Response(
            jsonEncode({'erro': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('not found', 404);
      });

      final controller = QueryController(
        config: config,
        client: ApiClient(client: mockClient),
      );
      addTearDown(controller.dispose);

      final message = await controller.search('99999-999');

      expect(message, 'CEP nao encontrado. Verifique os digitos e tente novamente.');
      expect(controller.state.status, QueryStatus.error);
      expect(controller.state.errorMessage, message);
    });
  });
}
