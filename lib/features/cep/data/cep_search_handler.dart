import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../search/domain/search_contract.dart';
import 'mappers/cep_result_mapper.dart';
import 'models/cep_dto.dart';

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
  String get hint => 'CEP';

  @override
  SearchInputKind get inputKind => SearchInputKind.cep;

  @override
  String normalize(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  AppFailure? validate(String rawInput, String normalized) {
    if (rawInput.trim().isEmpty) {
      return const AppFailure(
        FailureType.emptyInput,
        'Informe um CEP para consultar.',
      );
    }

    if (RegExp(r'[^0-9\s-]').hasMatch(rawInput)) {
      return const AppFailure(
        FailureType.invalidInput,
        'CEP deve conter apenas numeros.',
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
    final json = await _client.getJson(
      'https://brasilapi.com.br/api/cep/v2/$normalized',
      requestLabel: 'consulta de CEP',
      notFoundMessage: 'CEP nao encontrado. Verifique os digitos e tente novamente.',
      badRequestMessage: 'CEP invalido para consulta na API.',
      unavailableMessage:
          'Servico de CEP indisponivel no momento. Tente novamente em instantes.',
    );

    final dto = CepDto.fromJson(json);
    return dto.toSearchResultData();
  }
}
