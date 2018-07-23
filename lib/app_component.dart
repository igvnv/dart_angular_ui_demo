//import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'src/services/uid_service.dart';
import 'src/ui/ui.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    formDirectives,
    uiDirectives,
  ],
  providers: [ClassProvider(UidService)]
)
class AppComponent implements OnInit {
  bool checkboxValue = true;
  String radioValue = 'one';
  String inputValue = 'test';

  Map<String, String> selectOptions = {
    'one': 'First Option',
    'two': 'Second Option',
    'three': 'Third Option'
  };
  String selectValue = '';
  DateTime timeValue = new DateTime(2018, 06, 12, 15, 45);
//  DateTime timeValue = new DateTime.now();
//  DateTime timeValue;

  bool disabled = false;

  RangeValue range;

  void ngOnInit() {
//    Future.delayed(const Duration(seconds: 3), () => disabled = true);
  }
}