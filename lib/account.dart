import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/services/authentication_service.dart';
import 'package:hydra/settings.dart';
import 'package:provider/provider.dart';
import 'package:hydra/decorations/card.dart' as Decorations;

class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    //final user = context.watch<User?>();

    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: Decorations.getCardDecoration(gradient: Decorations.whiteLinearGradient),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: "assets/images/account/placeholder.png",
                        image: user.photoURL!
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                    child: Text(
                      user.displayName!,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Text(
                    user.email ?? "not specified",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  /*Text(
                    "UID: ${user.uid}"
                  ),*/
                  SizedBox(height: 40),
                  Text(
                    "Hydra helps you to keep track of your daily water intake. " + 
                    "Set up your daily goal in the settings menu and Hydra will remind you to drink!",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: size.height * 0.27),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          primary: Color.fromARGB(255, 62, 87, 117),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          elevation: 2,
                          shape: StadiumBorder(),
                          ),
                      ),
                      SizedBox(width: 20,),
                      ElevatedButton.icon( // logout button
                        label: Text(
                          "Logout",
                        ),
                        icon: Icon(Icons.logout_rounded),
                        onPressed: () {
                          context.read<AuthenticationService>().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 62, 87, 117),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          elevation: 2,
                          shape: StadiumBorder(),
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
