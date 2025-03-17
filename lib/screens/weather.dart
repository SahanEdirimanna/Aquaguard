import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketPage extends StatefulWidget {
  const WebSocketPage({super.key});

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  Map<String, dynamic> _data = {};
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
      try {
        final data = jsonDecode(message);
        setState(() {
          _data = data;
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
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
        title: Text("Weather Data"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              if (_data.isNotEmpty) ...[
                buildDataCard('Location', _data['location']),
                buildDataCard('Weather', _data['weather']),
                buildDataCard('Detail', _data['detail']),
                buildDataCard('Icon', _data['icon']),
                buildDataCard('Temperature (K)', _data['tempk']),
                buildDataCard('Temperature (C)', _data['tempc']),
                buildDataCard('Max Temperature (C)', _data['temp_maxc']),
                buildDataCard('Min Temperature (C)', _data['temp_minc']),
                buildDataCard('Humidity', _data['humidity']),
                buildDataCard('Pressure', _data['pressure']),
                buildDataCard('Max Temperature (K)', _data['maxtemp']),
                buildDataCard('Min Temperature (K)', _data['mintemp']),
                buildDataCard('Wind Speed', _data['windspeed']),
                buildDataCard('Wind Direction', _data['winddirection']),
                buildDataCard('Sunrise', DateTime.fromMillisecondsSinceEpoch(_data['sunrise'] * 1000).toString()),
                buildDataCard('Sunset', DateTime.fromMillisecondsSinceEpoch(_data['sunset'] * 1000).toString()),
                buildDataCard('Clouds', _data['clouds']),
                buildDataCard('Description', _data['description']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDataCard(String title, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(value.toString(), style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}