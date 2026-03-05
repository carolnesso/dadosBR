class CnpjDto {
  const CnpjDto({
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.cnpj,
    required this.logradouro,
    required this.numero,
    required this.municipio,
    required this.uf,
    required this.cep,
    required this.capitalSocial,
    required this.naturezaJuridica,
    required this.cnaePrincipal,
    required this.cnaesSecundarios,
  });

  final String razaoSocial;
  final String nomeFantasia;
  final String cnpj;
  final String logradouro;
  final String numero;
  final String municipio;
  final String uf;
  final String cep;
  final String capitalSocial;
  final String naturezaJuridica;
  final String cnaePrincipal;
  final List<String> cnaesSecundarios;

  factory CnpjDto.fromJson(Map<String, dynamic> json) {
    return CnpjDto(
      razaoSocial: _string(json['razao_social']),
      nomeFantasia: _string(json['nome_fantasia']),
      cnpj: _string(json['cnpj']),
      logradouro: _string(json['logradouro']),
      numero: _string(json['numero']),
      municipio: _string(json['municipio']),
      uf: _string(json['uf']).toUpperCase(),
      cep: _string(json['cep']),
      capitalSocial: _string(json['capital_social']),
      naturezaJuridica: _string(json['natureza_juridica']),
      cnaePrincipal: _string(json['cnae_fiscal_descricao']),
      cnaesSecundarios: _secondaryCnaes(json['cnaes_secundarios']),
    );
  }

  static List<String> _secondaryCnaes(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map((item) => _string(item['descricao']))
        .where((value) => value != '-')
        .toList();
  }

  static String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
