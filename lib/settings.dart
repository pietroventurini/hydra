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
          Text(
            "Set your daily goal",
            style: TextStyle(
              fontFamily: 'Avenir',
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            _goalMl.toInt().toString() + " ml",
            style: Theme.of(context).textTheme.headline5
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
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Cancel"),
    );

    final saveBtn = ElevatedButton(
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
            Navigator.pop(context);
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
          });
      },
      child: const Text("Save"),
    );

    final buttons = Row(
      children: [
        cancelBtn, 
        saveBtn
      ],
    );

    return Center(
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: Decorations.cardDecoration,
          child: Center(
            child: Column(
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