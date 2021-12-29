import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/model/weekly_history.dart';
import 'package:hydra/util/date_utils.dart';
import 'package:intl/intl.dart';

class Repository {

  final FirebaseFirestore _firestore;

  Repository(this._firestore);

  Stream<Records> todaysRecordsStream() {
    //DateTime now = DateTime.now();
    DateTime now = DateTime(2021, 12, 12); //FIXME
    String formattedDate = DateFormat('yyyyMMdd').format(now);

    return _firestore.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .doc(formattedDate)
      .snapshots()
      .map((snap) => Records.fromMap(snap.data()));
  }

  Future<WeeklyHistory> weeklyHistoryFromDate(DateTime date) async {
    // FIXME: startOfWeek should be set at 00:00, endOfWeek at 23:59:59
    DateTime startOfWeek = CustomDateUtils.startOfWeek(date);
    DateTime endOfWeek = CustomDateUtils.endOfWeek(date);
    QuerySnapshot<Map<String, dynamic>> queryResultJson= await _firestore.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .where("date", 
            isGreaterThanOrEqualTo: startOfWeek, 
            isLessThanOrEqualTo: endOfWeek)
      .get();
    
    List<Map<String, dynamic>> docsJson = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in queryResultJson.docs) {
      docsJson.add(doc.data());
    }
    
    print("I received data from firestore");
    return WeeklyHistory.fromMap(docsJson, date);
  }

  Future<Records> historyOfDay(DateTime date) async {
    String docId = DateFormat('yyyyMMdd').format(date);
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .doc(docId)
      .get();
    
    if (!doc.exists) {
      return Records(date: date, records: <Record>[]); // empty history
    }
    return Records.fromMap(doc.data());
  }

  Future<void> addRecord(Record r) async {
    //String docId = history.getDocId(); // history should be a param of type Records
    String docId = Records.getDocIdOf(r);
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .doc(docId).get();

    // json for a new document which is not already in the db
    Map<String, dynamic> newDocJson = {
      "date": r.timestamp,
      "goal_ml": 0, // get goal from user (set as variable of user)
    };

    // json for a new record
    Map<String, dynamic> newRecordJson = {
      "progress_ml": FieldValue.increment(r.quantity),
      "records": {
        r.id: {
          "quantity_ml": r.quantity,
          "time": r.timestamp,
          "title": r.title
        } 
      }
    };

    Map<String, dynamic> docJson = {};
    // merge new document (if it doesnt exist yet) with new recordd
    if (!doc.exists) {
      docJson.addAll(newDocJson);
    }
    docJson.addAll(newRecordJson);

    return doc.reference.set(docJson, SetOptions(merge: true));
  }

  Future<void> removeRecord(Record r) {
    String docId = Records.getDocIdOf(r);
    return _firestore.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .doc(docId)
      .set({
        "progress_ml": FieldValue.increment(-r.quantity), //decrement progress
        "records": {r.id: FieldValue.delete()}
      }, SetOptions(merge: true));
  }

  Future<void> updateRecord(Record oldRecord, Record updatedRecord) {
    // problema: se cambia la data cambia anche il documento
    // forse è meglio richiedere oldRecord e updatedRecord
    // rimuovere oldRecord dal documento in cui si trova
    // aggiungere updatedRecord nel nuovo documento (o nello stesso)
    // N.B. l'id del documento si può calcolare dalla data del record
    // ma come aggiorno il campo progress_ml?
    // vedi qui: https://firebase.google.com/docs/firestore/manage-data/add-data#increment_a_numeric_value
    // update ha un parametro FieldValue.increment

    String oldDocId = Records.getDocIdOf(oldRecord);
    

    if (oldRecord.timestamp.year == updatedRecord.timestamp.year
    && oldRecord.timestamp.month == updatedRecord.timestamp.month
    && oldRecord.timestamp.day == updatedRecord.timestamp.day) {
      // update that document
      return _firestore.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .doc(oldDocId)
      .set({
        "progress_ml": FieldValue.increment(updatedRecord.quantity - oldRecord.quantity),
        "records": {
          updatedRecord.id: {
            "quantity_ml": updatedRecord.quantity,
            "time": updatedRecord.timestamp,
            "title": updatedRecord.title
          } 
        }
      }, SetOptions(merge: true));
    } else {
      // remove record from oldDocument
      removeRecord(oldRecord);
      // add record to newDocument
      return addRecord(updatedRecord);
    }
  }
}