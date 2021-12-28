import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Record {
  Record({
    required this.id, 
    this.title, 
    required this.timestamp, 
    required this.quantity
    }); 

  String id;
  String? title;
  DateTime timestamp;
  int quantity;
}


class Records extends ChangeNotifier {
  /* Represents history of a single day */

  DateTime date;
  int goalMl;
  int progressMl;
  List<Record> records;

  Records({
    required this.date,
    this.goalMl = 0,
    this.progressMl = 0,
    required this.records
  });


  /*Records({
    required this.date,
    required this.goalMl,
    required this.progressMl,
    required this.records,
  });

  DateTime date;
  int goalMl;
  int progressMl;
  List<Record> records;*/


  static final _records = <Record>[
    Record(
      id: '1',
      title: 'Breakfast',
      timestamp: DateTime(2021, 12, 7, 9, 11),
      quantity: 220,
    ),
    Record(
      id: '2',
      timestamp: DateTime(2021, 12, 7, 11, 23),
      quantity: 250,
    ),
    Record(
      id: '3',
      title: 'Lunch',
      timestamp: DateTime(2021, 12, 7, 12, 00),
      quantity: 500,
    ),
    Record(
      id: '4',
      title: 'Orange juice',
      timestamp: DateTime(2021, 12, 7, 15, 55),
      quantity: 220,
    ),
    Record(
      id: '5',
      title: 'Workout',
      timestamp: DateTime(2021, 12, 7, 17, 30),
      quantity: 500,
    ),
    Record(
      id: '6',
      title: 'Dinner',
      timestamp: DateTime(2021, 12, 7, 19, 46),
      quantity: 300,
    ),
    Record(
      id: '7',
      timestamp: DateTime(2021, 12, 7, 21, 30),
      quantity: 220,
    ),
  ];

  //final List<Record> _records = [];

  UnmodifiableListView<Record> recordsOf(DateTime date) {
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return UnmodifiableListView(
      records.where((r) => 
        r.timestamp.year == date.year
        && r.timestamp.month == date.month
        && r.timestamp.day == date.day)
      );
  }

  UnmodifiableListView<Record> recordsOfToday() {
    return recordsOf(DateTime.now());
  }

  Record getRecord(String id) => records.firstWhere((r) => r.id == id);

  
  int dailyAmount() {
    DateTime now = DateTime.now();
    int amount = 0;
    records.where((i) => i.timestamp.year == now.year && i.timestamp.month == now.month && i.timestamp.day == now.day)
            .forEach((record) { 
              amount += record.quantity; 
            });
    return amount;
  }

  void add(Record record) {
    records.add(record);
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  void updateRecord(String id, Record record) {
    Record r = getRecord(id);
    r.title = record.title;
    r.timestamp = record.timestamp;
    r.quantity = record.quantity;
    notifyListeners();
  }

  Record remove(String id) {
    Record r = records.firstWhere((record) => record.id == id);
    records.remove(r);
    notifyListeners();
    return r;
  }

  void removeAll() {
    records.clear();
    notifyListeners();
  }

  factory Records.fromMap(Map<String, dynamic>? data) {
    data = data ?? { };

    DateTime date = data['date'].toDate();
    int goalMl = data['goal_ml'];
    int progressMl = data['progress_ml'];
    List<Record> records = <Record>[];

    Map<String, dynamic> firestoreRecords = data['records'];
    firestoreRecords.forEach((k,r) => {
      records.add(Record(
        id: k,
        timestamp: r['time'].toDate(),
        title: r['title'],
        quantity: r['quantity_ml']
        )
      )
    });
    records.sort((a,b) => a.timestamp.compareTo(b.timestamp));

    return Records(
      date: date,
      goalMl: goalMl,
      progressMl: progressMl,
      records: records
    );
  }

  String getIdForNewRecord() {
    int largest = 0;
    records.forEach((element) {
      String id = element.id;
      id = id.replaceAll(new RegExp(r'[^0-9]'),''); // remove characters that are non-numeric
      largest = max(largest, int.parse(id));
    });
    return (largest + 1).toString();
  }

  String getDocId() {
    return DateFormat('yyyyMMdd').format(date);
  }

  static String getDocIdOf(Record record) {
    return DateFormat('yyyyMMdd').format(record.timestamp);
  }
}