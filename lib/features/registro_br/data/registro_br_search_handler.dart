import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../search/domain/search_contract.dart';
import 'mappers/registro_br_result_mapper.dart';
import 'models/registro_br_dto.dart';

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
  String get hint => 'dominio.com.br';

  @override
  SearchInputKind get inputKind => SearchInputKind.domain;

  @override
  String normalize(String input) => input.trim().toLowerCase();

  @override
  AppFailure? validate(String rawInput, String normalized) {
    if (rawInput.trim().isEmpty) {
      return const AppFailure(
        FailureType.emptyInput,
        'Informe um dominio para consultar.',
      );
    }

    if (RegExp(r'\s').hasMatch(rawInput)) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Nao use espacos.',
      );
    }

    if (!normalized.endsWith('.br')) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Informe um dominio terminado em .br.',
      );
    }

    if (normalized.length > 253) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Tamanho maximo permitido: 253 caracteres.',
      );
    }

    if (RegExp(r'[^a-z0-9.-]').hasMatch(normalized)) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Use apenas letras, numeros, ponto e hifen.',
      );
    }

    if (normalized.contains('..')) {
      return const AppFailure(
        FailureType.invalidInput,
        'Dominio invalido. Pontos consecutivos nao sao permitidos.',
      );
    }

    final label = r'[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?';
    final regex = RegExp('^$label(?:\\.$label)*\\.br\$');

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
    final json = await _client.getJson(
      'https://brasilapi.com.br/api/registrobr/v1/$normalized',
      requestLabel: 'consulta de dominio Registro.br',
      notFoundMessage: 'Dominio nao encontrado no Registro.br.',
      badRequestMessage: 'Dominio invalido para consulta na API.',
      unavailableMessage:
          'Servico de dominio indisponivel no momento. Tente novamente em instantes.',
    );

    final dto = RegistroBrDto.fromJson(json);
    return dto.toSearchResultData();
  }
}
