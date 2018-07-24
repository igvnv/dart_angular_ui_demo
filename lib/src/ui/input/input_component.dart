part of ui;

@Component(
  selector: 'ui-input',
  styleUrls: ['input/input_component.css'],
  template: '''
    <input 
      #inputEl
      [id]="inputId" 
      type="text" 
      [value]="inputValue"
      [class.error]="!isValid"
      (change)="setValue(inputEl.value)"
      (input)="setValue(inputEl.value)"
      (blur)="onBlur()"
      (focus)="onFocus()"
      [disabled]="disabled"
    />
    <label 
      [attr.for]="inputId"
      [class.raised]="inputEl.value.isNotEmpty"
    >
      <ng-content></ng-content> <span *ngIf="required">*</span>
    </label>
    <ul class="suggest" *ngIf="showSuggest">
      <li
        *ngFor="let value of suggest"
        (click)="setValue(value)"
        [class.active]="value==inputValue"
      >{{value}}</li> 
    </ul>
    <span class="error" *ngIf="!isValid">{{invalidMessage}}</span>
  ''',
  directives: [coreDirectives, formDirectives],
  providers: [ClassProvider(UidService)]
)
class InputComponent implements ControlValueAccessor<String>, OnInit {
  String inputValue;

  final UidService _uid;

  bool showSuggest = false;

  @Input()
  List<String> suggest;

  /// RegExp строка, в соответствии с которой происходит очистка
  /// вводимого значения.
  ///
  /// Пример поля, принимающего только числа:
  /// <ui-input [(ngModel)]="var" [pattern]="'[^0-9]+'">Digits only</ui-input>
  @Input()
  String pattern;

  /// Является ли компонент заблокированным.
  @Input()
  bool disabled;

  /// Является ли заполнение компонента обязательным.
  @Input()
  bool required = false;

  /// Сообщение об ошибке.
  @Input()
  String invalidMessage = 'Invalid field';

  /// Ссылка на HTML элемент инпута.
  @ViewChild('inputEl')
  InputElement inputElement;

  /// Обработчик изменения значения компонента
  /// (необходимо для работы с [(ngModel)]).
  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  InputComponent(NgControl control, this._uid) {
    control.valueAccessor = this;
  }

  String inputId;

  bool isValid = true;

  void ngOnInit () {
    if (inputId==null) {
      inputId = 'input_' + _uid.generate();
    }
  }

  /// Устанавливает значение компонента.
  void setValue (String newValue) {
    if (pattern!=null) {
      String replacedValue = newValue.replaceAll(RegExp(pattern), '');
      if (newValue!=replacedValue) {
        inputElement.value = replacedValue;
        setValue(replacedValue);
        return;
      }
    }

    inputValue = newValue;
    _onChecked.add(inputValue);
    _validate();
  }

  /// Устанавливает курсор в инпут.
  void focus() {
    Future.delayed(const Duration(milliseconds: 50), () => inputElement.focus());
  }

  /// Обрабатывает событие покидания фокуса из инпута.
  void onBlur() {
    _validate();

    // Откладываем скрытие подсказки, иначе событие клика не успевает произойти.
    Future.delayed(const Duration(milliseconds: 50), () => _hideSuggest());
  }

  /// Обрабатывает получение инпутом фокуса.
  void onFocus() {
    _showSuggest();
  }

  /// Проверяет правильность значения компонента.
  void _validate() {
    isValid = true;

    if (required) {
      if (inputValue.isEmpty || inputValue.trim() == '') {
        isValid = false;
      }
    }
  }

  /// При раскрытом списке вариантов включаем обработку нажатий на клавиатуру.
  StreamSubscription<KeyboardEvent> _keyDownListener;

  /// Отображает список с подсказками.
  void _showSuggest() {
    if (suggest==null || suggest.isEmpty) return;

    showSuggest = true;

    _keyDownListener = document.onKeyDown.listen((KeyboardEvent event) {
      switch (event.keyCode) {
        // Скрываем опции по нажатию Enter
        case 13:
        // Скрываем опции по нажатию Esc
        case 27:
        // Скрываем опции по нажатию Space
        case 32:
          _hideSuggest(event);
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

  /// Прячет список с подсказками.
  void _hideSuggest([KeyboardEvent event]) {
    // Защита от пролистывания страницы вниз
    event?.stopPropagation();
    event?.preventDefault();

    _keyDownListener?.cancel();
    showSuggest = false;
  }

  /// Выбирает предыдущий элемент в списке с подсказками.
  void _selectPreviousOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вверх
    event.stopPropagation();
    event.preventDefault();

    if (inputValue==null || inputValue.isEmpty || !suggest.contains(inputValue)) {
      setValue(suggest.last);
    }
    else {
      dynamic previousValue = null;

      for (String value in suggest) {
        if (value==inputValue && previousValue!=null) {
          setValue(previousValue);
        }

        previousValue = value;
      }
    }
  }

  /// Выбирает следующий элемент в списке с подсказками.
  void _selectNextOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вниз
    event.stopPropagation();
    event.preventDefault();

    if (inputValue==null || inputValue.isEmpty || !suggest.contains(inputValue)) {
      setValue(suggest.first);
    }
    else {
      bool previousSelected = false;

      for (String value in suggest) {
        if (previousSelected) {
          setValue(value);
          previousSelected = false;
        }
        else if (value==inputValue) {
          previousSelected = true;
        }
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
    _onTouched?.call();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
  }
}