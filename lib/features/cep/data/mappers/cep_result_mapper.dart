import '../../../search/domain/search_contract.dart';
import '../models/cep_dto.dart';

extension CepResultMapper on CepDto {
  SearchResultData toSearchResultData() {
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

  String? _stateFlagAssetPath(String uf) {
    if (uf.length != 2) return null;
    return 'assets/flags/${uf.toUpperCase()}.png';
  }
}
