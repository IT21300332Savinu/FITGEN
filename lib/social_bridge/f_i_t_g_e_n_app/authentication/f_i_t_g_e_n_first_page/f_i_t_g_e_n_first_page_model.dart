import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'f_i_t_g_e_n_first_page_widget.dart' show FITGENFirstPageWidget;
import 'package:flutter/material.dart';

class FITGENFirstPageModel extends FlutterFlowModel<FITGENFirstPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
