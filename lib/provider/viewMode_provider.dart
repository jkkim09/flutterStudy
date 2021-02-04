import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ViewModeProvider extends ChangeNotifier {
  bool _mode = true;

  ViewModeProvider(this._mode);

  bool get mode => _mode;

  setMode(bool mode) {
    _mode = mode;
    notifyListeners();
  }

  setDark() {
    _mode = false;
    notifyListeners();
  }

  setWhite() {
    _mode = true;
    notifyListeners();
  }
}
