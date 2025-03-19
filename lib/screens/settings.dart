import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late WebSocketChannel _channel;
  final Map<String, TextEditingController> _fishControllers = {};
  final List<String> _fishTypes = ['Goldfish', 'Betta', 'Guppy', 'Tetra'];

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/settings'), // Replace with your WebSocket URL
    );

    // Initialize controllers for each fish type
    for (var fishType in _fishTypes) {
      _fishControllers[fishType] = TextEditingController();
    }
  }

  void _sendMessage() {
    final messages = _fishTypes.map((fishType) {
      final fishNumber = _fishControllers[fishType]?.text ?? '0';
      return 'Fish Type: $fishType, Number: $fishNumber';
    }).join('; ');

    if (messages.isNotEmpty) {
      _channel.sink.add(messages);
    }
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    for (var controller in _fishControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            subtitle: Text('Manage your account settings'),
            onTap: () {
              // Handle account settings tap
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy'),
            subtitle: Text('Manage privacy settings'),
            onTap: () {
              // Handle privacy settings tap
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Learn more about the app'),
            onTap: () {
              // Handle about tap
            },
          ),
          Divider(),
          ..._fishTypes.map((fishType) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fishType,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _fishControllers[fishType],
                    //keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter the number of $fishType',
                    ),
                  ),
                ],
              ),
            );
          }),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Send Message'),
          ),
        ],
      ),
    );
  }
}