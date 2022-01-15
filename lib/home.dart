import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/history_list.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/newrecord_menu.dart';
import 'package:provider/provider.dart';
import 'package:hydra/decorations/card.dart' as Decorations;

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final history = Provider.of<Records>(context);
    final repository = Repository(FirebaseFirestore.instance);

    var progressCard = Container(
      height: 180,
      margin: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 30),
      decoration: Decorations.getCardDecoration(gradient: Decorations.whiteLinearGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Today's progress",
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 16,
                      color: const Color.fromARGB(255, 171, 186, 214), //Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 18,
                        color: const Color.fromARGB(255, 62, 87, 117), //Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: history.progressMl.toString(),
                          style: TextStyle(
                            fontSize: 28,
                            color: const Color.fromARGB(255, 62, 87, 117), //Colors.black87,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: "/" + history.goalMl.toString() + "ml",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: history.goalMl != 0 ? history.progressMl / history.goalMl : 0,
                  strokeWidth: 10.0,
                  color: const Color.fromARGB(255, 62, 87, 117),
                  backgroundColor: const Color.fromARGB(255, 226, 232, 241),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    var historyTab = Expanded(
      child: HistoryList(
        history: history, // le prossime 3 funzioni vanno sostituite con chiamate a firestore (creare appositi metodi nella classe repository)
        //onRecordDeleted: (id) => Provider.of<Records>(context, listen: false).remove(id),
        //onRecordUpdated: (id, newRecord) => Provider.of<Records>(context, listen: false).updateRecord(id, newRecord),
        //onUndoDelete: (oldRecord) => Provider.of<Records>(context, listen: false).add(oldRecord),

        onRecordDeleted: (record) => repository.removeRecord(record),
        onRecordUpdated: (oldRecord, updatedRecord) => repository.updateRecord(oldRecord, updatedRecord),
        onUndoDelete: (deletedRecord) => repository.addRecord(deletedRecord),
      ),
    );

    void _openNewRecordMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.85,
            child: NewRecordMenu(
              id: history.getIdForNewRecord(),
              edit: false,
            ),
          );
        },
      ).then((record) {
        if (record != null) {
          // repo.add record
          repository.addRecord(record);
          //Provider.of<Records>(context, listen: false).add(record);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 243, 248),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            progressCard,
            //newRecordTab,
            //getRecordBtn,
            historyTab,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewRecordMenu(),
        tooltip: "New check-in",
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.endFloat,
    );
  }
}