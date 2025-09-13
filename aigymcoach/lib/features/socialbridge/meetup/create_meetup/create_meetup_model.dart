import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'create_meetup_widget.dart' show CreateMeetupWidget;
import 'package:flutter/material.dart';

class CreateMeetupModel extends FlutterFlowModel<CreateMeetupWidget> {
  ///  Local state fields for this component.

  String selectedAddress = 'sliit, malabe';

  LatLng? selectedLatLng;

  DateTime? selectedDate;

  DateTime? selectedTime;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for createMeetupSportDropDown widget.
  String? createMeetupSportDropDownValue;
  FormFieldController<String>? createMeetupSportDropDownValueController;
  // State field(s) for PlacePicker widget.
  FFPlace placePickerValue = FFPlace();
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  DateTime? datePicked1;
  DateTime? datePicked2;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Action blocks.
  Future storeUserInput(BuildContext context) async {
    selectedLatLng = selectedLatLng;
    selectedAddress = selectedAddress;
  }
}
