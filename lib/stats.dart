import 'package:flutter/material.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Stats',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}
