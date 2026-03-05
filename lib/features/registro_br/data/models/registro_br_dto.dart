class RegistroBrDto {
  const RegistroBrDto({
    required this.domain,
    required this.status,
    required this.hosts,
    required this.publicationStatus,
    required this.expiresAt,
  });

  final String domain;
  final String status;
  final List<String> hosts;
  final String publicationStatus;
  final String expiresAt;

  factory RegistroBrDto.fromJson(Map<String, dynamic> json) {
    return RegistroBrDto(
      domain: _string(_readAny(json, const ['domain', 'fqdn', 'host'])),
      status: _string(_readAny(json, const ['status'])),
      hosts: _hosts(_readAny(json, const ['hosts', 'host'])),
      publicationStatus: _string(
        _readAny(json, const ['publication-status', 'publication_status']),
      ),
      expiresAt: _string(_readAny(json, const ['expires-at', 'expires_at'])),
    );
  }

  static dynamic _readAny(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static List<String> _hosts(dynamic value) {
    if (value is List) {
      final items = value
          .map((item) => _string(item))
          .where((item) => item != '-')
          .toList();
      return items;
    }

    final host = _string(value);
    if (host == '-') return const [];
    return [host];
  }

  static String _string(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
