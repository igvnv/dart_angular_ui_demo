part of ui;

@Component(
  selector: 'ui-date',
  styleUrls: ['date/date_component.css'],
  templateUrl: 'date/date_component.html',
  directives: [
    coreDirectives,
    formDirectives,
    ButtonComponent,
    InputComponent,
    SelectComponent
  ],
  pipes: [commonPipes]
)
class DateComponent implements ControlValueAccessor<DateTime>, OnDestroy {
  DateTime now = DateTime.now();
  DateTime timeValue;
  DateTime displayedMonth;
  List<int> monthDays = [];
  List<int> previousMonthDays = [];
  List<int> nextMonthDays = [];

  final UidService _uid;

  final HtmlElement _el;

  @Input()
  int tabindex = 0;

  bool _disabled = false;
  @Input()
  set disabled(bool disabled) {
    _disabled = disabled;

    if (_disabled) {
      hideCalendar();
    }
  }

  get disabled => _disabled;

  List<String> monthsNamesList = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  List<int> yearsList = [];

  @Input()
  bool required = false;

  @Input()
  String value;

  @Input()
  String invalidMessage = 'Invalid field';

  DateComponent(NgControl control, this._uid, this._el) {
    control.valueAccessor = this;
  }

  bool isValid = true;

  String formOpened = '';

  void toggleForm() {
    if (formOpened!='') {
      hideCalendar();
    }
    else {
      showCalendar();
    }
  }

  // При раскрытом списке вариантов включаем обработку кликов для скрытия списка
  // при клике вне компонента
  StreamSubscription<MouseEvent> _clickOutsideListener;

  void showCalendar() {
    if (_disabled) return;

    yearsList = List.generate(20, (int i) => now.year - 19 + i);

    displayedMonth = timeValue ?? now;

    formOpened = 'calendar';

    _initCalendar();

    _clickOutsideListener = document.onClick.listen((MouseEvent event) {
      if (!_el.contains(event.target)) {
        formOpened = '';
      }
    });
  }

  bool isCurrentDate(int day) {
    return
      now.month==displayedMonth.month
      && now.year==displayedMonth.year
      && day==now.day;
  }

  bool isSelectedDate(int day) {
    return
      timeValue?.month==displayedMonth.month
      && timeValue?.year==displayedMonth.year
      && day==timeValue?.day;
  }

  void hideCalendar() {
    formOpened = '';
    _clickOutsideListener?.cancel();
  }

  void olderYearsList() {
    int lastYear = yearsList.first - 1;
    yearsList = List.generate(20, (int i) => lastYear - 19 + i);
  }

  void newerYearsList() {
    int lastYear = yearsList.last + 1;
    yearsList = List.generate(20, (int i) => lastYear + i);
  }

  void ngOnDestroy() {
    _clickOutsideListener?.cancel();
  }

  void displayYear(year) {
    displayedMonth = DateTime(
      year,
      displayedMonth.month,
      displayedMonth.day,
      displayedMonth.hour,
      displayedMonth.minute
    );
  }

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (DateTime newValue) {
    timeValue = newValue;
    _onChecked.add(timeValue);
    _validate();
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

  void selectDay(int day) {
    DateTime date = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      day,
      timeValue!=null ? displayedMonth.hour : 0,
      timeValue!=null ? displayedMonth.minute : 0
    );

    onChange(date);
    hideCalendar();
  }

  void showPreviousMonth() {
    displayedMonth = _previousMonth(displayedMonth);
    _initCalendar();
  }

  void showNextMonth() {
    displayedMonth = _nextMonth(displayedMonth);
    _initCalendar();
  }

  void showMonthByNumber(int month, int year) {
    displayedMonth = new DateTime(
        year,
        month,
        1,
        displayedMonth.hour,
        displayedMonth.minute
    );
    _initCalendar();

    calendarMode('calendar');
  }

  void calendarMode(String mode) {
    Future.delayed(const Duration(milliseconds: 50), () => formOpened = mode);
  }

  void _initCalendar() {
    monthDays = List.generate(_lastMonthDay(displayedMonth), (int i) => i + 1);
    int monthFirstDay = DateTime(displayedMonth.year, displayedMonth.month, 1).weekday;

    // Генерируем список дней прошлого месяца, которые попадают в просмотр
    int previousMonthLastDay = _lastMonthDay(_previousMonth(displayedMonth));
    previousMonthDays = List.generate(monthFirstDay - 1, (int i) => previousMonthLastDay - monthFirstDay + i + 2);

    // Генерируем список дней следующего месяца, которые попадают в просмотр
    int lastWeekDays = (_lastMonthDay(displayedMonth) + monthFirstDay - 1) % 7;
    if (lastWeekDays==0) {
      nextMonthDays = [];
    }
    else {
      nextMonthDays = List.generate(7 - lastWeekDays, (int i) => i + 1);
    }
  }

  int _lastMonthDay(DateTime date) {
    DateTime lastDayDateTime = (date.month < 12)
      ? new DateTime(date.year, date.month + 1, 0)
      : new DateTime(date.year + 1, 1, 0);
    return lastDayDateTime.day;
  }

  DateTime _previousMonth(DateTime date) {
    DateTime previousMonth = (date.month > 1)
      ? new DateTime(date.year, date.month - 1, 1, date.hour, date.minute)
      : new DateTime(date.year - 1, 12, 1, date.hour, date.minute);
    return previousMonth;
  }

  DateTime _nextMonth(DateTime date) {
    DateTime previousMonth = (date.month < 12)
      ? new DateTime(date.year, date.month + 1, 1, date.hour, date.minute)
      : new DateTime(date.year + 1, 1, 1, date.hour, date.minute);
    return previousMonth;
  }
}