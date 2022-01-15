import 'package:flutter/material.dart';
import 'package:hydra/screens/login/background.dart';
import 'package:hydra/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "HYDRA",
              style: Theme.of(context).textTheme.headline2 //?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.05),
            SvgPicture.asset(
              "assets/images/drink/drink_blue_1.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.05),
            ElevatedButton.icon( // signup button
              label: Text(
                "Login with Google",
              ),
              icon: Icon(Icons.login_rounded),
              onPressed: (){
                context.read<AuthenticationService>().signInWithGoogle();
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 62, 87, 117),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                elevation: 4,
                shape: StadiumBorder(),
                ),
            ),
            /*SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: () {
                
              },
            ),*/
          ],
        ),
      ),
    );
  }
}