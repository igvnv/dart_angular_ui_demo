library ui;

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'uid_service.dart';

part 'button/button_component.dart';
part 'checkbox/checkbox_component.dart';
part 'date/date_component.dart';
part 'radio/radio_component.dart';
part 'range/range_component.dart';
part 'input/input_component.dart';
part 'select/select_component.dart';
part 'time/time_component.dart';

const uiDirectives = [
  ButtonComponent,
  CheckboxComponent,
  DateComponent,
  InputComponent,
  RadioComponent,
  RangeComponent,
  SelectComponent,
  TimeComponent
];

@Injectable()
class Ui {}