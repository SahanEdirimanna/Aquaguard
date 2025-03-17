import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  String _message = '';
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      channel.sink.add(message);
    }
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/info'), // Replace with your WebSocket URL
    );

    channel.stream.listen((message) {
      print('Received message: $message'); // Debugging statement
      setState(() {
        _message = message;
      });
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversation"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
          'Person 1 talking over here',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter message',
          ),
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Send Message'),
          ),
          const SizedBox(height: 20),
            Text(
            'Person 2 talking over here',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          if (_message.isNotEmpty)
            Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _message,
            style: TextStyle(fontSize: 16),
          ),
            ),
        ],
          ),
        ),
      ),
        );
      }
    }
