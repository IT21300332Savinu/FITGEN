import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 's_p_u_login_page_widget.dart' show SPULoginPageWidget;
import 'package:flutter/material.dart';

class SPULoginPageModel extends FlutterFlowModel<SPULoginPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for SPUemailAddress widget.
  FocusNode? sPUemailAddressFocusNode;
  TextEditingController? sPUemailAddressTextController;
  String? Function(BuildContext, String?)?
      sPUemailAddressTextControllerValidator;
  // State field(s) for SPUpassword widget.
  FocusNode? sPUpasswordFocusNode;
  TextEditingController? sPUpasswordTextController;
  late bool sPUpasswordVisibility;
  String? Function(BuildContext, String?)? sPUpasswordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    sPUpasswordVisibility = false;
  }

  @override
  void dispose() {
    sPUemailAddressFocusNode?.dispose();
    sPUemailAddressTextController?.dispose();

    sPUpasswordFocusNode?.dispose();
    sPUpasswordTextController?.dispose();
  }
}
