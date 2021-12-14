import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsDate extends ChangeNotifier {
  StatsDate(this._date);

  DateTime _date; 

  DateTime get date => _date;

  set date(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void backOneWeek() {
    _date = _date.subtract(Duration(days: 7));
    notifyListeners();
  }

  void forwardOneWeek() {
    _date = _date.add(Duration(days: 7));
    notifyListeners();
  }

  DateTime startOfWeek() {
    return _date.subtract(Duration(days: _date.weekday - 1));
  }

  DateTime endOfWeek() {
    return _date.add(Duration(days: 7 - _date.weekday));
  }

  String formatWeekRange() {
    DateFormat formatter = DateFormat('MMMd');
    return formatter.format(startOfWeek()) + ' - ' + formatter.format(endOfWeek());
  }
}