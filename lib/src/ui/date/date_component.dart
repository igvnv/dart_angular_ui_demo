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
  /// Текущая дата.
  DateTime now = DateTime.now();

  /// Текущее значение компонента.
  DateTime inputValue;

  /// Отображаемый на календаре месяц.
  DateTime displayedDate;

  /// Список дней месяца.
  List<int> monthDays = [];

  /// Список дней предыдущего месяца, которые попадают в отображение первой.
  /// недели текущего месяца
  List<int> previousMonthDays = [];

  /// Список дней следующего месяца, которые попадают в отображение последней
  /// недели текущего месяца.
  List<int> nextMonthDays = [];

  /// Ссылка на HTML элемент текущего компонента.
  final HtmlElement _el;

  DateComponent(NgControl control, this._el) {
    control.valueAccessor = this;
  }

  /// Список названий месяцев.
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

  /// Список годов для отображения на слое быстрого выбора года.
  List<int> yearsList = [];

  /// Является ли заполнение компонента обязательным.
  @Input()
  bool required = false;

  /// Сообщение об ошибке
  @Input()
  String invalidMessage = 'Invalid field';

  /// Управляет последовательностю перехода между элементами при нажатии на
  /// кнопку Tab. Необходимо задать значение (например 0) для возможности
  /// перехода к текущему компоненту нажатием на Tab.
  @Input()
  int tabindex = 0;

  /// Обработчик изменения значения компонента
  /// (необходимо для работы с [(ngModel)]).
  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  bool _disabled = false;

  /// Является ли компонент заблокированным.
  @Input()
  set disabled(bool disabled) {
    _disabled = disabled;

    if (_disabled) {
      hideCalendar();
    }
  }

  get disabled => _disabled;

  bool isValid = true;

  void toggleCalendar() {
    if (displayedView.isNotEmpty) {
      hideCalendar();
    }
    else {
      showCalendar();
    }
  }

  // При раскрытом календаре включаем обработку кликов для скрытия календаря
  // при клике вне компонента.
  StreamSubscription<MouseEvent> _clickOutsideListener;

  /// Показывает календарь.
  void showCalendar() {
    if (_disabled) return;

    // Формируем список годов для отображения на экране выбора года
    // (20 лет, последний год текущий)
    yearsList = List.generate(20, (int i) => now.year - 19 + i);

    // Если у компонента не указана дата, то отображаем текущую
    displayedDate = inputValue ?? now;

    displayedView = 'calendar';

    _initCalendar();

    // Добавляем обработчик клика вне компонента
    _clickOutsideListener = document.onClick.listen((MouseEvent event) {
      if (!_el.contains(event.target)) {
        hideCalendar();
      }
    });
  }

  /// Определяет является ли [day] сегодняшним днём.
  bool isCurrentDate(int day) {
    return
      now.month==displayedDate.month
      && now.year==displayedDate.year
      && day==now.day;
  }

  /// Определяет является ли [day] выбранным ранее днём.
  bool isSelectedDate(int day) {
    return
      inputValue?.month==displayedDate.month
      && inputValue?.year==displayedDate.year
      && day==inputValue?.day;
  }

  /// Прячет календарь.
  void hideCalendar() {
    displayedView = '';
    _clickOutsideListener?.cancel();
  }

  /// Отображает более старый список годов для экрана выбора года.
  void olderYearsList() {
    int lastYear = yearsList.first - 1;
    yearsList = List.generate(20, (int i) => lastYear - 19 + i);
  }

  /// Отображает более новый список годов для экрана выбора года.
  void newerYearsList() {
    int lastYear = yearsList.last + 1;
    yearsList = List.generate(20, (int i) => lastYear + i);
  }

  /// При уничтожении компонента отключает ранее добавленные обработчики.
  void ngOnDestroy() {
    _clickOutsideListener?.cancel();
  }

  /// Устанавливает отображаемый год.
  void displayYear(year) {
    displayedDate = DateTime(
      year,
      displayedDate.month,
      displayedDate.day,
      displayedDate.hour,
      displayedDate.minute
    );
  }

  /// Устанавливает значение компонента.
  void setValue (DateTime newValue) {
    inputValue = newValue;
    _onChecked.add(inputValue);
    _validate();
  }

  /// Проверяет правильность значения компонента.
  void _validate() {
    isValid = true;

    if (required) {
      if (inputValue==null) {
        isValid = false;
      }
    }
  }

  /// Устанавливает день [day] для текущего отображаемого месяца.
  void setDay(int day) {
    DateTime date = DateTime(
        displayedDate.year,
        displayedDate.month,
        day,
        inputValue!=null ? displayedDate.hour : 0,
        inputValue!=null ? displayedDate.minute : 0
    );

    setValue(date);
    hideCalendar();
  }

  /// Отображает предыдущий месяц (относительно текущего просматриваемого).
  void showPreviousMonth() {
    displayedDate = _previousMonth(displayedDate);
    _initCalendar();
  }

  /// Отображает следующий месяц (относительно текущего просматриваемого).
  void showNextMonth() {
    displayedDate = _nextMonth(displayedDate);
    _initCalendar();
  }

  /// Отображает месяц по его номеру для указанного года.
  void showMonthByNumber(int month, int year) {
    displayedDate = new DateTime(
        year,
        month,
        1,
        displayedDate.hour,
        displayedDate.minute
    );
    _initCalendar();

    viewMode('calendar');
  }

  /// Текущий отображаемый экран. Доступны следующие значения:
  ///
  /// * (пустая строка) - календарь скрыт
  /// * 'calendar' - отображение дней месяца
  /// * 'months' - отображение списка месяцев
  /// * 'years' - отображение списка годов
  String displayedView = '';

  /// Устанавливает отображаемый экран
  void viewMode(String mode) {
    Future.delayed(const Duration(milliseconds: 50), () => displayedView = mode);
  }

  /// Инициализирует календарь (экран отображения дней месяца).
  void _initCalendar() {
    // Формирует список дней отображаемого месяца
    monthDays = List.generate(_lastMonthDay(displayedDate), (int i) => i + 1);
    int monthFirstDay = DateTime(displayedDate.year, displayedDate.month, 1).weekday;

    // Формирует список дней прошлого месяца, которые попадают в просмотр
    int previousMonthLastDay = _lastMonthDay(_previousMonth(displayedDate));
    if (monthFirstDay==7) {
      previousMonthDays = [];
    }
    else {
      previousMonthDays = List.generate(
          monthFirstDay,
          (int i) => previousMonthLastDay - monthFirstDay + i +1
      );
    }

    // Генерируем список дней следующего месяца, которые попадают в просмотр
    int lastWeekDays = (_lastMonthDay(displayedDate) + monthFirstDay - 1) % 7;
    if (lastWeekDays==6) {
      nextMonthDays = [];
    }
    else {
      nextMonthDays = List.generate(6 - lastWeekDays, (int i) => i + 1);
    }
  }

  /// Возвращает последний день месяца для [date].
  int _lastMonthDay(DateTime date) {
    DateTime lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    return lastDayDateTime.day;
  }

  /// Возвращает месяц, предыдущий для [date].
  DateTime _previousMonth(DateTime date) {
    DateTime previousMonth = (date.month > 1)
        ? new DateTime(date.year, date.month - 1, 1, date.hour, date.minute)
        : new DateTime(date.year - 1, 12, 1, date.hour, date.minute);
    return previousMonth;
  }

  /// Возвращает месяц, следующий для [date].
  DateTime _nextMonth(DateTime date) {
    DateTime previousMonth = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 1, date.hour, date.minute)
        : new DateTime(date.year + 1, 1, 1, date.hour, date.minute);
    return previousMonth;
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