import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

String globalDeviceId = '2';
String globalTime = '';
String globalInterval = '10';
DateTime globalTimefull = DateTime.now();

List<Map<String, dynamic>> globalData = [];

Future<void> initializeGlobals() async {
  // WebSocket connection URL
  final String webSocketUrl = 'ws://159.89.173.231:1880/ws/dashboard/database/$globalDeviceId';

  // Connect to the WebSocket
  final channel = WebSocketChannel.connect(Uri.parse(webSocketUrl));

  // Listen for messages from the WebSocket
  channel.stream.listen((message) {
    try {
      // Decode the received message
      final decodedMessage = jsonDecode(message);

      // Check if the message is an array of objects
      if (decodedMessage is List) {
        // Convert the array into globalData
        globalData = decodedMessage.map((entry) {
          return {
            'time': DateTime.parse(entry['timestamp']),
            'temperature': entry['temperature'],
            'pH': entry['pH'] ?? 7.0, // Default pH if not provided
            'turbidity': entry['turbidity'] ?? 0.0, // Default turbidity if not provided
            'tds_value': entry['tds_value'] ?? 0.0, // Default TDS value if not provided
          };
        }).toList();
      }
    } catch (e) {
      //print('Error processing WebSocket message: $e');
    }
  }, onError: (error) {
    //print('WebSocket error: $error');
  }, onDone: () {
    //print('WebSocket connection closed');
  });
}