import 'package:angular/angular.dart';

import 'src/custom_form/custom_form_component.dart';
import 'src/material_form/material_form_component.dart';

import 'src/services/uid_service.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [CustomFormComponent, MaterialFormComponent],
  providers: [ClassProvider(UidService)]
)
class AppComponent {
  // Nothing here yet. All logic is in TodoListComponent.
}
