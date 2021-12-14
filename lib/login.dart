import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:hydra/services/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Login page"),
            SizedBox(height: size.height * 0.05),
            SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: () {
                context.read<AuthenticationService>().signInWithGoogle();
              },
            ),
          ],
        ),
      ),
    );
  }
}