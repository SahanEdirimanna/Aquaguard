import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://159.89.173.231:1880/ws/notifications'));
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      setState(() {
        _notifications.add(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification ${index + 1}'),
            subtitle: Text(_notifications[index]),
            onTap: () {
              // Handle notification tap
            },
          );
        },
      ),
    );
  }
}