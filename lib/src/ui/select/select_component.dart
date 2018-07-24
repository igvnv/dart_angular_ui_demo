part of ui;

@Component(
  selector: 'ui-select',
  styleUrls: ['select/select_component.css'],
  template: '''
    <div 
      class="select"
      [class.error]="!isValid"
      [class.disabled]="disabled"
      [class.open]="listOpened"
    >
      <span 
        class="label"
        [class.raised]="selectValue!=null && selectValue.isNotEmpty"
        (focus)="showOptions()"
        [tabindex]="tabindex"
      >
        <ng-content></ng-content> <span *ngIf="required">*</span>
      </span>
      <span 
        class="currentValue"
        (click)="toggleOptions()"
      >{{options[selectValue]}}</span>
      <ul>
        <li
          *ngFor="let key of options.keys"
          (click)="setValue(key);hideOptions()"
          [class.active]="key==selectValue"
        >{{options[key]}}</li>
      </ul>
    </div>
    <span class="error" *ngIf="!isValid">{{invalidMessage}}</span>
  ''',
  directives: [coreDirectives, formDirectives],
  providers: [ClassProvider(UidService)]
)
class SelectComponent implements ControlValueAccessor<String>, OnInit, OnDestroy {
  String selectValue;

  final UidService _uid;

  /// Ссылка на HTML элемент текущего компонента.
  final HtmlElement _el;

  /// Раскрыт ли на данный момент список доступных значений.
  bool listOpened = false;

  /// Управляет последовательностю перехода между элементами при нажатии на
  /// кнопку Tab. Необходимо задать значение (например 0) для возможности
  /// перехода к текущему компоненту нажатием на Tab.
  @Input()
  int tabindex = 0;

  bool _disabled = false;
  @Input()
  set disabled(bool disabled) {
    _disabled = disabled;

    if (_disabled) {
      hideOptions();
    }
  }

  get disabled => _disabled;

  /// Является ли заполнение компонента обязательным.
  @Input()
  bool required = false;

  /// Спиоск доступных значений для выпадающего списка.
  /// Пример: {'one': 'First Line', 'two': 'Second Line'}
  @Input()
  Map<dynamic, String> options = {};

  /// Сообщение об ошибке
  @Input()
  String invalidMessage = 'Invalid field';

  SelectComponent(NgControl control, this._uid, this._el) {
    control.valueAccessor = this;
  }

  String inputId;

  bool isValid = true;

  void ngOnInit () {
    if (inputId==null) {
      inputId = 'select_' + _uid.generate();
    }
  }

  /// Обработчик изменения значения компонента
  /// (необходимо для работы с [(ngModel)]).
  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  /// Скрывает/отображает выпадающий список.
  void toggleOptions() {
    if (listOpened) {
      hideOptions();
    }
    else {
      showOptions();
    }
  }

  /// При раскрытом списке вариантов включаем обработку кликов для скрытия списка
  /// при клике вне компонента.
  StreamSubscription<MouseEvent> _clickOutsideListener;

  /// При раскрытом списке вариантов включаем обработку нажатий на клавиатуру.
  StreamSubscription<KeyboardEvent> _keyDownListener;

  /// Отображает выпадающий список с вариантами выбора.
  void showOptions() {
    if (_disabled) return;

    listOpened = true;

    _clickOutsideListener = document.onClick.listen((MouseEvent event) {
      if (!_el.contains(event.target)) {
        hideOptions();
      }
    });

    _addKeyDownListener();
  }

  /// Добавляет обработчки нажатия клавиш для управления выпадающим списком
  /// с клавиатуры:
  ///
  /// * при нажатии на Esc, Enter и Space скрываем выпадающий список
  /// * при нажатии на кнопку Вниз выбираем следующий элемент в списке (если
  ///   не выбрано ранее, то перывй элемент)
  /// * при нажатии на кнопку Вверх выбираем предыдущий элемент в списке (если
  ///   не выбрано ранее, то последний элемент)
  void _addKeyDownListener() {
    _keyDownListener = document.onKeyDown.listen((KeyboardEvent event) {
      switch (event.keyCode) {
        // Скрываем опции по нажатию Enter
        case 13:
        // Скрываем опции по нажатию Esc
        case 27:
        // Скрываем опции по нажатию Space
        case 32:
          hideOptions(event);
          break;
        // Нажатие кнопки Вверх
        case 38:
          _selectPreviousOption(event);
          break;
        // Нажатие кнопки Вниз
        case 40:
          _selectNextOption(event);
          break;
      }
    });
  }

  /// Выбирает предыдущий элемент в списке выбора.
  void _selectPreviousOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вверх
    event.stopPropagation();
    event.preventDefault();

    if (selectValue==null || selectValue.isEmpty) {
      setValue(options.keys.last);
    }
    else {
      dynamic previousKey = null;

      for (dynamic key in options.keys) {
        if (key==selectValue && previousKey!=null) {
          setValue(previousKey);
        }

        previousKey = key;
      }
    }
  }

  /// Выбирает следующий элемент в списке выбора.
  void _selectNextOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вниз
    event.stopPropagation();
    event.preventDefault();

    if (selectValue==null || selectValue.isEmpty) {
      setValue(options.keys.first);
    }
    else {
      bool previousSelected = false;

      for (dynamic key in options.keys) {
        if (previousSelected) {
          setValue(key);
          previousSelected = false;
        }
        else if (key==selectValue) {
          previousSelected = true;
        }
      }
    }
  }

  /// Прячет список выбора.
  void hideOptions([KeyboardEvent event]) {
    // Защита от пролистывания страницы вниз
    event?.stopPropagation();
    event?.preventDefault();

    listOpened = false;
    _clickOutsideListener?.cancel();
    _keyDownListener?.cancel();
  }

  void ngOnDestroy() {
    _clickOutsideListener?.cancel();
    _keyDownListener?.cancel();
  }

  /// Устанавливает значение компонента
  void setValue (String newValue) {
    selectValue = newValue;
    _onChecked.add(selectValue);
    _validate();
  }

  void onBlur() => _validate();

  void _validate() {
    isValid = true;

    if (required) {
      if (selectValue.isEmpty || selectValue.trim() == '') {
        isValid = false;
      }
    }
  }

  @override
  void writeValue(String newValue) {
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
    print('Blur');
    _onTouched?.call();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
  }
}