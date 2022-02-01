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

  //final List<Record> _records = [];

  void _sortRecords({bool ascending: true}) {
    if (ascending) {
      records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else {
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  UnmodifiableListView<Record> recordsOf(DateTime date) {
    _sortRecords();
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
    progressMl += record.quantity.toInt();
    _sortRecords();
    notifyListeners();
  }

  void updateRecord(String id, Record record) {
    Record r = getRecord(id);
    r.title = record.title;
    r.timestamp = record.timestamp;
    r.quantity = record.quantity;
    _sortRecords();
    notifyListeners();
  }

  Record remove(String id) {
    Record r = records.firstWhere((record) => record.id == id);
    records.remove(r);
    progressMl -= r.quantity.toInt();
    notifyListeners();
    return r;
  }

  void removeAll() {
    records.clear();
    progressMl = 0;
    notifyListeners();
  }

  factory Records.fromMap(Map<String, dynamic>? data) {
    data = data ?? { };

    DateTime date = data['date']?.toDate();
    int goalMl = data['goal_ml'];
    int progressMl = data['progress_ml'];
    List<Record> records = <Record>[];

    Map<String, dynamic>? firestoreRecords = data['records'];
    firestoreRecords?.forEach((k,r) => {
      records.add(Record(
        id: k,
        timestamp: r['time']?.toDate(),
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