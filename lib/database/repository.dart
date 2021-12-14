import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydra/model/records.dart';
import 'package:intl/intl.dart';

class Repository {

  final FirebaseFirestore _firestore;

  Repository(this._firestore);

  Future<Records> getTodaysRecords() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd').format(now);

    var snapshot = await _firestore.collection('users')
              .doc('OqMygmWjZtR4npNroiBUInphzb43')
              .collection('records')
              .doc(formattedDate)
              .get();
    print(snapshot['date']);
    print(snapshot['goal_ml']);
    print(snapshot['progress_ml']);
    
    print("hey");

    return Records();    
  }

}