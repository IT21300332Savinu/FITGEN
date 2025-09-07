import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 's_p_u_football_page_widget.dart' show SPUFootballPageWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class SPUFootballPageModel extends FlutterFlowModel<SPUFootballPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Level1 widget.
  late ExpandableController level1ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs1 = 0;
  int timerMilliseconds1 = 0;
  String timerValue1 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController1 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // State field(s) for Level2 widget.
  late ExpandableController level2ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs2 = 0;
  int timerMilliseconds2 = 0;
  String timerValue2 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController2 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // State field(s) for Level3 widget.
  late ExpandableController level3ExpandableController;

  // State field(s) for Timer widget.
  final timerInitialTimeMs3 = 0;
  int timerMilliseconds3 = 0;
  String timerValue3 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController3 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController1;

  // State field(s) for Timer widget.
  final timerInitialTimeMs4 = 0;
  int timerMilliseconds4 = 0;
  String timerValue4 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController4 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController2;

  // State field(s) for Timer widget.
  final timerInitialTimeMs5 = 0;
  int timerMilliseconds5 = 0;
  String timerValue5 = StopWatchTimer.getDisplayTime(
    0,
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
    expandableExpandableController1.dispose();
    timerController4.dispose();
    expandableExpandableController2.dispose();
    timerController5.dispose();
  }
}
