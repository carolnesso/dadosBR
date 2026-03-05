import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../search/domain/search_contract.dart';

class CepSearchHandler implements SearchHandler {
  CepSearchHandler({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  String get id => 'cep';

  @override
  String get title => 'Consulta de CEP';

  @override
  String get buttonLabel => 'CEP';

  @override
  String get description =>
      'Insira um CEP valido para consultar dados de endereco pela BrasilAPI.';

  @override
  String get hint => 'CEP (somente numeros)';

  @override
  String normalize(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  AppFailure? validate(String normalized) {
    if (normalized.isEmpty) {
      return const AppFailure(
        FailureType.emptyInput,
        'Informe um CEP para consultar.',
      );
    }
    if (normalized.length != 8) {
      return const AppFailure(
        FailureType.invalidInput,
        'CEP invalido. Use 8 digitos numericos.',
      );
    }
    return null;
  }

  @override
  Future<SearchResultData> fetch(String normalized) async {
    final data = await _client.getJson(
      'https://brasilapi.com.br/api/cep/v2/$normalized',
    );

    final street = _string(data['street']);
    final neighborhood = _string(data['neighborhood']);
    final city = _string(data['city']);
    final state = _string(data['state']);
    final cep = _string(data['cep']);

    return SearchResultData(
      title: 'Resultado CEP',
      imageAssetPath: _stateFlagAssetPath(state),
      fields: [
        ResultField(label: 'Rua', value: street),
        ResultField(label: 'Bairro', value: neighborhood),
        ResultField(label: 'Cidade', value: city),
        ResultField(label: 'Estado', value: state),
        ResultField(label: 'CEP', value: cep),
      ],
      shareText: '''
Consulta de CEP
Rua: $street
Bairro: $neighborhood
Cidade: $city
Estado: $state
CEP: $cep
''',
    );
  }

  String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String? _stateFlagAssetPath(String uf) {
    if (uf.length != 2) return null;
    final upperUf = uf.toUpperCase();
    return 'assets/flags/$upperUf.png';
  }
}



