import 'package:angular/angular.dart';

int _num = 0;

@Injectable()
class UidService {

  String generate() {
    return (++_num).toString();
  }
}