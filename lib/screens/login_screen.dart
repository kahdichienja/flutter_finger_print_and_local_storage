import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/ColorLoaders.dart';
import '../resources/auth_methods.dart';
// import 'package:shimmer/shimmer.dart';
import '../utils/universal_variables.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UniversalVariables.gradientColorEnd,
        body: Container(
          color: Colors.indigo[100],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(image: AssetImage("assets/logo.png"), height: 200.0),
                SizedBox(height: 5),
                Center(
                  child: loginButton(),
                ),
                isLoginPressed
                    ? Center(
                        child: ColorLoader2(
                          color3: Colors.green,
                          color2: Colors.greenAccent,
                          color1: Colors.lightGreenAccent,
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ));
  }

  Widget loginButton() {
    return OutlineButton(
      splashColor: Colors.white,
      onPressed: () => performLogin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.green),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget _signInButton() {
  //   return Shimmer.fromColors(
  //     baseColor: Colors.white,
  //     highlightColor: UniversalVariables.senderColor,
  //     child: FlatButton(
  //       padding: EdgeInsets.all(35),
  //       child: Text(
  //         "Sign In With Google",
  //         style: TextStyle(
  //             fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 0.9),
  //       ),
  //       onPressed: () => performLogin(),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //   );
  // }

  void performLogin() async {
    setState(() {
      isLoginPressed = true;
    });

    FirebaseUser user = await _authMethods.signIn();

    if (user != null) {
      authenticateUser(user);
    }
    setState(() {
      isLoginPressed = false;
    });
  }

  void authenticateUser(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
