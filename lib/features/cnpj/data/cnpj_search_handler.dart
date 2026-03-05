import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../search/domain/search_contract.dart';

class CnpjSearchHandler implements SearchHandler {
  CnpjSearchHandler({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  String get id => 'cnpj';

  @override
  String get title => 'Consulta de CNPJ';

  @override
  String get buttonLabel => 'CNPJ';

  @override
  String get description =>
      'Insira um CNPJ valido para consultar dados cadastrais pela BrasilAPI.';

  @override
  String get hint => 'CNPJ (somente numeros)';

  @override
  String normalize(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  AppFailure? validate(String normalized) {
    if (normalized.isEmpty) {
      return const AppFailure(
        FailureType.emptyInput,
        'Informe um CNPJ para consultar.',
      );
    }
    if (normalized.length != 14) {
      return const AppFailure(
        FailureType.invalidInput,
        'CNPJ invalido. Use 14 digitos numericos.',
      );
    }
    return null;
  }

  @override
  Future<SearchResultData> fetch(String normalized) async {
    final data = await _client.getJson(
      'https://brasilapi.com.br/api/cnpj/v1/$normalized',
    );

    final razaoSocial = _string(data['razao_social']);
    final nomeFantasia = _string(data['nome_fantasia']);
    final cnpj = _string(data['cnpj']);
    final capitalSocial = _string(data['capital_social']);
    final naturezaJuridica = _string(data['natureza_juridica']);
    final cnaePrincipal = _string(data['cnae_fiscal_descricao']);
    final cnaesSecundarios = _secondaryCnaes(data['cnaes_secundarios']);
    final endereco = _buildAddress(data);

    return SearchResultData(
      title: 'Resultado CNPJ',
      fields: [
        ResultField(label: 'Razao social', value: razaoSocial),
        ResultField(label: 'Nome fantasia', value: nomeFantasia),
        ResultField(label: 'CNPJ', value: cnpj),
        ResultField(label: 'Endereco', value: endereco),
        ResultField(label: 'Capital social', value: capitalSocial),
        ResultField(label: 'Natureza juridica', value: naturezaJuridica),
        ResultField(label: 'CNAE principal', value: cnaePrincipal),
        ResultField(label: 'CNAEs secundarios', value: cnaesSecundarios),
      ],
      shareText: '''
Consulta de CNPJ
Razao social: $razaoSocial
Nome fantasia: $nomeFantasia
CNPJ: $cnpj
Endereco: $endereco
Capital social: $capitalSocial
Natureza juridica: $naturezaJuridica
CNAE principal: $cnaePrincipal
CNAEs secundarios: $cnaesSecundarios
''',
    );
  }

  String _buildAddress(Map<String, dynamic> data) {
    final parts = [
      _string(data['logradouro']),
      _string(data['numero']),
      _string(data['municipio']),
      _string(data['uf']),
      _string(data['cep']),
    ].where((item) => item != '-').toList();

    if (parts.isEmpty) return '-';
    return parts.join(', ');
  }

  String _secondaryCnaes(dynamic raw) {
    if (raw is! List) return '-';

    final descriptions = raw
        .whereType<Map<String, dynamic>>()
        .map((item) => _string(item['descricao']))
        .where((item) => item != '-')
        .toList();

    if (descriptions.isEmpty) return '-';
    return descriptions.join(' | ');
  }

  String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
