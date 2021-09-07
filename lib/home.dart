import 'package:flutter/material.dart';
import 'package:hydra/model/record_model.dart';
import 'package:hydra/newrecord_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(.23),
          blurRadius: 30,
          offset: Offset(0, 10),
        )
      ],
    );

    var progressCard = Container(
      height: 180,
      margin: EdgeInsets.only(top: 24, left: 24, right: 24),
      decoration: cardDecoration,
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
                          text: Provider.of<Records>(context).dailyAmount().toString(),
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: "/2000ml",
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

    var newRecordTab = Container(
      margin: EdgeInsets.only(top: 20, left: 26, right: 26),
      decoration: cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Drink check-in",
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: TextFormField(
                        initialValue: "20:37",
                        decoration: InputDecoration(
                          icon: Icon(Icons.schedule_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );

    var historyTab = Expanded(
      child: Container(
        //color: Colors.white,
        margin: EdgeInsets.only(top: 20),
        child: Consumer<Records>(
          builder: (context, history, child) => ListView.builder(
            itemCount: history.records.length,
            itemBuilder: (BuildContext context, index) {
              var record = history.records[index];
              return RecordItem(
                record: record,
                onDelete: () => history.remove(record.id),
                );
            },
          ),
        ),
      ),
    );

    void _openNewRecordMenu(int id) {
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
            child: NewRecordMenu(id),
          );
        },
      ).then((record) {
        if (record != null) {
          Provider.of<Records>(context, listen: false).add(record);
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
            historyTab,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewRecordMenu(Provider.of<Records>(context, listen: false).records.length + 1),
        tooltip: "New check-in",
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.endFloat,
    );
  }
}

class RecordItem extends StatelessWidget {
  const RecordItem({
    Key? key,
    required this.record,
    required this.onDelete,
  }) : super(key: key);

  final Record record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
        var deletedRecord = Provider.of<Records>(context, listen: false).remove(record.id);
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
          ],
        ),
      ),
    );
  }
}