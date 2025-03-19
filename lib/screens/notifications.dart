import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification 1'),
            subtitle: Text('This is the first notification'),
            onTap: () {
              // Handle notification tap
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification 2'),
            subtitle: Text('This is the second notification'),
            onTap: () {
              // Handle notification tap
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification 3'),
            subtitle: Text('This is the third notification'),
            onTap: () {
              // Handle notification tap
            },
          ),
        ],
      ),
    );
  }
}