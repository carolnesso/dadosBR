import '../../../search/domain/search_contract.dart';
import '../models/registro_br_dto.dart';

extension RegistroBrResultMapper on RegistroBrDto {
  SearchResultData toSearchResultData() {
    final hostsText = hosts.isEmpty ? '-' : hosts.join(', ');

    return SearchResultData(
      title: 'Resultado Registro.br',
      fields: [
        ResultField(label: 'Dominio', value: domain),
        ResultField(label: 'Status do dominio', value: status),
        ResultField(label: 'Hosts (DNS)', value: hostsText),
        ResultField(label: 'Status da publicacao', value: publicationStatus),
        ResultField(label: 'Data de expiracao', value: expiresAt),
      ],
      shareText: '''
Consulta Registro.br
Dominio: $domain
Status do dominio: $status
Hosts: $hostsText
Status da publicacao: $publicationStatus
Data de expiracao: $expiresAt
''',
    );
  }
}
