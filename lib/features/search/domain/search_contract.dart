import '../../../core/errors/app_failure.dart';

class ResultField {
  const ResultField({required this.label, required this.value});

  final String label;
  final String value;
}

class SearchResultData {
  const SearchResultData({
    required this.title,
    required this.fields,
    required this.shareText,
    this.imageAssetPath,
  });

  final String title;
  final List<ResultField> fields;
  final String shareText;
  final String? imageAssetPath;
}

abstract class SearchHandler {
  String get id;
  String get title;
  String get buttonLabel;
  String get description;
  String get hint;

  String normalize(String input);
  AppFailure? validate(String normalized);
  Future<SearchResultData> fetch(String normalized);
}

