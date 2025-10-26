import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 's_p_u_badminton_page_widget.dart' show SPUBadmintonPageWidget;
import 'package:flutter/material.dart';

class SPUBadmintonPageModel extends FlutterFlowModel<SPUBadmintonPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for BadmintonPages widget.
  PageController? badmintonPagesController;

  int get badmintonPagesCurrentIndex => badmintonPagesController != null &&
          badmintonPagesController!.hasClients &&
          badmintonPagesController!.page != null
      ? badmintonPagesController!.page!.round()
      : 0;
  // State field(s) for Timer widget.
  final timerInitialTimeMs1 = 10800;
  int timerMilliseconds1 = 10800;
  String timerValue1 = StopWatchTimer.getDisplayTime(
    10800,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController1 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

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
    timerController1.dispose();
    timerController2.dispose();
    timerController3.dispose();
    timerController4.dispose();
    timerController5.dispose();
  }
}
