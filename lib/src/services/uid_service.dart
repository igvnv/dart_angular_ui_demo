import 'package:angular/angular.dart';

@Injectable()
class UidService {
  int _num = 0;

  String generate() {
    return (++_num).toString();
  }
}