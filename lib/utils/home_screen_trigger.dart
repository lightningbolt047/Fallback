import 'package:flutter/material.dart';

class HomeScreenTrigger extends ChangeNotifier{
  void triggerHomeScreenUpdate(){
    notifyListeners();
  }
}

HomeScreenTrigger homeScreenTrigger=HomeScreenTrigger();