import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WorkoutPlansRecord extends FirestoreRecord {
  WorkoutPlansRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "spuser_ref" field.
  DocumentReference? _spuserRef;
  DocumentReference? get spuserRef => _spuserRef;
  bool hasSpuserRef() => _spuserRef != null;

  // "sport" field.
  String? _sport;
  String get sport => _sport ?? '';
  bool hasSport() => _sport != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "model_version" field.
  String? _modelVersion;
  String get modelVersion => _modelVersion ?? '';
  bool hasModelVersion() => _modelVersion != null;

  // "age_years" field.
  int? _ageYears;
  int get ageYears => _ageYears ?? 0;
  bool hasAgeYears() => _ageYears != null;

  // "weight_kg" field.
  int? _weightKg;
  int get weightKg => _weightKg ?? 0;
  bool hasWeightKg() => _weightKg != null;

  // "attention_span" field.
  int? _attentionSpan;
  int get attentionSpan => _attentionSpan ?? 0;
  bool hasAttentionSpan() => _attentionSpan != null;

  // "sensory_tolerance" field.
  int? _sensoryTolerance;
  int get sensoryTolerance => _sensoryTolerance ?? 0;
  bool hasSensoryTolerance() => _sensoryTolerance != null;

  // "exertion_tolerance" field.
  int? _exertionTolerance;
  int get exertionTolerance => _exertionTolerance ?? 0;
  bool hasExertionTolerance() => _exertionTolerance != null;

  // "levels" field.
  List<LevelPlanStruct>? _levels;
  List<LevelPlanStruct> get levels => _levels ?? const [];
  bool hasLevels() => _levels != null;

  // "raw_plan_json" field.
  String? _rawPlanJson;
  String get rawPlanJson => _rawPlanJson ?? '';
  bool hasRawPlanJson() => _rawPlanJson != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _spuserRef = snapshotData['spuser_ref'] as DocumentReference?;
    _sport = snapshotData['sport'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _modelVersion = snapshotData['model_version'] as String?;
    _ageYears = castToType<int>(snapshotData['age_years']);
    _weightKg = castToType<int>(snapshotData['weight_kg']);
    _attentionSpan = castToType<int>(snapshotData['attention_span']);
    _sensoryTolerance = castToType<int>(snapshotData['sensory_tolerance']);
    _exertionTolerance = castToType<int>(snapshotData['exertion_tolerance']);
    _levels = getStructList(
      snapshotData['levels'],
      LevelPlanStruct.fromMap,
    );
    _rawPlanJson = snapshotData['raw_plan_json'] as String?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('workout_plans');

  static Stream<WorkoutPlansRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WorkoutPlansRecord.fromSnapshot(s));

  static Future<WorkoutPlansRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WorkoutPlansRecord.fromSnapshot(s));

  static WorkoutPlansRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WorkoutPlansRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WorkoutPlansRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WorkoutPlansRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WorkoutPlansRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WorkoutPlansRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createWorkoutPlansRecordData({
  DocumentReference? spuserRef,
  String? sport,
  DateTime? createdAt,
  String? modelVersion,
  int? ageYears,
  int? weightKg,
  int? attentionSpan,
  int? sensoryTolerance,
  int? exertionTolerance,
  String? rawPlanJson,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'spuser_ref': spuserRef,
      'sport': sport,
      'created_at': createdAt,
      'model_version': modelVersion,
      'age_years': ageYears,
      'weight_kg': weightKg,
      'attention_span': attentionSpan,
      'sensory_tolerance': sensoryTolerance,
      'exertion_tolerance': exertionTolerance,
      'raw_plan_json': rawPlanJson,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class WorkoutPlansRecordDocumentEquality
    implements Equality<WorkoutPlansRecord> {
  const WorkoutPlansRecordDocumentEquality();

  @override
  bool equals(WorkoutPlansRecord? e1, WorkoutPlansRecord? e2) {
    const listEquality = ListEquality();
    return e1?.spuserRef == e2?.spuserRef &&
        e1?.sport == e2?.sport &&
        e1?.createdAt == e2?.createdAt &&
        e1?.modelVersion == e2?.modelVersion &&
        e1?.ageYears == e2?.ageYears &&
        e1?.weightKg == e2?.weightKg &&
        e1?.attentionSpan == e2?.attentionSpan &&
        e1?.sensoryTolerance == e2?.sensoryTolerance &&
        e1?.exertionTolerance == e2?.exertionTolerance &&
        listEquality.equals(e1?.levels, e2?.levels) &&
        e1?.rawPlanJson == e2?.rawPlanJson &&
        e1?.status == e2?.status;
  }

  @override
  int hash(WorkoutPlansRecord? e) => const ListEquality().hash([
        e?.spuserRef,
        e?.sport,
        e?.createdAt,
        e?.modelVersion,
        e?.ageYears,
        e?.weightKg,
        e?.attentionSpan,
        e?.sensoryTolerance,
        e?.exertionTolerance,
        e?.levels,
        e?.rawPlanJson,
        e?.status
      ]);

  @override
  bool isValidKey(Object? o) => o is WorkoutPlansRecord;
}
