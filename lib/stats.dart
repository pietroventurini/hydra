import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/decorations/card.dart' as Decorations;
import 'package:hydra/history_list.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/model/weekly_history.dart';
import 'package:hydra/util/date_utils.dart';

import 'package:provider/provider.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({Key? key}) : super(key: key);

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Container(
        child: FutureBuilder<WeeklyHistory>(
          future: Repository(FirebaseFirestore.instance).weeklyHistoryFromDate(DateTime.now()),
          initialData: WeeklyHistory(
            date: DateTime.now(),
            weeklyRecords: <Records>[]
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return ChangeNotifierProvider<WeeklyHistory>(
                create: (context) => snapshot.data!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ChartCard(),
                    HistoryListContainer(),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
        )
      ),
    );
    
  }
}

class ChartCard extends StatefulWidget {
  const ChartCard({Key? key}) : super(key: key);

  @override
  _ChartCardState createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: Decorations.getCardDecoration(gradient: Decorations.whiteLinearGradient),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          WeekController(),
          barChart(),
        ],
      ),
    );
  }

  Container barChart() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      height: 210,
      child: BarChart(
        BarChartData(
          barGroups: barGroups(),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: SideTitles(showTitles: false),
            topTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                color: const Color(0xff7589a2),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              margin: 20,
              getTitles: (double value) {
                switch(value.toInt()) {
                  case 0:
                    return 'Mn';
                  case 1:
                    return 'Te';
                  case 2:
                    return 'Wd';
                  case 3:
                    return 'Tu';
                  case 4:
                    return 'Fr';
                  case 5:
                    return 'St';
                  case 6:
                    return 'Sn';
                  default:
                    return '';
                }
              }
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
              margin: 8,
              reservedSize: 28,
              interval: 1,
              getTitles: (value) {
                return (value % 1000 == 0 && value != 0) ? '${value ~/ 1000}L' : '';
              },
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
        ),
        swapAnimationDuration: Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }


  List<BarChartGroupData> barGroups() {
    List<BarChartGroupData> data = [];

    List<Records> history = Provider.of<WeeklyHistory>(context).weeklyRecords;

    for (int day=0; day < 7; day++) {
      double dailyTotal = history[day].progressMl.toDouble();
      double dailyGoal = history[day].goalMl.toDouble();
      data.add(makeGroupData(day, dailyTotal, dailyGoal));
    }
  
    return data;
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    final Color leftBarColor = const Color.fromARGB(255, 62, 87, 117);
    final Color rightBarColor = const Color.fromARGB(255, 226, 232, 241); //Color.fromARGB(255, 238, 140, 178);
    final double width = 7;
    return BarChartGroupData(
      barsSpace: 4, 
      x: x, 
      barRods: [
        BarChartRodData(
          y: y1,
          colors: [leftBarColor],
          width: width,
        ),
        BarChartRodData(
          y: y2,
          colors: [rightBarColor],
          width: width,
        ),
      ],
    );
  }
}

class WeekController extends StatelessWidget{
  const WeekController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeeklyHistory weeklyHistory = Provider.of<WeeklyHistory>(context);

    return Container(
      width: 250,
      decoration: Decorations.getCardDecoration(),/*BoxDecoration(
        borderRadius: BorderRadius.circular(17.0),
        color: Color(0xFF7A9BEE)
      ),*/
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_left_rounded),
              tooltip: "Previous week",
              color: const Color.fromARGB(255, 62, 87, 117),
              onPressed: () {
                weeklyHistory.updateDate(CustomDateUtils.backOneWeek(weeklyHistory.date));
                // get new records
                Repository(FirebaseFirestore.instance).weeklyHistoryFromDate(weeklyHistory.date)
                  .then((newHistory) => Provider.of<WeeklyHistory>(context, listen: false).updateWeeklyHistory(newHistory));
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  CustomDateUtils.formatWeekRange(Provider.of<WeeklyHistory>(context).date),
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 15,
                    color: const Color.fromARGB(255, 62, 87, 117),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_right_rounded),
              tooltip: "Next week",
              color: const Color.fromARGB(255, 62, 87, 117),
              onPressed: () {
                weeklyHistory.updateDate(CustomDateUtils.forwardOneWeek(weeklyHistory.date));
                // get new records
                Repository(FirebaseFirestore.instance).weeklyHistoryFromDate(weeklyHistory.date)
                  .then((newHistory) => Provider.of<WeeklyHistory>(context, listen: false).updateWeeklyHistory(newHistory));
                // update records
                //Provider.of<StatsDate>(context, listen: false).forwardOneWeek();
              }, 
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Provider.of<WeeklyHistory>(context, listen: false).date, //Provider.of<StatsDate>(context, listen: false).date,
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2100)
    );
    //if (picked != null && picked != Provider.of<WeeklyHistory>(context, listen: false).date) {
    if (picked != null) {
      //Provider.of<WeeklyHistory>(context, listen: false).updateDate(picked);
      // get new records
      Repository(FirebaseFirestore.instance).weeklyHistoryFromDate(picked)
        .then((newHistory) => Provider.of<WeeklyHistory>(context, listen:false).updateWeeklyHistory(newHistory))
        .catchError((error) => print("houston, we have a problem:" + error));
        // ATTUALE PROBLEMA: UPDATE WEEKLY HISTORY NON AGGIORNA GLI ALTRI WEEKLY HISTORY
        // PROBABILMENTE È colpa di future provider (che non viene aggiornato)

      //Provider.of<StatsDate>(context, listen: false).date = picked;
    }
  }
}


class HistoryListContainer extends StatelessWidget {
  const HistoryListContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeeklyHistory history = Provider.of<WeeklyHistory>(context);
    Repository repository = Repository(FirebaseFirestore.instance);
    return Expanded(
      child: Container(
        child: HistoryList( 
          history: history.historyOfSelectedDate(),
          onRecordDeleted: (Record record) { 
            history.removeRecord(record);
            // cloud remove
            repository.removeRecord(record);
          },
          onRecordUpdated: (Record oldRecord, Record updatedRecord) {
            history.updateRecord(oldRecord, updatedRecord);
            // cloud update (pay attention to record id duplicates if date changes)
            repository.updateRecord(oldRecord, updatedRecord);
          },
          onUndoDelete: (Record deletedRecord) {
            history.addRecord(deletedRecord);
            // cloud add
            repository.addRecord(deletedRecord);
          },
        ),
      ),
    );
  }
}