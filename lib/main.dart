// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dashboard.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'config/colors.dart';
import 'config/utility.dart';
// new
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'provider/image_upload_provider.dart';
import 'provider/notification_provider.dart';
import 'provider/user_provider.dart';
import 'resources/auth_methods.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
      ],
      child: MaterialApp(
        title: "@VideoCall Chienja",
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/search_screen': (context) => SearchScreen(),
        },
        theme: ThemeData(brightness: Brightness.dark),
        home: FutureBuilder(
          future: _authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authMethods.getUserDetails(),
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class LoginPageWithBioMet extends StatefulWidget {
  @override
  _LoginPageWithBioMetState createState() => _LoginPageWithBioMetState();
}

class _LoginPageWithBioMetState extends State<LoginPageWithBioMet> {
  bool _rememberMe = false;
  final TextEditingController _usernameOrMailController =
      TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  FlutterSecureStorage storage;
  bool userHasTouchId = false;

  // bool useBioMet = false; //_useTouchId
  void _decrypt() async {
    //read from the secure storage
    final isUsingBio = await storage.read(key: 'useBioMet');
    setState(() {
      userHasTouchId = isUsingBio == 'true';
    });
  }

  void _loginWithFingerPrint() async {
    final LocalAuthentication _localAuthentication = LocalAuthentication();
    // reading data from secure storage.
    final username = await storage.read(key: 'username');
    final pwd = await storage.read(key: 'password');

    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    // if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric Auth is available!')
        : print('Biometric is unavailable.');

    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    print(listOfBiometrics);

    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Do You Want To Use Biometric For Login.",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated
        ? print('User is authenticated!')
        : print('User is not authenticated.');

    if (isAuthenticated) {
      // Here you can pass username and pwd to login Function to Auth With Server and obtain token.
      print('$username');
      print('$pwd');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    storage = FlutterSecureStorage();
    _decrypt();
  }

  @override
  void dispose() {
    super.dispose();
    storage = null;
  }

  void _encrypt(String username, String password) async {
    // var stopwatch = new Stopwatch()..start();

    //write to the secure storage
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'useBioMet', value: 'true');

    print('Encrypting and saving $username');
    print('Encrypting and saving $password');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DashboardPage(),
      ),
    );
  }

  void displayDialog(context, DialogType title, text) => AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: title,
      body: Text(text));

  Future<String> attemptLogIn(
      String username, String password, bool bioMetCheck) async {
    print('Email: $username Pwd: $password BioCheck: $bioMetCheck');

    final LocalAuthentication _localAuthentication = LocalAuthentication();

    Future<bool> _isBiometricAvailable() async {
      bool isAvailable = false;
      try {
        isAvailable = await _localAuthentication.canCheckBiometrics;
      } on PlatformException catch (e) {
        print(e);
      }

      if (!mounted) return isAvailable;

      isAvailable
          ? print('Biometric Auth is available!')
          : print('Biometric is unavailable.');

      return isAvailable;
      // ...
    }

    // To retrieve the list of biometric types
    // (if available).
    Future<void> _getListOfBiometricTypes() async {
      List<BiometricType> listOfBiometrics;
      try {
        listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
      } on PlatformException catch (e) {
        print(e);
      }

      if (!mounted) return;

      print(listOfBiometrics);
      // ...
    }

    // Process of authentication user using
    // biometrics.
    Future<void> _authenticateUser() async {
      bool isAuthenticated = false;
      try {
        isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
          localizedReason: "Do You Want To Use Biometric For Next Login.",
          useErrorDialogs: true,
          stickyAuth: true,
        );
      } on PlatformException catch (e) {
        print(e);
      }

      if (!mounted) return;

      isAuthenticated
          ? print('User is authenticated!')
          : print('User is not authenticated.');

      if (isAuthenticated) {
        _encrypt(username, password);
        print('$username');
      }
      // ...
    }

    if (username.length <= 4) print('username Must Have 4 chars long');
    if (password.length <= 8) print('password Must Have 8 chars long');

    bioMetCheck == true
        ? await _authenticateUser()
        : Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => DashboardPage()));

    return username;
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _usernameOrMailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Circular',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter Username',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _pwdController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Circular',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => {},
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: userHasTouchId ? 35 : 20.0,
      child: userHasTouchId
          ? RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 5.0,
              color: Colors.white,
              onPressed: () => _loginWithFingerPrint(),
              child: Icon(
                Icons.fingerprint,
                color: Colors.blueAccent,
              ),
            )
          : Row(
              children: <Widget>[
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white),
                  child: Checkbox(
                    value: _rememberMe,
                    checkColor: Colors.green,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                  ),
                ),
                Text(
                  'Sign me with finger print on next login',
                  style: kLabelStyle,
                ),
              ],
            ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 25.0),
        width: double.infinity,
        child: userHasTouchId
            ? Center(
                child: Text(
                'Press The Finger Print Button',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ))
            : RaisedButton(
                elevation: 5.0,
                onPressed: () async {
                  var username = _usernameOrMailController.text;
                  var password = _pwdController.text;
                  var bioMetCheck = _rememberMe;

                  var userData =
                      await attemptLogIn(username, password, bioMetCheck);

                  if (userData == null) {
                    print('ok');

                    displayDialog(context, DialogType.ERROR,
                        "No account was found matching that username and password");
                  }
                },
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.white,
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Color(0xFF527DAA),
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Circular',
                  ),
                ),
              ));
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => print('Login with Face'),
            AssetImage(
              'assets/images/face.png',
            ),
          ),
          _buildSocialBtn(
            () => print('Login with Finger'),
            AssetImage(
              'assets/images/fingerprint.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradientColor1,
                      AppColors.gradientColor2,
                      AppColors.gradientColor3,
                      AppColors.gradientColor4,
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Circular',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Form(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30.0),
                            _buildEmailTF(),
                            SizedBox(
                              height: 30.0,
                            ),
                            _buildPasswordTF(),
                            _buildForgotPasswordBtn(),
                            _buildRememberMeCheckbox(),
                            _buildLoginBtn(),
                            _buildSignInWithText(),
                            _buildSignupBtn(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
