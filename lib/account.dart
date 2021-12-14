import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydra/services/authentication_service.dart';
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
              context.read<AuthenticationService>().signOut();
            }, 
            child: Text("sign out")
          )
        ],
      ),
    );
  }
}
