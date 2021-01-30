import 'package:flutter/foundation.dart';

class CountProvider extends ChangeNotifier {
  int _count = 0;

  CountProvider(this._count);

  int get count => _count;

  setCounter(int counter) {
    _count = counter;
    notifyListeners();
  }

  add() {
    _count++;
    notifyListeners();
  }
}
