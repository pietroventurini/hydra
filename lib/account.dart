import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/services/authentication_service.dart';
import 'package:hydra/settings.dart';
import 'package:provider/provider.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if we are sure user is authenticated
    final user = FirebaseAuth.instance.currentUser!;
    //final user = context.watch<User?>();

    print("UID:" + user.uid);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Account',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            user.email ?? "e-mail not specified"
          ),
          Text(
            "UID: " + user.uid
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    body: FutureBuilder<int>(
                      future: Repository(FirebaseFirestore.instance).getDailyGoal(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return SettingsTab(goalMl: snapshot.data);
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    ),
                  );
                }),
              );
            }, 
            child: Text("Settings")
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            }, 
            child: Text("sign out")
          )
        ],
      ),
    );
  }
}
