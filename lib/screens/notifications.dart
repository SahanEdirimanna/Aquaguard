import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:aquaguard/globals.dart' as globals;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final WebSocketChannel _generalChannel =
      WebSocketChannel.connect(Uri.parse('ws://159.89.173.231:1880/ws/notifications/general/${globals.globalDeviceId}'));
  final WebSocketChannel _criticalChannel =
      WebSocketChannel.connect(Uri.parse('ws://159.89.173.231:1880/ws/notifications/critical/${globals.globalDeviceId}'));

  final List<Map<String, dynamic>> _generalNotifications = []; // Store general notifications
  final List<Map<String, dynamic>> _criticalNotifications = []; // Store critical notifications

  @override
  void initState() {
    super.initState();

    // Listen to general notifications
    _generalChannel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message); // Parse JSON message
        setState(() {
          _generalNotifications.add(decodedMessage); // Add parsed message to the list
        });
      } catch (e) {
        print('Error decoding general notification: $e'); // Handle invalid JSON
      }
    });

    // Listen to critical notifications
    _criticalChannel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message); // Parse JSON message
        setState(() {
          _criticalNotifications.add(decodedMessage); // Add parsed message to the list
        });
      } catch (e) {
        print('Error decoding critical notification: $e'); // Handle invalid JSON
      }
    });
  }

  @override
  void dispose() {
    _generalChannel.sink.close(status.goingAway);
    _criticalChannel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: _generalNotifications.isEmpty && _criticalNotifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
          : ListView(
              children: [
                if (_criticalNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Critical Notifications',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ..._criticalNotifications.map((notification) {
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        notification['general_message'] ?? 'No message',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notification['power_on'] != null)
                            Text(
                              'Power On: ${notification['power_on']}',
                              style: TextStyle(color: Colors.black),
                            ),
                          if (notification['timestamp'] != null)
                            Text(
                              'Checked on: ${notification['timestamp']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () {
                        // Handle critical notification tap (e.g., show details)
                      },
                    ),
                  );
                }).toList(),
                if (_generalNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'General Notifications',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ..._generalNotifications.map((notification) {
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
                        // Handle general notification tap (e.g., show details)
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}