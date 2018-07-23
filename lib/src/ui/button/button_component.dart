part of ui;

@Component(
  selector: 'ui-button',
  styleUrls: ['button/button_component.css'],
  template: '''
    <button 
      type="button" 
      [class.large]="large"
    ><ng-content></ng-content></button>
  '''
)
class ButtonComponent {
  @Input()
  bool large = false;
}