import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 's_p_u_all_meetup_page_widget.dart' show SPUAllMeetupPageWidget;
import 'package:flutter/material.dart';

class SPUAllMeetupPageModel extends FlutterFlowModel<SPUAllMeetupPageWidget> {
  ///  Local state fields for this page.

  LatLng? displayLocationMeetupPage;

  bool goingButton = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
