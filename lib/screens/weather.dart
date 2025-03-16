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

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void _sendMessage() {
    final message = 'Hello from Flutter!';
    channel.sink.add(message);
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.120:1880/ws/data'), // Replace with your WebSocket URL
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
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('Say Hellp to nodered'),
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