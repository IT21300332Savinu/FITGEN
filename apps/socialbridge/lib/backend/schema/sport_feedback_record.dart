import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SportFeedbackRecord extends FirestoreRecord {
  SportFeedbackRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "sport" field.
  String? _sport;
  String get sport => _sport ?? '';
  bool hasSport() => _sport != null;

  // "workoutdatetime" field.
  DateTime? _workoutdatetime;
  DateTime? get workoutdatetime => _workoutdatetime;
  bool hasWorkoutdatetime() => _workoutdatetime != null;

  // "lvl" field.
  int? _lvl;
  int get lvl => _lvl ?? 0;
  bool hasLvl() => _lvl != null;

  // "exercise" field.
  int? _exercise;
  int get exercise => _exercise ?? 0;
  bool hasExercise() => _exercise != null;

  // "fb_workout" field.
  double? _fbWorkout;
  double get fbWorkout => _fbWorkout ?? 0.0;
  bool hasFbWorkout() => _fbWorkout != null;

  // "fb_exercises" field.
  double? _fbExercises;
  double get fbExercises => _fbExercises ?? 0.0;
  bool hasFbExercises() => _fbExercises != null;

  // "fb_mood" field.
  double? _fbMood;
  double get fbMood => _fbMood ?? 0.0;
  bool hasFbMood() => _fbMood != null;

  // "count" field.
  int? _count;
  int get count => _count ?? 0;
  bool hasCount() => _count != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _sport = snapshotData['sport'] as String?;
    _workoutdatetime = snapshotData['workoutdatetime'] as DateTime?;
    _lvl = castToType<int>(snapshotData['lvl']);
    _exercise = castToType<int>(snapshotData['exercise']);
    _fbWorkout = castToType<double>(snapshotData['fb_workout']);
    _fbExercises = castToType<double>(snapshotData['fb_exercises']);
    _fbMood = castToType<double>(snapshotData['fb_mood']);
    _count = castToType<int>(snapshotData['count']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('sport_feedback');

  static Stream<SportFeedbackRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SportFeedbackRecord.fromSnapshot(s));

  static Future<SportFeedbackRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SportFeedbackRecord.fromSnapshot(s));

  static SportFeedbackRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SportFeedbackRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SportFeedbackRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SportFeedbackRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SportFeedbackRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SportFeedbackRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSportFeedbackRecordData({
  DocumentReference? user,
  String? sport,
  DateTime? workoutdatetime,
  int? lvl,
  int? exercise,
  double? fbWorkout,
  double? fbExercises,
  double? fbMood,
  int? count,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'sport': sport,
      'workoutdatetime': workoutdatetime,
      'lvl': lvl,
      'exercise': exercise,
      'fb_workout': fbWorkout,
      'fb_exercises': fbExercises,
      'fb_mood': fbMood,
      'count': count,
    }.withoutNulls,
  );

  return firestoreData;
}

class SportFeedbackRecordDocumentEquality
    implements Equality<SportFeedbackRecord> {
  const SportFeedbackRecordDocumentEquality();

  @override
  bool equals(SportFeedbackRecord? e1, SportFeedbackRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.sport == e2?.sport &&
        e1?.workoutdatetime == e2?.workoutdatetime &&
        e1?.lvl == e2?.lvl &&
        e1?.exercise == e2?.exercise &&
        e1?.fbWorkout == e2?.fbWorkout &&
        e1?.fbExercises == e2?.fbExercises &&
        e1?.fbMood == e2?.fbMood &&
        e1?.count == e2?.count;
  }

  @override
  int hash(SportFeedbackRecord? e) => const ListEquality().hash([
        e?.user,
        e?.sport,
        e?.workoutdatetime,
        e?.lvl,
        e?.exercise,
        e?.fbWorkout,
        e?.fbExercises,
        e?.fbMood,
        e?.count
      ]);

  @override
  bool isValidKey(Object? o) => o is SportFeedbackRecord;
}
