import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import '../services/uid_service.dart';

//(change)="onChange(inputEl.value)"
//(input)="onChange(inputEl.value)"
//(blur)="onBlur()"

@Component(
    selector: 'custom-input',
    styleUrls: ['custom_input_component.css'],
    template: '''
      <input 
        #inputEl
        [id]="inputId" 
        type="text" 
        [value]="inputValue"
        [class.error]="!isValid"
        required
      />
      <label [attr.for]="inputId">
        <ng-content></ng-content>
      </label>
      <span class="error" [hidden]="isValid">Invalid field</span>
    ''',
    directives: [coreDirectives, formDirectives]
)
class CustomInputComponent implements ControlValueAccessor<String>, OnInit {
  String inputValue;

  final UidService _uid;

  @Input()
  bool disabled;

  bool isValid = true;

  @Input()
  String value;

  CustomInputComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String inputId;

  void ngOnInit () {
    if (inputId==null) {
      inputId = 'input_' + _uid.generate();
    }
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (String newValue) {
    inputValue = newValue;
    _onChecked.add(inputValue);

    if (inputValue.trim()=='') {
      isValid = false;
    }
    else {
      isValid = true;
    }
  }

  void onBlur() {
    if (inputValue==null || inputValue.trim()=='') {
      isValid = false;
    }
  }

  @override
  void writeValue(String newValue) {
    if (newValue == null) return;
    onChange(newValue);
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