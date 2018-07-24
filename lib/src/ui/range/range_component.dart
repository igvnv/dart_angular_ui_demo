part of ui;

class RangeValue {
  num from;
  num to;

  RangeValue(this.from, this.to);
}

@Component(
  selector: 'ui-range',
  styleUrls: ['range/range_component.css'],
  template: '''
    <span class="min">{{minValue}}</span>
    <span class="max">{{maxValue}}</span>

    <span *ngIf="inputValue!=null" class="selector from" #fromSelector [style.left.%]="offsetFrom"><span>{{inputValue.from}}</span></span>
    <span *ngIf="inputValue!=null" class="selector to" #toSelector [style.left.%]="offsetTo"><span>{{inputValue.to}}</span></span>

    <span 
      class="rangeSelected" 
      [style.left.%]="offsetFrom"
      [style.width.%]="offsetTo - offsetFrom"
    ></span>
    <span class="rangeAll"></span>
  ''',
  directives: [coreDirectives, formDirectives]
)
class RangeComponent  implements ControlValueAccessor<RangeValue>, OnInit {
  RangeValue inputValue;

  /// Минимальное допустимое значение.
  @Input()
  num minValue;

  /// Максимальное допустимое значение.
  @Input()
  num maxValue;

  /// Шаг, с которым возможно изменение диапазона.
  @Input()
  num step;

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  /// Сдвиг селектора "от" по горизонтали в процентах (сервисный атрибут).
  double offsetFrom = 0.0;

  /// Сдвиг селектора "до" по горизонтали в процентах (сервисный атрибут).
  double offsetTo = 100.0;

  @ViewChild('fromSelector')
  SpanElement fromSelector;

  @ViewChild('toSelector')
  SpanElement toSelector;

  final HtmlElement _rangeElement;

  RangeComponent(NgControl control, this._rangeElement) {
    control.valueAccessor = this;
  }

  /// Устанавливает значение компонента.
  void setValue (RangeValue newValue) {
    inputValue = newValue;
    _onChecked.add(inputValue);
  }

  @override
  void ngOnInit() {
    if (inputValue==null) {
      inputValue = RangeValue(minValue, maxValue);
    }
    // Устанавливаем бегунки согласно переданным значениям
    else {
      offsetFrom = 100 / (maxValue - minValue) * (inputValue.from - minValue).abs();
      offsetTo = 100 / (maxValue - minValue) * (inputValue.to - minValue).abs();
    }
  }

  SpanElement _activeSelector;

  @HostListener('mousedown')
  void onMoveStart(MouseEvent event) {
    if (fromSelector.contains(event.target)) {
      _activeSelector = fromSelector;
    }
    else if (toSelector.contains(event.target)) {
      _activeSelector = toSelector;
    }
    // Нажатие на свободную область, перемещаем в это место подходящий
    // слайдер.
    else {
      int clickOffsetLeft = event.client.x - _rangeElement.offsetLeft;
      double percentage = 100 / _rangeElement.clientWidth * (clickOffsetLeft);

      if (clickOffsetLeft<fromSelector.offsetLeft) {
        offsetFrom = percentage;
        inputValue.from = _stepRound((maxValue - minValue) / 100 * percentage + minValue, step);
      }
      else {
        offsetTo = percentage;
        inputValue.to = _stepRound((maxValue - minValue) / 100 * percentage + minValue, step);
      }
    }
  }

  @HostListener('mouseup')
  @HostListener('mouseleave')
  void onMoveEnd(MouseEvent event) {
    _activeSelector = null;
  }

  @HostListener('mousemove')
  void onMove(MouseEvent event) {
    if (_activeSelector==null) return;

    event.preventDefault();
    event.stopPropagation();

    int fullWidth = _rangeElement.clientWidth;
    double percentage = 100 / fullWidth * (event.client.x - _rangeElement.offsetLeft);

    if (_activeSelector==fromSelector) {
      if (percentage>offsetTo) return;
      if (percentage<0.0) percentage = 0.0;
      offsetFrom = percentage;

      inputValue.from = _stepRound((maxValue - minValue) / 100 * percentage + minValue, step);
    }

    if (_activeSelector==toSelector) {
      if (percentage<offsetFrom) return;
      if (percentage>100.0) percentage = 100.0;
      offsetTo = percentage;

      inputValue.to = _stepRound((maxValue - minValue) / 100 * percentage + minValue, step);
    }
  }

  /// Округление значения с шагом [step]
  /// Примеры:
  /// * _stepRound(12.2, 5) -> 12
  /// * _stepRound(13.6, 5) -> 15
  int _stepRound(double value, int step) {
    double remainder = value % step;

    if (remainder == 0.00) {
      return value.toInt();
    }
    else {
      return value ~/ step * step + (remainder > step / 2 ? step : 0);
    }
  }

  @override
  void writeValue(RangeValue newValue) {
    if (newValue == null) return;

    setValue(newValue);
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
    // @todo Реализовать?
  }
}