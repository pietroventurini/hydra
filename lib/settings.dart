import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/decorations/card.dart' as Decorations;


class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key, this.goalMl}) : super(key: key);

  final int? goalMl;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  int _goalMl = 1500;

  @override
  void initState() {
    super.initState();
    _goalMl = widget.goalMl ?? 1500;
  }

  @override
  Widget build(BuildContext context) {

    final goalMlSlider = Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: Text(
              "Set your daily goal",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          Text(
            "${_goalMl.toInt().toString()} ml",
            style: Theme.of(context).textTheme.headline6
          ),
          Slider(
            min: 0,
            max: 4000,
            divisions: 80,
            value: _goalMl.toDouble(), 
            onChanged: (double value) => setState(() {
              _goalMl = value.toInt();
            }),
          ),
        ],
      ),
    ); 

    final cancelBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 62, 87, 117),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        elevation: 2,
        shape: StadiumBorder(),
      ),
      onPressed: () {
        Navigator.pop(context, {"dailyGoalUpdated" : false});
      },
      child: const Text("Cancel"),
    );

    final saveBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 62, 87, 117),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        elevation: 2,
        shape: StadiumBorder(),
        ),
      onPressed: () {
        const successSnackBar = SnackBar(
          content: Text('Goal Updated'),
        );

        const errorSnackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unable to save changes'),
        );

        // save changes to server
        Repository(FirebaseFirestore.instance)
          .updateDailyGoalMl(_goalMl.toInt())
          .then((value) {
            ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
            Navigator.pop(context, {"dailyGoalUpdated": true});
          })
          .catchError((error) {
            ScaffoldMessenger.of(context,).showSnackBar(errorSnackBar);
          });
      },
      child: const Text("Save"),
    );

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        cancelBtn, 
        saveBtn
      ],
    );

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(14.0),
        height: 400,
        width: double.infinity,
        decoration: Decorations.getCardDecoration(gradient: Decorations.whiteLinearGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              goalMlSlider,
              buttons
            ],
          ),
        ),
      ),
    );
  }
}