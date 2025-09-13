// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class LevelExerciseStruct extends FFFirebaseStruct {
  LevelExerciseStruct({
    String? exerciseId,
    int? repsPerSet,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _exerciseId = exerciseId,
        _repsPerSet = repsPerSet,
        super(firestoreUtilData);

  // "exercise_id" field.
  String? _exerciseId;
  String get exerciseId => _exerciseId ?? '';
  set exerciseId(String? val) => _exerciseId = val;

  bool hasExerciseId() => _exerciseId != null;

  // "reps_per_set" field.
  int? _repsPerSet;
  int get repsPerSet => _repsPerSet ?? 0;
  set repsPerSet(int? val) => _repsPerSet = val;

  void incrementRepsPerSet(int amount) => repsPerSet = repsPerSet + amount;

  bool hasRepsPerSet() => _repsPerSet != null;

  static LevelExerciseStruct fromMap(Map<String, dynamic> data) =>
      LevelExerciseStruct(
        exerciseId: data['exercise_id'] as String?,
        repsPerSet: castToType<int>(data['reps_per_set']),
      );

  static LevelExerciseStruct? maybeFromMap(dynamic data) => data is Map
      ? LevelExerciseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'exercise_id': _exerciseId,
        'reps_per_set': _repsPerSet,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'exercise_id': serializeParam(
          _exerciseId,
          ParamType.String,
        ),
        'reps_per_set': serializeParam(
          _repsPerSet,
          ParamType.int,
        ),
      }.withoutNulls;

  static LevelExerciseStruct fromSerializableMap(Map<String, dynamic> data) =>
      LevelExerciseStruct(
        exerciseId: deserializeParam(
          data['exercise_id'],
          ParamType.String,
          false,
        ),
        repsPerSet: deserializeParam(
          data['reps_per_set'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'LevelExerciseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LevelExerciseStruct &&
        exerciseId == other.exerciseId &&
        repsPerSet == other.repsPerSet;
  }

  @override
  int get hashCode => const ListEquality().hash([exerciseId, repsPerSet]);
}

LevelExerciseStruct createLevelExerciseStruct({
  String? exerciseId,
  int? repsPerSet,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    LevelExerciseStruct(
      exerciseId: exerciseId,
      repsPerSet: repsPerSet,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

LevelExerciseStruct? updateLevelExerciseStruct(
  LevelExerciseStruct? levelExercise, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    levelExercise
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addLevelExerciseStructData(
  Map<String, dynamic> firestoreData,
  LevelExerciseStruct? levelExercise,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (levelExercise == null) {
    return;
  }
  if (levelExercise.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && levelExercise.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final levelExerciseData =
      getLevelExerciseFirestoreData(levelExercise, forFieldValue);
  final nestedData =
      levelExerciseData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = levelExercise.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getLevelExerciseFirestoreData(
  LevelExerciseStruct? levelExercise, [
  bool forFieldValue = false,
]) {
  if (levelExercise == null) {
    return {};
  }
  final firestoreData = mapToFirestore(levelExercise.toMap());

  // Add any Firestore field values
  levelExercise.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getLevelExerciseListFirestoreData(
  List<LevelExerciseStruct>? levelExercises,
) =>
    levelExercises
        ?.map((e) => getLevelExerciseFirestoreData(e, true))
        .toList() ??
    [];
