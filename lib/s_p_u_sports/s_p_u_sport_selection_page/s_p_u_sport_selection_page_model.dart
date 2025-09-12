import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 's_p_u_sport_selection_page_widget.dart'
    show SPUSportSelectionPageWidget;
import 'package:flutter/material.dart';

class SPUSportSelectionPageModel
    extends FlutterFlowModel<SPUSportSelectionPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for SelectSportDropDown widget.
  String? selectSportDropDownValue;
  FormFieldController<String>? selectSportDropDownValueController;
  // State field(s) for SelectSportUserNameInput widget.
  FocusNode? selectSportUserNameInputFocusNode;
  TextEditingController? selectSportUserNameInputTextController;
  String? Function(BuildContext, String?)?
      selectSportUserNameInputTextControllerValidator;
  // State field(s) for attenspanslider widget.
  double? attenspansliderValue1;
  // State field(s) for senstolslider widget.
  double? senstolsliderValue;
  // State field(s) for attenspanslider widget.
  double? attenspansliderValue2;
  // Stores action output result for [Backend Call - API (PredictWorkout)] action in Button widget.
  ApiCallResponse? mLapicallresult;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  WorkoutPlansRecord? savedMLdoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectSportUserNameInputFocusNode?.dispose();
    selectSportUserNameInputTextController?.dispose();
  }
}
