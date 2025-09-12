import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RunsRecord extends FirestoreRecord {
  RunsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "levelruns" field.
  int? _levelruns;
  int get levelruns => _levelruns ?? 0;
  bool hasLevelruns() => _levelruns != null;

  // "endedatruns" field.
  DateTime? _endedatruns;
  DateTime? get endedatruns => _endedatruns;
  bool hasEndedatruns() => _endedatruns != null;

  // "userrefruns" field.
  DocumentReference? _userrefruns;
  DocumentReference? get userrefruns => _userrefruns;
  bool hasUserrefruns() => _userrefruns != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _levelruns = castToType<int>(snapshotData['levelruns']);
    _endedatruns = snapshotData['endedatruns'] as DateTime?;
    _userrefruns = snapshotData['userrefruns'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('runs')
          : FirebaseFirestore.instance.collectionGroup('runs');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('runs').doc(id);

  static Stream<RunsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RunsRecord.fromSnapshot(s));

  static Future<RunsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RunsRecord.fromSnapshot(s));

  static RunsRecord fromSnapshot(DocumentSnapshot snapshot) => RunsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RunsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RunsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RunsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RunsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRunsRecordData({
  int? levelruns,
  DateTime? endedatruns,
  DocumentReference? userrefruns,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'levelruns': levelruns,
      'endedatruns': endedatruns,
      'userrefruns': userrefruns,
    }.withoutNulls,
  );

  return firestoreData;
}

class RunsRecordDocumentEquality implements Equality<RunsRecord> {
  const RunsRecordDocumentEquality();

  @override
  bool equals(RunsRecord? e1, RunsRecord? e2) {
    return e1?.levelruns == e2?.levelruns &&
        e1?.endedatruns == e2?.endedatruns &&
        e1?.userrefruns == e2?.userrefruns;
  }

  @override
  int hash(RunsRecord? e) =>
      const ListEquality().hash([e?.levelruns, e?.endedatruns, e?.userrefruns]);

  @override
  bool isValidKey(Object? o) => o is RunsRecord;
}
