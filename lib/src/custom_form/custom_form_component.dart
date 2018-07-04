import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import '../custom_checkbox/custom_checkbox_component.dart';
import '../custon_input/custom_input_component.dart';
import '../custom_radio/custom_radio_component.dart';

@Component(
  selector: 'custom-form',
  templateUrl: 'custom_form_component.html',
  styleUrls: ['custom_form_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    CustomCheckboxComponent,
    CustomRadioComponent,
    CustomInputComponent
  ]
)
class CustomFormComponent {
  bool accept = true;
  bool accept2 = false;
  String firstName = 'Ivan';
  String lastName;
  String role = 'director';
  final List<Map<String, String>> roles = [
    {'value': 'director', 'label': 'Funeral Director'},
    {'value': 'cemetery', 'label': 'Cemetery'},
  ];
}