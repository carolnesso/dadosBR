class QueryResultData {
  const QueryResultData({
    required this.title,
    required this.fields,
    required this.shareText,
    this.imageAssetPath,
  });

  final String title;
  final Map<String, String> fields;
  final String shareText;
  final String? imageAssetPath;
}
