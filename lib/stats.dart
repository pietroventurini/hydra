import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydra/decorations/card.dart' as Decorations;
import 'package:hydra/history_list.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/model/stats_date.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: ChangeNotifierProvider(
        create: (context) => StatsDate(DateTime.now()),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ChartCard(),
              HistoryListContainer(),
            ],
          ),
        ),
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
      decoration: Decorations.cardDecoration,
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
                  getTextStyles: (context, value) => const TextStyle(
                      color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
                  margin: 8,
                  reservedSize: 28,
                  interval: 1,
                  getTitles: (value) {
                    if (value % 1000 == 0 && value != 0) {
                      return '${value ~/ 1000}L';
                    } else {
                      return '';
                    }
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
    // TODO: add parameter "date range" or year-month-week
    List<BarChartGroupData> data = [];

    Random rng = new Random();
    for (int day=0; day < 7; day++) {
      double dailyTotal = rng.nextInt(1500).toDouble() + 1500;
      double dailyGoal = 2000;
      data.add(makeGroupData(day, dailyTotal, dailyGoal));
    }
  
    return data;
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    final Color leftBarColor = const Color(0xff53fdd7);
    final Color rightBarColor = const Color(0xffff5182);
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
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.0),
        color: Color(0xFF7A9BEE)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_left_rounded),
              tooltip: "Previous week",
              color: Colors.white,
              onPressed: () {
                Provider.of<StatsDate>(context, listen: false).backOneWeek();
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Consumer<StatsDate>(
                  builder: (context, date, child) {
                    return Text(
                      date.formatWeekRange(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_right_rounded),
              tooltip: "Next week",
              color: Colors.white,
              onPressed: () {
                Provider.of<StatsDate>(context, listen: false).forwardOneWeek();
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
      initialDate: Provider.of<StatsDate>(context, listen: false).date,
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2100)
    );
    if (picked != null && picked != Provider.of<StatsDate>(context, listen: false).date) {
      Provider.of<StatsDate>(context, listen: false).date = picked;
    }
  }
}


class HistoryListContainer extends StatelessWidget {
  const HistoryListContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: HistoryList(
          records: Provider.of<Records>(context, listen: true).recordsOf(
            Provider.of<StatsDate>(context, listen: true).date
          ),
          onRecordDeleted: (id) => Provider.of<Records>(context, listen: false).remove(id),
          onRecordUpdated: (id, newRecord) => Provider.of<Records>(context, listen: false).updateRecord(id, newRecord),
          onUndoDelete: (oldRecord) => Provider.of<Records>(context, listen: false).add(oldRecord),
        ),
      ),
    );
  }
}