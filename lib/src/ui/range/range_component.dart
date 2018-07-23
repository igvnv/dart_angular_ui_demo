part of ui;

//typedef RangeValue = class { num from; };

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

  @Input()
  num minValue;

  @Input()
  num maxValue;

  @Input()
  num step;

  @Input()
  RangeValue value;

  double offsetFrom = 0.0;
  double offsetTo = 100.0;

  @ViewChild('fromSelector')
  SpanElement fromSelector;

  @ViewChild('toSelector')
  SpanElement toSelector;

  final HtmlElement _rangeElement;

  RangeComponent(NgControl control, this._rangeElement) {
    control.valueAccessor = this;
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (RangeValue newValue) {
    inputValue = newValue;
    _onChecked.add(inputValue);
  }

  @override
  void ngOnInit() {
    if (inputValue==null) {
      inputValue = RangeValue(minValue, maxValue);
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
    // слайдер
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

  @override
  void writeValue(RangeValue newValue) {
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
    // @todo Реализовать
  }

  int _stepRound(double x, int step) {
    double remainder = x % step;

    if (remainder == 0.00) {
      return x.toInt();
    }
    else {
      return x ~/ step * step + (remainder > step / 2 ? step : 0);
    }
  }
}