import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 's_p_u_badminton_page_widget.dart' show SPUBadmintonPageWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class SPUBadmintonPageModel extends FlutterFlowModel<SPUBadmintonPageWidget> {
  ///  Local state fields for this page.

  String badmintonnamepagestate = 'badminton';

  int selectedlevel = 0;

  bool showtimer = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Level1 widget.
  late ExpandableController level1ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs1 = 1800000;
  int timerMilliseconds1 = 1800000;
  String timerValue1 = StopWatchTimer.getDisplayTime(
    1800000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController1 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for Level2 widget.
  late ExpandableController level2ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs2 = 1800000;
  int timerMilliseconds2 = 1800000;
  String timerValue2 = StopWatchTimer.getDisplayTime(
    1800000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController2 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for Level3 widget.
  late ExpandableController level3ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs3 = 1800000;
  int timerMilliseconds3 = 1800000;
  String timerValue3 = StopWatchTimer.getDisplayTime(
    1800000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController3 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for Level4 widget.
  late ExpandableController level4ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs4 = 1800000;
  int timerMilliseconds4 = 1800000;
  String timerValue4 = StopWatchTimer.getDisplayTime(
    1800000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController4 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for level5 widget.
  late ExpandableController level5ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs5 = 1800000;
  int timerMilliseconds5 = 1800000;
  String timerValue5 = StopWatchTimer.getDisplayTime(
    1800000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController5 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    level1ExpandableController.dispose();
    timerController1.dispose();
    level2ExpandableController.dispose();
    timerController2.dispose();
    level3ExpandableController.dispose();
    timerController3.dispose();
    level4ExpandableController.dispose();
    timerController4.dispose();
    level5ExpandableController.dispose();
    timerController5.dispose();
  }
}
