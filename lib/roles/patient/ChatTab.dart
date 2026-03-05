import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, placeholder list of chats
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text("Dr. Aisha Khan"),
          subtitle: Text("Hi, how are you feeling today?"),
          trailing: Icon(Icons.chat),
        ),
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text("Dr. Ahmed"),
          subtitle: Text("Your lab results are ready."),
          trailing: Icon(Icons.chat),
        ),
      ],
    );
  }
}
