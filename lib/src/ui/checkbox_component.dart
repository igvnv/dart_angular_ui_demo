part of ui;

@Component(
  selector: 'ui-checkbox',
  styleUrls: ['checkbox_component.css'],
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
  '''
)
class CheckboxComponent implements ControlValueAccessor<bool>, OnInit {
  bool checkboxValue;

  final UidService _uid;

  @Input()
  bool disabled;

  CheckboxComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String checkboxId;

  void ngOnInit () {
    if (checkboxId==null) {
      checkboxId = 'checkbox_' + _uid.generate();
    }
  }

  void toggle () {
    checkboxValue = !checkboxValue;
    _onChecked.add(checkboxValue);
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (bool value) {
    checkboxValue = value;
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