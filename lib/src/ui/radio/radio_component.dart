part of ui;

@Component(
  selector: 'ui-radio',
  styleUrls: ['radio/radio_component.css'],
  template: '''
  <input 
    type="radio"
    [id]="radioId"
    [value]="value"
    [checked]="radioValue==value"
    (change)="onChange(value)"
    [disabled]="disabled"
  >
  <label [attr.for]="radioId">
    <ng-content></ng-content>
  </label>
  ''',
)
class RadioComponent implements ControlValueAccessor<String>, OnInit {
  String radioValue;

  final UidService _uid;

  @Input()
  bool disabled;

  @Input()
  String value;

  RadioComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String radioId;

  void ngOnInit () {
    if (radioId==null) {
      radioId = 'radio_' + _uid.generate();
    }
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (String newValue) {
    radioValue = newValue;
    _onChecked.add(radioValue);
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