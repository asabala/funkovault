import 'package:flutter/material.dart';

class AtlasNavigationController extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void goTo(int value) {
    if (_index == value) return;

    _index = value;
    notifyListeners();
  }
}
