import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_flutter/utils/ColorLoaders.dart';
import '../../../../models/contact.dart';
import '../../../../models/user.dart';
import '../../../../provider/user_provider.dart';
import '../../../../resources/auth_methods.dart';
import '../../../../resources/chat_methods.dart';
import '../../../../screens/chatscreens/chat_screen.dart';
import '../../../../screens/chatscreens/widgets/cached_image.dart';
import '../../../../widgets/custom_tile.dart';

import 'last_message_container.dart';
import 'online_dot_indicator.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
          child: ColorLoader2(
            color3: Colors.green,
            color2: Colors.greenAccent,
            color1: Colors.lightGreenAccent,
          ),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        (contact != null ? contact.name : null) != null ? contact.name : "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Circular", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid,
          receiverId: contact.uid,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 20.0,
              child: CircleAvatar(
                radius: 18.0,
                child: CachedImage(
                  contact.profilePhoto,
                  radius: 70,
                  isRound: true,
                ),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 0,
              child: OnlineDotIndicator(
                uid: contact.uid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
