import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aquaguard/websocket_manager.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final WebSocketManager _webSocketManager = WebSocketManager();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh the page every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // Trigger a rebuild to fetch new notifications
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generalNotifications = _webSocketManager.generalNotifications;
    final criticalNotifications = _webSocketManager.criticalNotifications;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: generalNotifications.isEmpty && criticalNotifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
          : ListView(
              children: [
                if (criticalNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Critical Notifications',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ...criticalNotifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final notification = entry.value;
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      setState(() {
                        criticalNotifications.removeAt(index);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: Card(
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
                      ),
                    ),
                  );
                }),
                if (generalNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'General Notifications',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ...generalNotifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final notification = entry.value;
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      setState(() {
                        generalNotifications.removeAt(index);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: Card(
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
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}