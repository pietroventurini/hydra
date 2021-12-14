import 'dart:collection';

import 'package:flutter/foundation.dart';

class Record {
  Record({
    required this.id, 
    this.title, 
    required this.timestamp, 
    required this.quantity
    }); 

  int id;
  String? title;
  DateTime timestamp;
  int quantity;
}


class Records extends ChangeNotifier {

  static final _records = <Record>[
    Record(
      id: 1,
      title: 'Breakfast',
      timestamp: DateTime(2021, 12, 7, 9, 11),
      quantity: 220,
    ),
    Record(
      id: 2,
      timestamp: DateTime(2021, 12, 7, 11, 23),
      quantity: 250,
    ),
    Record(
      id: 3,
      title: 'Lunch',
      timestamp: DateTime(2021, 12, 7, 12, 00),
      quantity: 500,
    ),
    Record(
      id: 4,
      title: 'Orange juice',
      timestamp: DateTime(2021, 12, 7, 15, 55),
      quantity: 220,
    ),
    Record(
      id: 5,
      title: 'Workout',
      timestamp: DateTime(2021, 12, 7, 17, 30),
      quantity: 500,
    ),
    Record(
      id: 6,
      title: 'Dinner',
      timestamp: DateTime(2021, 12, 7, 19, 46),
      quantity: 300,
    ),
    Record(
      id: 7,
      timestamp: DateTime(2021, 12, 7, 21, 30),
      quantity: 220,
    ),
  ];

  //final List<Record> _records = [];

  UnmodifiableListView<Record> recordsOf(DateTime date) {
    _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return UnmodifiableListView(
      _records.where((r) => 
        r.timestamp.year == date.year
        && r.timestamp.month == date.month
        && r.timestamp.day == date.day)
      );
  }

  UnmodifiableListView<Record> recordsOfToday() {
    return recordsOf(DateTime.now());
  }

  Record getRecord(int id) => _records.firstWhere((r) => r.id == id);

  
  int dailyAmount() {
    DateTime now = DateTime.now();
    int amount = 0;
    _records.where((i) => i.timestamp.year == now.year && i.timestamp.month == now.month && i.timestamp.day == now.day)
            .forEach((record) { 
              amount += record.quantity; 
            });
    return amount;
  }

  void add(Record record) {
    _records.add(record);
    notifyListeners();
  }

  void updateRecord(int id, Record record) {
    Record r = getRecord(id);
    r.title = record.title;
    r.timestamp = record.timestamp;
    r.quantity = record.quantity;
    notifyListeners();
  }

  Record remove(int id) {
    Record r = _records.firstWhere((record) => record.id == id);
    _records.remove(r);
    notifyListeners();
    return r;
  }

  void removeAll() {
    _records.clear();
    notifyListeners();
  }
}