import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SpecialUserRecord extends FirestoreRecord {
  SpecialUserRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  // "disability" field.
  String? _disability;
  String get disability => _disability ?? '';
  bool hasDisability() => _disability != null;

  // "caretaker_name" field.
  String? _caretakerName;
  String get caretakerName => _caretakerName ?? '';
  bool hasCaretakerName() => _caretakerName != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "weight_kg" field.
  int? _weightKg;
  int get weightKg => _weightKg ?? 0;
  bool hasWeightKg() => _weightKg != null;

  // "age_years" field.
  int? _ageYears;
  int get ageYears => _ageYears ?? 0;
  bool hasAgeYears() => _ageYears != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _uid = snapshotData['uid'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _gender = snapshotData['gender'] as String?;
    _disability = snapshotData['disability'] as String?;
    _caretakerName = snapshotData['caretaker_name'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _address = snapshotData['address'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _weightKg = castToType<int>(snapshotData['weight_kg']);
    _ageYears = castToType<int>(snapshotData['age_years']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('special_user');

  static Stream<SpecialUserRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SpecialUserRecord.fromSnapshot(s));

  static Future<SpecialUserRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SpecialUserRecord.fromSnapshot(s));

  static SpecialUserRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SpecialUserRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SpecialUserRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SpecialUserRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SpecialUserRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SpecialUserRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSpecialUserRecordData({
  String? email,
  String? displayName,
  String? uid,
  String? phoneNumber,
  String? gender,
  String? disability,
  String? caretakerName,
  DateTime? createdTime,
  String? address,
  String? photoUrl,
  int? weightKg,
  int? ageYears,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'uid': uid,
      'phone_number': phoneNumber,
      'gender': gender,
      'disability': disability,
      'caretaker_name': caretakerName,
      'created_time': createdTime,
      'address': address,
      'photo_url': photoUrl,
      'weight_kg': weightKg,
      'age_years': ageYears,
    }.withoutNulls,
  );

  return firestoreData;
}

class SpecialUserRecordDocumentEquality implements Equality<SpecialUserRecord> {
  const SpecialUserRecordDocumentEquality();

  @override
  bool equals(SpecialUserRecord? e1, SpecialUserRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.uid == e2?.uid &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.gender == e2?.gender &&
        e1?.disability == e2?.disability &&
        e1?.caretakerName == e2?.caretakerName &&
        e1?.createdTime == e2?.createdTime &&
        e1?.address == e2?.address &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.weightKg == e2?.weightKg &&
        e1?.ageYears == e2?.ageYears;
  }

  @override
  int hash(SpecialUserRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.uid,
        e?.phoneNumber,
        e?.gender,
        e?.disability,
        e?.caretakerName,
        e?.createdTime,
        e?.address,
        e?.photoUrl,
        e?.weightKg,
        e?.ageYears
      ]);

  @override
  bool isValidKey(Object? o) => o is SpecialUserRecord;
}
