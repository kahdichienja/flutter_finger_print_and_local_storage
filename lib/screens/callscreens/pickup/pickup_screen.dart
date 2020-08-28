import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_flutter/provider/notification_provider.dart';
import '../../../constants/strings.dart';
import '../../../models/call.dart';
import '../../../models/log.dart';
import '../../../resources/call_methods.dart';
import '../../../resources/local_db/repository/log_repository.dart';
import '../../../screens/callscreens/call_screen.dart';
import '../../../screens/chatscreens/widgets/cached_image.dart';
import '../../../utils/permissions.dart';
import '../../home_screen.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  // final LogRepository logRepository = LogRepository(isHive: true);
  // final LogRepository logRepository = LogRepository(isHive: false);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  @override
  void initState() {
    super.initState();
    initializing();
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  void _showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Missed Incoming call...', 'Please Tap To View.', notificationDetails);
  }

  Future<void> notificationAfterSec() async {
    var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(1, 'Hello there',
        'please subscribe my channel', timeDelayed, notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }

    // we can set navigator to navigate another screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  bool isCallMissed = true;

  addToLocalStorage({@required String callStatus}) {
    
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      FlutterRingtonePlayer.stop();
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
      _showNotifications();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final notificationWhenCall = Provider.of<UserNotificationProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Incoming...",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 50),
              CircleAvatar(
                child: CachedImage(
                  widget.call.callerPic,
                  isRound: true,
                  radius: 180,
                ),
              ),
              SizedBox(height: 15),
              Text(
                widget.call.callerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.call_end),
                    color: Colors.redAccent,
                    onPressed: () async {
                      isCallMissed = false;
                      addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                      FlutterRingtonePlayer.stop();
                      await callMethods.endCall(call: widget.call);
                    },
                  ),
                  SizedBox(width: 25),
                  IconButton(
                      icon: Icon(Icons.call),
                      color: Colors.green,
                      onPressed: () async {
                        isCallMissed = false;
                        addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                        FlutterRingtonePlayer.stop();
                        await Permissions
                                .cameraAndMicrophonePermissionsGranted()
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(call: widget.call),
                                ),
                              )
                            : {};
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
