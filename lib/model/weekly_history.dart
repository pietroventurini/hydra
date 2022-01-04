import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/util/date_utils.dart';

class WeeklyHistory extends ChangeNotifier {

  DateTime date;
  List<Records> weeklyRecords;

  WeeklyHistory({required this.date, required this.weeklyRecords}) {
    this.weeklyRecords = _expandToSevenDays(weeklyRecords); 
  }
  
  List<Records> _expandToSevenDays(List<Records> weeklyHistory) {
    assert (weeklyHistory.length <= 7, "Weekly history length must be <= 7");

    List<Records> weeklyRecords = [];
    DateTime startOfWeek = CustomDateUtils.startOfWeek(date);
    // initialize empty weekly history from startOfWeek to startOfWeek + 6
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      weeklyRecords.add(Records(date: day, records: <Record>[]));
    }
    // override with available daily history
    for (Records dailyRecords in weeklyHistory) {
      weeklyRecords[dailyRecords.date.weekday-1] = dailyRecords;
    }

    return weeklyRecords;
  }



  void updateDate(DateTime newDate) {
    DateTime startOfWeek = CustomDateUtils.startOfWeek(date);
    DateTime endOfWeek = CustomDateUtils.endOfWeek(date);
    this.date = newDate;
    // if new date is out of range respect to old week
    // then remove all the old records
    if (newDate.difference(startOfWeek).inDays < 0 || newDate.difference(endOfWeek).inDays > 0) {
      this.weeklyRecords = _expandToSevenDays(<Records>[]);
    }
    notifyListeners();
  }

  void updateWeeklyRecords(List<Records> weeklyRecords) {
    assert (weeklyRecords.length <= 7, "weekly records length must be <= 7");
    this.weeklyRecords = _expandToSevenDays(weeklyRecords);
    notifyListeners();
  }

  void updateWeeklyHistory(WeeklyHistory history) {
    assert (weeklyRecords.length <= 7, "weekly records length must be <= 7");
    this.date = history.date;
    this.weeklyRecords = _expandToSevenDays(history.weeklyRecords);
    notifyListeners();
  }

  void sortWeeklyHistoryByDate() {
    weeklyRecords.sort((a,b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void addDailyHistory(Records dailyHistory) {
    weeklyRecords.add(dailyHistory);
    sortWeeklyHistoryByDate();
    notifyListeners();
  }

  Records historyOfSelectedDate() {
    return weeklyRecords[date.weekday-1];
  }

  Records historyOfDate(DateTime date) {
    return weeklyRecords.firstWhere((e) => DateUtils.isSameDay(e.date, date));
  }

  bool _isFromSelectedWeek(DateTime date) {
    DateTime startOfWeek = CustomDateUtils.startOfWeek(this.date);
    DateTime endOfWeek = CustomDateUtils.endOfWeek(this.date);
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  void removeRecord(Record record) {
    if (_isFromSelectedWeek(record.timestamp)) {
      historyOfDate(record.timestamp).remove(record.id);
    }
    notifyListeners();
  }

  void updateRecord(Record oldRecord, Record newRecord) {
    if (_isFromSelectedWeek(newRecord.timestamp) && _isFromSelectedWeek(oldRecord.timestamp)) {
      removeRecord(oldRecord);
      addRecord(newRecord);
    } else if (_isFromSelectedWeek(oldRecord.timestamp)) {
      removeRecord(oldRecord);
    }
    notifyListeners();
  }

  void addRecord(Record record) {
    if (_isFromSelectedWeek(record.timestamp)) {
      historyOfDate(record.timestamp).add(record);
    }
    notifyListeners();
  }


  factory WeeklyHistory.fromMap(List<Map<String, dynamic>> docs, DateTime selectedDate) {

    List<Records> weeklyRecords = <Records>[];

    docs.forEach((doc) => weeklyRecords.add(Records.fromMap(doc)));
    weeklyRecords.sort((a,b) => a.date.compareTo(b.date));

    return WeeklyHistory(
      date: selectedDate,
      weeklyRecords: weeklyRecords,
    );
  }


}