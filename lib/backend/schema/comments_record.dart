import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CommentsRecord extends FirestoreRecord {
  CommentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "time" field.
  DateTime? _time;
  DateTime? get time => _time;
  bool hasTime() => _time != null;

  // "meetupref" field.
  DocumentReference? _meetupref;
  DocumentReference? get meetupref => _meetupref;
  bool hasMeetupref() => _meetupref != null;

  // "spuserref" field.
  DocumentReference? _spuserref;
  DocumentReference? get spuserref => _spuserref;
  bool hasSpuserref() => _spuserref != null;

  // "commentor" field.
  String? _commentor;
  String get commentor => _commentor ?? '';
  bool hasCommentor() => _commentor != null;

  void _initializeFields() {
    _comment = snapshotData['comment'] as String?;
    _time = snapshotData['time'] as DateTime?;
    _meetupref = snapshotData['meetupref'] as DocumentReference?;
    _spuserref = snapshotData['spuserref'] as DocumentReference?;
    _commentor = snapshotData['commentor'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('comments');

  static Stream<CommentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CommentsRecord.fromSnapshot(s));

  static Future<CommentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CommentsRecord.fromSnapshot(s));

  static CommentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CommentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CommentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CommentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CommentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CommentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCommentsRecordData({
  String? comment,
  DateTime? time,
  DocumentReference? meetupref,
  DocumentReference? spuserref,
  String? commentor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'comment': comment,
      'time': time,
      'meetupref': meetupref,
      'spuserref': spuserref,
      'commentor': commentor,
    }.withoutNulls,
  );

  return firestoreData;
}

class CommentsRecordDocumentEquality implements Equality<CommentsRecord> {
  const CommentsRecordDocumentEquality();

  @override
  bool equals(CommentsRecord? e1, CommentsRecord? e2) {
    return e1?.comment == e2?.comment &&
        e1?.time == e2?.time &&
        e1?.meetupref == e2?.meetupref &&
        e1?.spuserref == e2?.spuserref &&
        e1?.commentor == e2?.commentor;
  }

  @override
  int hash(CommentsRecord? e) => const ListEquality()
      .hash([e?.comment, e?.time, e?.meetupref, e?.spuserref, e?.commentor]);

  @override
  bool isValidKey(Object? o) => o is CommentsRecord;
}
