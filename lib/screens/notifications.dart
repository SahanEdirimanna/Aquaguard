import 'dart:convert'; // For JSON decoding
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
  final List<Map<String, dynamic>> _notifications = []; // Store parsed notifications

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message); // Parse JSON message
        setState(() {
          _notifications.add(decodedMessage); // Add parsed message to the list
        });
      } catch (e) {
        print('Error decoding message: $e'); // Handle invalid JSON
      }
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
      body: _notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Text(
                      notification['general_message'] ?? 'No message',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification['warnings'] != null)
                          Text(
                            'Warnings: ${notification['warnings']}',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (notification['timestamp'] != null)
                          Text(
                            'Checked on: ${notification['timestamp']}',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                    onTap: () {
                      // Handle notification tap (e.g., show details)
                    },
                  ),
                );
              },
            ),
    );
  }
}