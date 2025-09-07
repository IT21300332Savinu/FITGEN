import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MeetupReserveRecord extends FirestoreRecord {
  MeetupReserveRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "mr_meetup" field.
  DocumentReference? _mrMeetup;
  DocumentReference? get mrMeetup => _mrMeetup;
  bool hasMrMeetup() => _mrMeetup != null;

  // "mr_reservation" field.
  bool? _mrReservation;
  bool get mrReservation => _mrReservation ?? false;
  bool hasMrReservation() => _mrReservation != null;

  // "mr_date" field.
  DateTime? _mrDate;
  DateTime? get mrDate => _mrDate;
  bool hasMrDate() => _mrDate != null;

  // "mr_creator" field.
  DocumentReference? _mrCreator;
  DocumentReference? get mrCreator => _mrCreator;
  bool hasMrCreator() => _mrCreator != null;

  // "mr_time" field.
  DateTime? _mrTime;
  DateTime? get mrTime => _mrTime;
  bool hasMrTime() => _mrTime != null;

  // "meetup_loc" field.
  LatLng? _meetupLoc;
  LatLng? get meetupLoc => _meetupLoc;
  bool hasMeetupLoc() => _meetupLoc != null;

  // "mr_sport" field.
  String? _mrSport;
  String get mrSport => _mrSport ?? '';
  bool hasMrSport() => _mrSport != null;

  // "mr_host" field.
  String? _mrHost;
  String get mrHost => _mrHost ?? '';
  bool hasMrHost() => _mrHost != null;

  void _initializeFields() {
    _mrMeetup = snapshotData['mr_meetup'] as DocumentReference?;
    _mrReservation = snapshotData['mr_reservation'] as bool?;
    _mrDate = snapshotData['mr_date'] as DateTime?;
    _mrCreator = snapshotData['mr_creator'] as DocumentReference?;
    _mrTime = snapshotData['mr_time'] as DateTime?;
    _meetupLoc = snapshotData['meetup_loc'] as LatLng?;
    _mrSport = snapshotData['mr_sport'] as String?;
    _mrHost = snapshotData['mr_host'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meetup_reserve');

  static Stream<MeetupReserveRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MeetupReserveRecord.fromSnapshot(s));

  static Future<MeetupReserveRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MeetupReserveRecord.fromSnapshot(s));

  static MeetupReserveRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MeetupReserveRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MeetupReserveRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MeetupReserveRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MeetupReserveRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MeetupReserveRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMeetupReserveRecordData({
  DocumentReference? mrMeetup,
  bool? mrReservation,
  DateTime? mrDate,
  DocumentReference? mrCreator,
  DateTime? mrTime,
  LatLng? meetupLoc,
  String? mrSport,
  String? mrHost,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'mr_meetup': mrMeetup,
      'mr_reservation': mrReservation,
      'mr_date': mrDate,
      'mr_creator': mrCreator,
      'mr_time': mrTime,
      'meetup_loc': meetupLoc,
      'mr_sport': mrSport,
      'mr_host': mrHost,
    }.withoutNulls,
  );

  return firestoreData;
}

class MeetupReserveRecordDocumentEquality
    implements Equality<MeetupReserveRecord> {
  const MeetupReserveRecordDocumentEquality();

  @override
  bool equals(MeetupReserveRecord? e1, MeetupReserveRecord? e2) {
    return e1?.mrMeetup == e2?.mrMeetup &&
        e1?.mrReservation == e2?.mrReservation &&
        e1?.mrDate == e2?.mrDate &&
        e1?.mrCreator == e2?.mrCreator &&
        e1?.mrTime == e2?.mrTime &&
        e1?.meetupLoc == e2?.meetupLoc &&
        e1?.mrSport == e2?.mrSport &&
        e1?.mrHost == e2?.mrHost;
  }

  @override
  int hash(MeetupReserveRecord? e) => const ListEquality().hash([
        e?.mrMeetup,
        e?.mrReservation,
        e?.mrDate,
        e?.mrCreator,
        e?.mrTime,
        e?.meetupLoc,
        e?.mrSport,
        e?.mrHost
      ]);

  @override
  bool isValidKey(Object? o) => o is MeetupReserveRecord;
}
