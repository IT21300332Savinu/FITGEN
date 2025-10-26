import '/flutter_flow/flutter_flow_util.dart';
import 'update_password_component_widget.dart'
    show UpdatePasswordComponentWidget;
import 'package:flutter/material.dart';

class UpdatePasswordComponentModel
    extends FlutterFlowModel<UpdatePasswordComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for newPWD widget.
  FocusNode? newPWDFocusNode;
  TextEditingController? newPWDTextController;
  late bool newPWDVisibility;
  String? Function(BuildContext, String?)? newPWDTextControllerValidator;
  // State field(s) for confirmnewPWD widget.
  FocusNode? confirmnewPWDFocusNode;
  TextEditingController? confirmnewPWDTextController;
  late bool confirmnewPWDVisibility;
  String? Function(BuildContext, String?)? confirmnewPWDTextControllerValidator;

  @override
  void initState(BuildContext context) {
    newPWDVisibility = false;
    confirmnewPWDVisibility = false;
  }

  @override
  void dispose() {
    newPWDFocusNode?.dispose();
    newPWDTextController?.dispose();

    confirmnewPWDFocusNode?.dispose();
    confirmnewPWDTextController?.dispose();
  }
}
