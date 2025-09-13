import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

int roundClamp1to5(double? value) {
  // Default to 3 if null or not a normal number
  final v = (value == null || !value.isFinite) ? 3.0 : value;
  // Round to nearest integer
  final r = v.round();
  // Clamp to 1..5
  if (r < 1) return 1;
  if (r > 5) return 5;
  return r;
}
