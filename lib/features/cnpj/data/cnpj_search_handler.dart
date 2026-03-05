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
  String get hint => 'CNPJ';

  @override
  SearchInputKind get inputKind => SearchInputKind.cnpj;

  @override
  String normalize(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  AppFailure? validate(String rawInput, String normalized) {
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
  }

  @override
  Future<SearchResultData> fetch(String normalized) async {
    final data = await _client.getJson(
      'https://brasilapi.com.br/api/cnpj/v1/$normalized',
      requestLabel: 'consulta de CNPJ',
      notFoundMessage: 'CNPJ nao encontrado na base consultada.',
      badRequestMessage: 'CNPJ invalido para consulta na API.',
      unavailableMessage:
          'Servico de CNPJ indisponivel no momento. Tente novamente em instantes.',
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

  bool _isValidCnpj(String value) {
    if (value.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(value)) return false;

    final numbers = value.split('').map(int.parse).toList();
    final firstVerifier = _calculateVerifier(numbers, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    final secondVerifier = _calculateVerifier(numbers, [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);

    return numbers[12] == firstVerifier && numbers[13] == secondVerifier;
  }

  int _calculateVerifier(List<int> numbers, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      sum += numbers[i] * weights[i];
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}
