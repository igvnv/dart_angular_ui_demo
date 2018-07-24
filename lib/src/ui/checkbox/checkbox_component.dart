part of ui;

@Component(
  selector: 'ui-checkbox',
  styleUrls: ['checkbox/checkbox_component.css'],
  template: '''
  <input 
    type="checkbox"
    [id]="checkboxId" 
    [checked]="checkboxValue"
    [disabled]="disabled"
    (change)="toggle()"
  >
  <label [attr.for]="checkboxId">
    <ng-content></ng-content>
  </label>
  ''',
  providers: [ClassProvider(UidService)]
)
class CheckboxComponent implements ControlValueAccessor<bool>, OnInit {
  bool checkboxValue;

  final UidService _uid;

  @Input()
  bool disabled;

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  CheckboxComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String checkboxId;

  void ngOnInit () {
    if (checkboxId==null) {
      checkboxId = 'checkbox_' + _uid.generate();
    }
  }

  /// Переключает состояние чекбокса (выбрано/не выбрано).
  void toggle () {
    setValue(!checkboxValue);
  }

  /// Устанавливает значение компонента.
  void setValue (bool value) {
    checkboxValue = value;
    _onChecked.add(checkboxValue);
  }

  @override
  void writeValue(bool isChecked) {
    if (isChecked == null) return;
    setValue(isChecked);
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