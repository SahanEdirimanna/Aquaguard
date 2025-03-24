// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  late WebSocketChannel _generalChannel;
  late WebSocketChannel _criticalChannel;

  final List<Map<String, dynamic>> generalNotifications = [];
  final List<Map<String, dynamic>> criticalNotifications = [];

  void initialize(String deviceId) {
    _generalChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/notifications/general/$deviceId'),
    );

    _criticalChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/notifications/critical/$deviceId'),
    );

    // Listen to general notifications
    _generalChannel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message);
        if (decodedMessage is Map<String, dynamic>) {
          generalNotifications.add(decodedMessage);
        }
      } catch (e) {
        //print('Error decoding general notification: $e');
      }
    });

    // Listen to critical notifications
    _criticalChannel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message);
        if (decodedMessage is Map<String, dynamic>) {
          criticalNotifications.add(decodedMessage);
        }
      } catch (e) {
        //print('Error decoding critical notification: $e');
      }
    });
  }

  void dispose() {
    _generalChannel.sink.close(status.goingAway);
    _criticalChannel.sink.close(status.goingAway);
  }
}