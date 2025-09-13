// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LevelPlanStruct extends FFFirebaseStruct {
  LevelPlanStruct({
    int? level,
    double? multiplierUsed,
    List<LevelExerciseStruct>? exercises,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _level = level,
        _multiplierUsed = multiplierUsed,
        _exercises = exercises,
        super(firestoreUtilData);

  // "level" field.
  int? _level;
  int get level => _level ?? 0;
  set level(int? val) => _level = val;

  void incrementLevel(int amount) => level = level + amount;

  bool hasLevel() => _level != null;

  // "multiplier_used" field.
  double? _multiplierUsed;
  double get multiplierUsed => _multiplierUsed ?? 0.0;
  set multiplierUsed(double? val) => _multiplierUsed = val;

  void incrementMultiplierUsed(double amount) =>
      multiplierUsed = multiplierUsed + amount;

  bool hasMultiplierUsed() => _multiplierUsed != null;

  // "exercises" field.
  List<LevelExerciseStruct>? _exercises;
  List<LevelExerciseStruct> get exercises => _exercises ?? const [];
  set exercises(List<LevelExerciseStruct>? val) => _exercises = val;

  void updateExercises(Function(List<LevelExerciseStruct>) updateFn) {
    updateFn(_exercises ??= []);
  }

  bool hasExercises() => _exercises != null;

  static LevelPlanStruct fromMap(Map<String, dynamic> data) => LevelPlanStruct(
        level: castToType<int>(data['level']),
        multiplierUsed: castToType<double>(data['multiplier_used']),
        exercises: getStructList(
          data['exercises'],
          LevelExerciseStruct.fromMap,
        ),
      );

  static LevelPlanStruct? maybeFromMap(dynamic data) => data is Map
      ? LevelPlanStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'level': _level,
        'multiplier_used': _multiplierUsed,
        'exercises': _exercises?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'level': serializeParam(
          _level,
          ParamType.int,
        ),
        'multiplier_used': serializeParam(
          _multiplierUsed,
          ParamType.double,
        ),
        'exercises': serializeParam(
          _exercises,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static LevelPlanStruct fromSerializableMap(Map<String, dynamic> data) =>
      LevelPlanStruct(
        level: deserializeParam(
          data['level'],
          ParamType.int,
          false,
        ),
        multiplierUsed: deserializeParam(
          data['multiplier_used'],
          ParamType.double,
          false,
        ),
        exercises: deserializeStructParam<LevelExerciseStruct>(
          data['exercises'],
          ParamType.DataStruct,
          true,
          structBuilder: LevelExerciseStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'LevelPlanStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is LevelPlanStruct &&
        level == other.level &&
        multiplierUsed == other.multiplierUsed &&
        listEquality.equals(exercises, other.exercises);
  }

  @override
  int get hashCode =>
      const ListEquality().hash([level, multiplierUsed, exercises]);
}

LevelPlanStruct createLevelPlanStruct({
  int? level,
  double? multiplierUsed,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    LevelPlanStruct(
      level: level,
      multiplierUsed: multiplierUsed,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

LevelPlanStruct? updateLevelPlanStruct(
  LevelPlanStruct? levelPlan, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    levelPlan
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addLevelPlanStructData(
  Map<String, dynamic> firestoreData,
  LevelPlanStruct? levelPlan,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (levelPlan == null) {
    return;
  }
  if (levelPlan.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && levelPlan.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final levelPlanData = getLevelPlanFirestoreData(levelPlan, forFieldValue);
  final nestedData = levelPlanData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = levelPlan.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getLevelPlanFirestoreData(
  LevelPlanStruct? levelPlan, [
  bool forFieldValue = false,
]) {
  if (levelPlan == null) {
    return {};
  }
  final firestoreData = mapToFirestore(levelPlan.toMap());

  // Add any Firestore field values
  levelPlan.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getLevelPlanListFirestoreData(
  List<LevelPlanStruct>? levelPlans,
) =>
    levelPlans?.map((e) => getLevelPlanFirestoreData(e, true)).toList() ?? [];
