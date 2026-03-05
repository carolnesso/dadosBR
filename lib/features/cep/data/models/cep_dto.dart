class CepDto {
  const CepDto({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.cep,
  });

  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String cep;

  factory CepDto.fromJson(Map<String, dynamic> json) {
    return CepDto(
      street: _string(json['street']),
      neighborhood: _string(json['neighborhood']),
      city: _string(json['city']),
      state: _string(json['state']).toUpperCase(),
      cep: _string(json['cep']),
    );
  }

  static String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
