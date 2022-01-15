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

    Size size = MediaQuery.of(context).size;

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
          SizedBox(height: size.height * 0.05),
          ElevatedButton.icon( // settings button
            label: Text(
              "Settings",
            ),
            icon: Icon(Icons.settings_rounded),
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
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                    ),
                  );
                }),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              elevation: 2,
              shape: StadiumBorder(),
              ),
          ),
          SizedBox(height: size.height * 0.05),
          ElevatedButton.icon( // logout button
            label: Text(
              "Logout",
            ),
            icon: Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              elevation: 2,
              shape: StadiumBorder(),
              ),
          ),
        ],
      ),
    );
  }
}
