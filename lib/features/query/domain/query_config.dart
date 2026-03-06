import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import 'query_result_data.dart';

typedef InputNormalizer = String Function(String input);
typedef QueryValidator = AppFailure? Function(String rawInput, String normalized);
typedef QueryUrlBuilder = String Function(String normalized);
typedef QueryParser = QueryResultData Function(Map<String, dynamic> json);
typedef QueryFetcher = Future<Map<String, dynamic>> Function(
  String normalized,
  ApiClient client,
);

class QueryConfig {
  const QueryConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.fieldLabel,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.maxLength,
    required this.normalize,
    required this.validate,
    required this.buildUrl,
    required this.parseResult,
    required this.requestLabel,
    this.notFoundMessage,
    this.badRequestMessage,
    this.unavailableMessage,
    this.fetchJson,
    this.buttonLabel = 'Buscar',
  });

  final String id;
  final String title;
  final String description;
  final String fieldLabel;
  final String hint;
  final String buttonLabel;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLength;

  final InputNormalizer normalize;
  final QueryValidator validate;
  final QueryUrlBuilder buildUrl;
  final QueryParser parseResult;
  final QueryFetcher? fetchJson;

  final String requestLabel;
  final String? notFoundMessage;
  final String? badRequestMessage;
  final String? unavailableMessage;
}
