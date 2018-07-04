import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import '../services/uid_service.dart';

@Component(
  selector: 'custom-checkbox',
  styleUrls: ['custom_checkbox_component.css'],
  template: '''
  <input 
    type="checkbox"
    [id]="checkboxId" 
    (change)="toggle()"
    [checked]="checkboxValue"
  >
  <label [attr.for]="checkboxId">
    <ng-content></ng-content>
  </label>
  ''',
  directives: [coreDirectives, formDirectives]
)
class CustomCheckboxComponent implements ControlValueAccessor<bool>, OnInit {
  bool checkboxValue;

  final UidService _uid;

  @Input()
  bool disabled;

  CustomCheckboxComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String checkboxId;

  void ngOnInit () {
    if (checkboxId==null) {
      checkboxId = 'checkbox_' + _uid.generate();
    }
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (bool value) {
    checkboxValue = value;
    _onChecked.add(checkboxValue);
  }

  void toggle () {
    checkboxValue = !checkboxValue;
    _onChecked.add(checkboxValue);
  }

  @override
  void writeValue(bool isChecked) {
    if (isChecked == null) return;
    onChange(isChecked);
  }

  @override
  void registerOnChange(callback) {
    onChecked.listen((checked) => callback(checked));
  }

  @override
  void registerOnTouched(callback) {
    _onTouched = callback;
  }
  Function _onTouched;

  @HostListener('blur')
  void handleBlur(Event event) {
    _onTouched?.call();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
  }
}