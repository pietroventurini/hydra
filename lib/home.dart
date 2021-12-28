import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/history_list.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/newrecord_menu.dart';
import 'package:intl/intl.dart';
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
      margin: EdgeInsets.only(top: 24, left: 24, right: 24),
      decoration: Decorations.cardDecoration,
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
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: history.progressMl.toString(),
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
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
                  value: 0.3,
                  strokeWidth: 10.0,
                  backgroundColor: Colors.black12,
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

/*class RecordItem extends StatelessWidget {
  const RecordItem({
    Key? key,
    required this.record,
    required this.onDelete,
  }) : super(key: key);

  final Record record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {

    void _openEditRecordMenu() {
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
              id: record.id,
              edit: true,
              record: record,
            ),
          );
        },
      ).then((updatedRecord) {
        if (updatedRecord != null) {
          Repository(FirebaseFirestore.instance).updateRecord(record, updatedRecord);

          //Provider.of<Records>(context, listen: false).updateRecord(record.id, record); // LISTEN = FALSE? 
        }
      });
    }

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (DismissDirection direction) {
        var deletedRecord = Provider.of<Records>(context, listen: false).remove(record.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Record deleted"
            ),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                Provider.of<Records>(context, listen: false).add(deletedRecord);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(left: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                DateFormat(DateFormat.HOUR24_MINUTE).format(record.timestamp),
              ),
            ),
            Expanded(
              flex: 8,
              child: GestureDetector(
                onLongPress: () => _openEditRecordMenu(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                  ),
                  padding: EdgeInsets.only(left: 20),
                  height: 60,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          record.quantity.toString() + 'ml'
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(left: 34),
                          child: Text(
                            record.title ?? '',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} */