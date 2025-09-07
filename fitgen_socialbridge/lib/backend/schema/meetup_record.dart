import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MeetupRecord extends FirestoreRecord {
  MeetupRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "meetup_sport" field.
  String? _meetupSport;
  String get meetupSport => _meetupSport ?? '';
  bool hasMeetupSport() => _meetupSport != null;

  // "meetup_date" field.
  DateTime? _meetupDate;
  DateTime? get meetupDate => _meetupDate;
  bool hasMeetupDate() => _meetupDate != null;

  // "meetup_time" field.
  DateTime? _meetupTime;
  DateTime? get meetupTime => _meetupTime;
  bool hasMeetupTime() => _meetupTime != null;

  // "meetup_location" field.
  LatLng? _meetupLocation;
  LatLng? get meetupLocation => _meetupLocation;
  bool hasMeetupLocation() => _meetupLocation != null;

  // "meetup_address" field.
  String? _meetupAddress;
  String get meetupAddress => _meetupAddress ?? '';
  bool hasMeetupAddress() => _meetupAddress != null;

  // "meetup_host" field.
  String? _meetupHost;
  String get meetupHost => _meetupHost ?? '';
  bool hasMeetupHost() => _meetupHost != null;

  // "meetup_attendance" field.
  int? _meetupAttendance;
  int get meetupAttendance => _meetupAttendance ?? 0;
  bool hasMeetupAttendance() => _meetupAttendance != null;

  void _initializeFields() {
    _meetupSport = snapshotData['meetup_sport'] as String?;
    _meetupDate = snapshotData['meetup_date'] as DateTime?;
    _meetupTime = snapshotData['meetup_time'] as DateTime?;
    _meetupLocation = snapshotData['meetup_location'] as LatLng?;
    _meetupAddress = snapshotData['meetup_address'] as String?;
    _meetupHost = snapshotData['meetup_host'] as String?;
    _meetupAttendance = castToType<int>(snapshotData['meetup_attendance']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meetup');

  static Stream<MeetupRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MeetupRecord.fromSnapshot(s));

  static Future<MeetupRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MeetupRecord.fromSnapshot(s));

  static MeetupRecord fromSnapshot(DocumentSnapshot snapshot) => MeetupRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MeetupRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MeetupRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MeetupRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MeetupRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMeetupRecordData({
  String? meetupSport,
  DateTime? meetupDate,
  DateTime? meetupTime,
  LatLng? meetupLocation,
  String? meetupAddress,
  String? meetupHost,
  int? meetupAttendance,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'meetup_sport': meetupSport,
      'meetup_date': meetupDate,
      'meetup_time': meetupTime,
      'meetup_location': meetupLocation,
      'meetup_address': meetupAddress,
      'meetup_host': meetupHost,
      'meetup_attendance': meetupAttendance,
    }.withoutNulls,
  );

  return firestoreData;
}

class MeetupRecordDocumentEquality implements Equality<MeetupRecord> {
  const MeetupRecordDocumentEquality();

  @override
  bool equals(MeetupRecord? e1, MeetupRecord? e2) {
    return e1?.meetupSport == e2?.meetupSport &&
        e1?.meetupDate == e2?.meetupDate &&
        e1?.meetupTime == e2?.meetupTime &&
        e1?.meetupLocation == e2?.meetupLocation &&
        e1?.meetupAddress == e2?.meetupAddress &&
        e1?.meetupHost == e2?.meetupHost &&
        e1?.meetupAttendance == e2?.meetupAttendance;
  }

  @override
  int hash(MeetupRecord? e) => const ListEquality().hash([
        e?.meetupSport,
        e?.meetupDate,
        e?.meetupTime,
        e?.meetupLocation,
        e?.meetupAddress,
        e?.meetupHost,
        e?.meetupAttendance
      ]);

  @override
  bool isValidKey(Object? o) => o is MeetupRecord;
}
