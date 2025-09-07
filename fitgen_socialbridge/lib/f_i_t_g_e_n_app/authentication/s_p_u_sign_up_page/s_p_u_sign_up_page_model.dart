import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 's_p_u_sign_up_page_widget.dart' show SPUSignUpPageWidget;
import 'package:flutter/material.dart';

class SPUSignUpPageModel extends FlutterFlowModel<SPUSignUpPageWidget> {
  ///  Local state fields for this page.

  FFUploadedFile? uploadImage;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  bool isDataUploading_uploadedImageSignupLocalState = false;
  FFUploadedFile uploadedLocalFile_uploadedImageSignupLocalState =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  // State field(s) for SPUSignupUserNameInput widget.
  FocusNode? sPUSignupUserNameInputFocusNode;
  TextEditingController? sPUSignupUserNameInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignupUserNameInputTextControllerValidator;
  // State field(s) for SPUSignupGuardianNameInput widget.
  FocusNode? sPUSignupGuardianNameInputFocusNode;
  TextEditingController? sPUSignupGuardianNameInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignupGuardianNameInputTextControllerValidator;
  // State field(s) for SPUSignUpEmailInput widget.
  FocusNode? sPUSignUpEmailInputFocusNode;
  TextEditingController? sPUSignUpEmailInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignUpEmailInputTextControllerValidator;
  // State field(s) for SPUSignUpPasswordInput widget.
  FocusNode? sPUSignUpPasswordInputFocusNode;
  TextEditingController? sPUSignUpPasswordInputTextController;
  late bool sPUSignUpPasswordInputVisibility;
  String? Function(BuildContext, String?)?
      sPUSignUpPasswordInputTextControllerValidator;
  // State field(s) for SPUSignUpPasswordConfirmText widget.
  FocusNode? sPUSignUpPasswordConfirmTextFocusNode;
  TextEditingController? sPUSignUpPasswordConfirmTextTextController;
  late bool sPUSignUpPasswordConfirmTextVisibility;
  String? Function(BuildContext, String?)?
      sPUSignUpPasswordConfirmTextTextControllerValidator;
  // State field(s) for SPUSignUpNumberInput widget.
  FocusNode? sPUSignUpNumberInputFocusNode;
  TextEditingController? sPUSignUpNumberInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignUpNumberInputTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // State field(s) for SPUSignUpAgeInput widget.
  FocusNode? sPUSignUpAgeInputFocusNode;
  TextEditingController? sPUSignUpAgeInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignUpAgeInputTextControllerValidator;
  // State field(s) for SPUSignUpWeightInput widget.
  FocusNode? sPUSignUpWeightInputFocusNode;
  TextEditingController? sPUSignUpWeightInputTextController;
  String? Function(BuildContext, String?)?
      sPUSignUpWeightInputTextControllerValidator;
  // State field(s) for SPUSignUpGenderDropDown widget.
  String? sPUSignUpGenderDropDownValue;
  FormFieldController<String>? sPUSignUpGenderDropDownValueController;
  // State field(s) for SPUSignUpDisabilityDropDown widget.
  String? sPUSignUpDisabilityDropDownValue;
  FormFieldController<String>? sPUSignUpDisabilityDropDownValueController;
  bool isDataUploading_uploadImageSignupFirebase = false;
  FFUploadedFile uploadedLocalFile_uploadImageSignupFirebase =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadImageSignupFirebase = '';

  @override
  void initState(BuildContext context) {
    sPUSignUpPasswordInputVisibility = false;
    sPUSignUpPasswordConfirmTextVisibility = false;
  }

  @override
  void dispose() {
    sPUSignupUserNameInputFocusNode?.dispose();
    sPUSignupUserNameInputTextController?.dispose();

    sPUSignupGuardianNameInputFocusNode?.dispose();
    sPUSignupGuardianNameInputTextController?.dispose();

    sPUSignUpEmailInputFocusNode?.dispose();
    sPUSignUpEmailInputTextController?.dispose();

    sPUSignUpPasswordInputFocusNode?.dispose();
    sPUSignUpPasswordInputTextController?.dispose();

    sPUSignUpPasswordConfirmTextFocusNode?.dispose();
    sPUSignUpPasswordConfirmTextTextController?.dispose();

    sPUSignUpNumberInputFocusNode?.dispose();
    sPUSignUpNumberInputTextController?.dispose();

    textFieldFocusNode?.dispose();
    textController5?.dispose();

    sPUSignUpAgeInputFocusNode?.dispose();
    sPUSignUpAgeInputTextController?.dispose();

    sPUSignUpWeightInputFocusNode?.dispose();
    sPUSignUpWeightInputTextController?.dispose();
  }
}
