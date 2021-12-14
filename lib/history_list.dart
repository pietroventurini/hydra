import 'package:flutter/material.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/newrecord_menu.dart';
import 'package:intl/intl.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    Key? key,
    required this.records,
    required this.onRecordUpdated,
    required this.onRecordDeleted,
    required this.onUndoDelete,
  });

  final List<Record> records;
  final Function onRecordUpdated;
  final Function onRecordDeleted;
  final Function onUndoDelete;


  @override
  Widget build(BuildContext context){
    return Container(
      //color: Colors.white,
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (BuildContext context, index) {
          var record = records[index];
          return RecordItem(
            record: record,
            onDelete: () => onRecordDeleted(record.id),
            onUpdate: (newRecord) => onRecordUpdated(record.id, newRecord),
            onUndoDelete: (oldRecord) => onUndoDelete(oldRecord),
          );
        },
      ),
    );
  }
}

class RecordItem extends StatelessWidget {
  const RecordItem({
    Key? key,
    required this.record,
    required this.onDelete,
    required this.onUpdate,
    required this.onUndoDelete,
  }) : super(key: key);

  final Record record;
  final Function onDelete;
  final Function onUpdate;
  final Function onUndoDelete;

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
      ).then((newRecord) {
        if (newRecord != null) {
          onUpdate(newRecord);
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
        var deletedRecord = onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Record deleted"
            ),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () => onUndoDelete(deletedRecord),
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
                onLongPress: _openEditRecordMenu,
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
}