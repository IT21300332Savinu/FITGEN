import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 's_p_u_home_page_widget.dart' show SPUHomePageWidget;
import 'package:flutter/material.dart';

class SPUHomePageModel extends FlutterFlowModel<SPUHomePageWidget> {
  ///  Local state fields for this page.

  DateTime? meetupDatesHome;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {}
}
