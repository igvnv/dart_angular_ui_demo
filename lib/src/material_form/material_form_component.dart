import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';

@Component(
  selector: 'material-form',
  templateUrl: 'material_form_component.html',
  styleUrls: ['material_form_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    materialInputDirectives,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    MaterialCheckboxComponent
  ]
)

class MaterialFormComponent {
  bool accept = false;
  String firstName = 'Ivan';
  String lastName;
  String role = 'director';
  final List<Map<String, String>> roles = [
    {'value': 'director', 'label': 'Funeral Director'},
    {'value': 'cemetery', 'label': 'Cemetery'},
  ];
}
