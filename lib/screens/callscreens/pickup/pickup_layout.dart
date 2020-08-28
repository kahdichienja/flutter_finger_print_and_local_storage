import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_flutter/utils/ColorLoaders.dart';
import '../../../models/call.dart';
import '../../../provider/user_provider.dart';
import '../../../resources/call_methods.dart';
import '../../../screens/callscreens/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                Call call = Call.fromMap(snapshot.data.data);

                if (!call.hasDialled) {
                  FlutterRingtonePlayer.playRingtone();
                  return PickupScreen(call: call);
                }
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: ColorLoader2(
                          color3: Colors.green,
                          color2: Colors.greenAccent,
                          color1: Colors.lightGreenAccent,
                        ),
            ),
          );
  }
}
