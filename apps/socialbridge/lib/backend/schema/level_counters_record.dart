import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LevelCountersRecord extends FirestoreRecord {
  LevelCountersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "docidcounters" field.
  DocumentReference? _docidcounters;
  DocumentReference? get docidcounters => _docidcounters;
  bool hasDocidcounters() => _docidcounters != null;

  // "levelscounters" field.
  int? _levelscounters;
  int get levelscounters => _levelscounters ?? 0;
  bool hasLevelscounters() => _levelscounters != null;

  // "count" field.
  int? _count;
  int get count => _count ?? 0;
  bool hasCount() => _count != null;

  // "lastcompletedatcounters" field.
  DateTime? _lastcompletedatcounters;
  DateTime? get lastcompletedatcounters => _lastcompletedatcounters;
  bool hasLastcompletedatcounters() => _lastcompletedatcounters != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _docidcounters = snapshotData['docidcounters'] as DocumentReference?;
    _levelscounters = castToType<int>(snapshotData['levelscounters']);
    _count = castToType<int>(snapshotData['count']);
    _lastcompletedatcounters =
        snapshotData['lastcompletedatcounters'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('level_counters')
          : FirebaseFirestore.instance.collectionGroup('level_counters');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('level_counters').doc(id);

  static Stream<LevelCountersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LevelCountersRecord.fromSnapshot(s));

  static Future<LevelCountersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LevelCountersRecord.fromSnapshot(s));

  static LevelCountersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LevelCountersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LevelCountersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LevelCountersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LevelCountersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LevelCountersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLevelCountersRecordData({
  DocumentReference? docidcounters,
  int? levelscounters,
  int? count,
  DateTime? lastcompletedatcounters,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'docidcounters': docidcounters,
      'levelscounters': levelscounters,
      'count': count,
      'lastcompletedatcounters': lastcompletedatcounters,
    }.withoutNulls,
  );

  return firestoreData;
}

class LevelCountersRecordDocumentEquality
    implements Equality<LevelCountersRecord> {
  const LevelCountersRecordDocumentEquality();

  @override
  bool equals(LevelCountersRecord? e1, LevelCountersRecord? e2) {
    return e1?.docidcounters == e2?.docidcounters &&
        e1?.levelscounters == e2?.levelscounters &&
        e1?.count == e2?.count &&
        e1?.lastcompletedatcounters == e2?.lastcompletedatcounters;
  }

  @override
  int hash(LevelCountersRecord? e) => const ListEquality().hash([
        e?.docidcounters,
        e?.levelscounters,
        e?.count,
        e?.lastcompletedatcounters
      ]);

  @override
  bool isValidKey(Object? o) => o is LevelCountersRecord;
}
