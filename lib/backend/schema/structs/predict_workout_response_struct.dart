// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PredictWorkoutResponseStruct extends FFFirebaseStruct {
  PredictWorkoutResponseStruct({
    String? modelVersion,
    List<LevelPlanStruct>? levels,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _modelVersion = modelVersion,
        _levels = levels,
        super(firestoreUtilData);

  // "model_version" field.
  String? _modelVersion;
  String get modelVersion => _modelVersion ?? '';
  set modelVersion(String? val) => _modelVersion = val;

  bool hasModelVersion() => _modelVersion != null;

  // "levels" field.
  List<LevelPlanStruct>? _levels;
  List<LevelPlanStruct> get levels => _levels ?? const [];
  set levels(List<LevelPlanStruct>? val) => _levels = val;

  void updateLevels(Function(List<LevelPlanStruct>) updateFn) {
    updateFn(_levels ??= []);
  }

  bool hasLevels() => _levels != null;

  static PredictWorkoutResponseStruct fromMap(Map<String, dynamic> data) =>
      PredictWorkoutResponseStruct(
        modelVersion: data['model_version'] as String?,
        levels: getStructList(
          data['levels'],
          LevelPlanStruct.fromMap,
        ),
      );

  static PredictWorkoutResponseStruct? maybeFromMap(dynamic data) => data is Map
      ? PredictWorkoutResponseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'model_version': _modelVersion,
        'levels': _levels?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'model_version': serializeParam(
          _modelVersion,
          ParamType.String,
        ),
        'levels': serializeParam(
          _levels,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static PredictWorkoutResponseStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PredictWorkoutResponseStruct(
        modelVersion: deserializeParam(
          data['model_version'],
          ParamType.String,
          false,
        ),
        levels: deserializeStructParam<LevelPlanStruct>(
          data['levels'],
          ParamType.DataStruct,
          true,
          structBuilder: LevelPlanStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'PredictWorkoutResponseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PredictWorkoutResponseStruct &&
        modelVersion == other.modelVersion &&
        listEquality.equals(levels, other.levels);
  }

  @override
  int get hashCode => const ListEquality().hash([modelVersion, levels]);
}

PredictWorkoutResponseStruct createPredictWorkoutResponseStruct({
  String? modelVersion,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PredictWorkoutResponseStruct(
      modelVersion: modelVersion,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PredictWorkoutResponseStruct? updatePredictWorkoutResponseStruct(
  PredictWorkoutResponseStruct? predictWorkoutResponse, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    predictWorkoutResponse
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPredictWorkoutResponseStructData(
  Map<String, dynamic> firestoreData,
  PredictWorkoutResponseStruct? predictWorkoutResponse,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (predictWorkoutResponse == null) {
    return;
  }
  if (predictWorkoutResponse.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      predictWorkoutResponse.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final predictWorkoutResponseData = getPredictWorkoutResponseFirestoreData(
      predictWorkoutResponse, forFieldValue);
  final nestedData =
      predictWorkoutResponseData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      predictWorkoutResponse.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPredictWorkoutResponseFirestoreData(
  PredictWorkoutResponseStruct? predictWorkoutResponse, [
  bool forFieldValue = false,
]) {
  if (predictWorkoutResponse == null) {
    return {};
  }
  final firestoreData = mapToFirestore(predictWorkoutResponse.toMap());

  // Add any Firestore field values
  predictWorkoutResponse.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPredictWorkoutResponseListFirestoreData(
  List<PredictWorkoutResponseStruct>? predictWorkoutResponses,
) =>
    predictWorkoutResponses
        ?.map((e) => getPredictWorkoutResponseFirestoreData(e, true))
        .toList() ??
    [];
