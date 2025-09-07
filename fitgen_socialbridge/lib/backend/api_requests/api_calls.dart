import 'dart:convert';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class PredictWorkoutCall {
  static Future<ApiCallResponse> call({
    int? paramAgeYears,
    int? paramWeightKg,
    int? paramAttn,
    int? paramSens,
    int? paramExert,
    String? paramSport = '',
  }) async {
    final ffApiRequestBody = '''
{
  "user": {
    "age_years": ${paramAgeYears},
    "weight_kg": ${paramWeightKg},
    "attention_span_1to5": ${paramAttn},
    "sensory_tolerance_1to5": ${paramSens},
    "exertion_tolerance_1to5": ${paramExert}
  },
  "context": {
    "sport": "${escapeStringForJson(paramSport)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'PredictWorkout',
      apiUrl: 'https://rep-api-358273804497.us-central1.run.app/predict',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? full(dynamic response) => getJsonField(
        response,
        r'''$''',
        true,
      ) as List?;
  static String? modelversion(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.model_version''',
      ));
  static List<LevelPlanStruct>? levels(dynamic response) => (getJsonField(
        response,
        r'''$.levels''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => LevelPlanStruct.maybeFromMap(x))
          .withoutNulls
          .toList();
  static int? level(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.levels[:].level''',
      ));
  static String? exerciseid(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.levels[:].exercises[:].exercise_id''',
      ));
  static int? repsperset(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.levels[:].exercises[:].reps_per_set''',
      ));
  static List? exercises(dynamic response) => getJsonField(
        response,
        r'''$.levels[:].exercises''',
        true,
      ) as List?;
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
