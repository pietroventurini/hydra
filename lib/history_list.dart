import 'package:flutter/material.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/newrecord_menu.dart';
import 'package:intl/intl.dart';
import 'package:hydra/decorations/card.dart' as Decorations;


class HistoryList extends StatelessWidget {
  const HistoryList({
    Key? key,
    required this.history,
    required this.onRecordUpdated,
    required this.onRecordDeleted,
    required this.onUndoDelete,
  });

  final Records history;
  final Function onRecordUpdated;
  final Function onRecordDeleted;
  final Function onUndoDelete;


  @override
  Widget build(BuildContext context){
    return Container(
      //color: Colors.white,
      child: ListView.builder(
        itemCount: history.records.length,
        itemBuilder: (BuildContext context, index) {
          var record = history.records[index];
          return RecordItem(
            record: record,
            onDelete: onRecordDeleted,
            onUpdate: onRecordUpdated,
            onUndoDelete: onUndoDelete,
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
          onUpdate(record, newRecord);
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
        decoration: BoxDecoration(
          gradient: Decorations.redLinearGradient,
        ),
        //color: Colors.red,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (DismissDirection direction) {
        //var deletedRecord = onDelete();
        onDelete(record);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Record deleted"
            ),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () => onUndoDelete(record),
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
                style: Theme.of(context).textTheme.headline3?.copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700
                ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(left: 20),
                  height: 60,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          "${record.quantity.toString()} ml",
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(left: 34),
                          child: Text(
                            record.title ?? '',
                            style: Theme.of(context).textTheme.headline3
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