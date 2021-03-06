part of ui;

@Component(
  selector: 'ui-time',
  styleUrls: ['time/time_component.css'],
  template: '''
    <div 
      class="input"
      [class.error]="!isValid"
      [class.disabled]="disabled"
    >
      <span 
        class="label"
        [class.raised]="timeValue!=null"
        [tabindex]="tabindex"
        (focus)="showForm()"
      >
        <ng-content></ng-content> <span *ngIf="required">*</span>
      </span>
      <span 
        class="currentValue"
        (click)="toggleForm()"
      >{{timeValue | date:'hh:mm a'}}</span>
    </div>
    <div class="timeSelector" [class.open]="formOpened">
      <ui-input 
        #hoursElement 
        [(ngModel)]="hours" 
        [pattern]="'[^0-9]+'"
        [suggest]="suggestHours"
      ></ui-input>
      <ui-input 
        [(ngModel)]="minutes" 
        [pattern]="'[^0-9]+'"
        [suggest]="suggestMinutes"
      ></ui-input>
      <ui-select [(ngModel)]="timePeriod" [options]="{'am': 'AM', 'pm': 'PM'}"></ui-select>
      <button 
        type="button" 
        tabindex="0"
        (click)="saveChanges()" 
        [disabled]="hours=='' || minutes=='' || timePeriod==null"
      >OK</button>
    </div>
    <span class="error" *ngIf="!isValid">{{invalidMessage}}</span>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    ButtonComponent,
    InputComponent,
    SelectComponent
  ],
  pipes: [commonPipes]
)
class TimeComponent implements ControlValueAccessor<DateTime>, OnDestroy {
  DateTime timeValue;

  /// Список, который будет отображаться в подсказке выбора часа.
  List<String> suggestHours =
                  ['0', '1', '2','3', '4', '5', '6', '7', '8', '9', '10', '11'];
  /// Список, который будет отображаться в подсказке выбора минут.
  List<String> suggestMinutes = ['00', '15', '30', '45'];

  int _hours;
  String get hours => _hours!=null ? _hours.toString() : '';
  set hours(String hours) {
    if (hours==null || hours.isEmpty) return;

    _hours = int.parse(hours);
    if (_hours > 11) _hours = 11;
    else if (_hours<0) _hours = 0;
  }

  int _minutes;
  String get minutes => _minutes!=null ? _minutes.toString() : '';
  set minutes(String minutes) {
    if (minutes==null || minutes.isEmpty) return;

    _minutes = int.parse(minutes);
    if (_minutes > 59) _minutes = 59;
    else if (_minutes<0) _minutes = 0;
  }

  /// Временной промежуток (AM, PM).
  String timePeriod;

  /// Ссылка на HTML элемент инпута выбора часа.
  @ViewChild('hoursElement')
  InputComponent hoursElement;

  /// Ссылка на HTML элемент инпута.
  final HtmlElement _el;

  @Input()
  int tabindex = 0;

  bool _disabled = false;
  @Input()
  set disabled(bool disabled) {
    _disabled = disabled;

    if (_disabled) {
      hideForm();
    }
  }

  get disabled => _disabled;


  @Input()
  bool required = false;

  @Input()
  String invalidMessage = 'Invalid field';

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  TimeComponent(NgControl control, this._el) {
    control.valueAccessor = this;
  }

  bool isValid = true;

  /// Открыта ли на данный момент форма ввода времни.
  bool formOpened = false;

  /// Открывает/закрывает форму ввода времени.
  void toggleForm() {
    if (formOpened) {
      hideForm();
    }
    else {
      showForm();
    }
  }

  // При раскрытом списке вариантов включаем обработку кликов для скрытия списка
  // при клике вне компонента.
  StreamSubscription<MouseEvent> _clickOutsideListener;

  /// Открывает форму ввода времени.
  void showForm() {
    if (_disabled) return;

    formOpened = true;
    hoursElement.focus();

    _clickOutsideListener = document.onClick.listen((MouseEvent event) {
      if (!_el.contains(event.target)) {
        formOpened = false;
      }
    });
  }

  /// Скрывает форму ввода времени.
  void hideForm() {
    formOpened = false;
    _clickOutsideListener?.cancel();
  }

  void ngOnDestroy() {
    _clickOutsideListener?.cancel();
  }

  /// Устанавливает значение компонента.
  void setValue (DateTime newValue) {
    timeValue = newValue;
    _onChecked.add(timeValue);
    _validate();

    // Приводим часы к 12-часовому формату
    hours = (timeValue.hour < 12 ? timeValue.hour : timeValue.hour - 12)
        .toString();
    minutes = timeValue.minute.toString();
    timePeriod = timeValue.hour < 12 ? 'am' : 'pm';
  }

  /// Устанавливает время из формы ввода времени.
  void saveChanges() {
    DateTime now = DateTime.now();
    DateTime newDateTime = DateTime(
      timeValue?.year ?? now.year,
      timeValue?.month ?? now.month,
      timeValue?.day ?? now.day,
      timePeriod=='am' ? _hours : _hours + 12,
      _minutes
    );

    setValue(newDateTime);
    hideForm();
  }

  void onBlur() => _validate();

  void _validate() {
    isValid = true;

    if (required) {
      if (timeValue==null) {
        isValid = false;
      }
    }
  }

  @override
  void writeValue(DateTime newValue) {
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
    disabled = isDisabled;
  }
}