import '../../../search/domain/search_contract.dart';
import '../models/cnpj_dto.dart';

extension CnpjResultMapper on CnpjDto {
  SearchResultData toSearchResultData() {
    final endereco = _buildAddress();
    final cnaesSecundariosTexto =
        cnaesSecundarios.isEmpty ? '-' : cnaesSecundarios.join(' | ');

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
        ResultField(label: 'CNAEs secundarios', value: cnaesSecundariosTexto),
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
CNAEs secundarios: $cnaesSecundariosTexto
''',
    );
  }

  String _buildAddress() {
    final parts = [logradouro, numero, municipio, uf, cep]
        .where((item) => item != '-')
        .toList();

    if (parts.isEmpty) return '-';
    return parts.join(', ');
  }
}
