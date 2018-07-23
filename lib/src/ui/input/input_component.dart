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
        (change)="onChange(inputEl.value)"
        (input)="onChange(inputEl.value)"
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
          (click)="onChange(value)"
          [class.active]="value==inputValue"
        >{{value}}</li> 
      </ul>
      <span class="error" *ngIf="!isValid">{{invalidMessage}}</span>
    ''',
    directives: [coreDirectives, formDirectives]
)
class InputComponent implements ControlValueAccessor<String>, OnInit {
  String inputValue;

  final UidService _uid;

  bool showSuggest = false;

  @Input()
  List<String> suggest;

  @Input()
  String pattern;

  @Input()
  bool disabled;

  @Input()
  bool required = false;

  @Input()
  String value;

  @Input()
  String invalidMessage = 'Invalid field';

  @ViewChild('inputEl')
  InputElement inputElement;

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

  @Output('checkedChange')
  Stream get onChecked => _onChecked.stream;
  final _onChecked = new StreamController.broadcast();

  void onChange (String newValue) {
    if (pattern!=null) {
      String replacedValue = newValue.replaceAll(RegExp(pattern), '');
      if (newValue!=replacedValue) {
        inputElement.value = replacedValue;
        onChange(replacedValue);
        return;
      }
    }

    inputValue = newValue;
    _onChecked.add(inputValue);
    _validate();
  }

  void focus() {
    Future.delayed(const Duration(milliseconds: 50), () => inputElement.focus());
  }

  void onBlur() {
    _validate();

    // Откладываем скрытие подсказки, иначе событие клика не успевает произойти
    Future.delayed(const Duration(milliseconds: 50), () => _hideSuggest());
  }

  void onFocus() {
    _showSuggest();
  }

  void _validate() {
    isValid = true;

    if (required) {
      if (inputValue.isEmpty || inputValue.trim() == '') {
        isValid = false;
      }
    }
  }

  // При раскрытом списке вариантов включаем обработку нажатий на клавиатуру
  StreamSubscription<KeyboardEvent> _keyDownListener;

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

  void _hideSuggest([KeyboardEvent event]) {
    // Защита от пролистывания страницы вниз
    event?.stopPropagation();
    event?.preventDefault();

    _keyDownListener?.cancel();
    showSuggest = false;
  }

  void _selectPreviousOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вверх
    event.stopPropagation();
    event.preventDefault();

    if (inputValue==null || inputValue.isEmpty || !suggest.contains(inputValue)) {
      onChange(suggest.last);
    }
    else {
      dynamic previousValue = null;

      for (String value in suggest) {
        if (value==inputValue && previousValue!=null) {
          onChange(previousValue);
        }

        previousValue = value;
      }
    }
  }

  void _selectNextOption(KeyboardEvent event) {
    // Защита от пролистывания страницы вниз
    event.stopPropagation();
    event.preventDefault();

    if (inputValue==null || inputValue.isEmpty || !suggest.contains(inputValue)) {
      onChange(suggest.first);
    }
    else {
      bool previousSelected = false;

      for (String value in suggest) {
        if (previousSelected) {
          onChange(value);
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