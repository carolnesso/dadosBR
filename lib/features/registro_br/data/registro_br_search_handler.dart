import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../search/domain/search_contract.dart';

class RegistroBrSearchHandler implements SearchHandler {
  RegistroBrSearchHandler({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  String get id => 'registro_br';

  @override
  String get title => 'Consulta de Registro.br';

  @override
  String get buttonLabel => 'REGISTRO.BR';

  @override
  String get description => 'Insira um dominio para consultar no Registro.br.';

  @override
  String get hint => 'dominio.br';

  @override
  String normalize(String input) => input.trim().toLowerCase();

  @override
  AppFailure? validate(String normalized) {
    if (normalized.isEmpty) {
      return const AppFailure(
        FailureType.emptyInput,
        'Informe um dominio para consultar.',
      );
    }

    final regex = RegExp(r'^[a-z0-9-]+(\.[a-z0-9-]+)*\.br$');
    if (!regex.hasMatch(normalized)) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Exemplo: empresa.com.br',
      );
    }
    return null;
  }

  @override
  Future<SearchResultData> fetch(String normalized) async {
    final data = await _client.getJson(
      'https://brasilapi.com.br/api/registrobr/v1/$normalized',
    );

    final domain = _string(_readAny(data, ['domain', 'fqdn', 'host']));
    final status = _string(_readAny(data, ['status']));
    final hosts = _hostsToString(_readAny(data, ['hosts', 'host']));
    final publication = _string(
      _readAny(data, ['publication-status', 'publication_status']),
    );
    final expiresAt = _string(_readAny(data, ['expires-at', 'expires_at']));

    return SearchResultData(
      title: 'Resultado Registro.br',
      fields: [
        ResultField(label: 'Dominio', value: domain),
        ResultField(label: 'Status do dominio', value: status),
        ResultField(label: 'Hosts (DNS)', value: hosts),
        ResultField(label: 'Status da publicacao', value: publication),
        ResultField(label: 'Data de expiracao', value: expiresAt),
      ],
      shareText: '''
Consulta Registro.br
Dominio: $domain
Status do dominio: $status
Hosts: $hosts
Status da publicacao: $publication
Data de expiracao: $expiresAt
''',
    );
  }

  dynamic _readAny(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key)) return data[key];
    }
    return null;
  }

  String _hostsToString(dynamic hosts) {
    if (hosts is List && hosts.isNotEmpty) {
      return hosts.map((item) => item.toString()).join(', ');
    }
    if (hosts is String && hosts.isNotEmpty) return hosts;
    return '-';
  }

  String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
