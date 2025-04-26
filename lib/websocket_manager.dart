// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:aquaguard/globals.dart' as globals;

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  late WebSocketChannel _generalChannel;
  late WebSocketChannel _criticalChannel;
  late WebSocketChannel _dataChannel; // Add dataChannel for dashboard data

  final List<Map<String, dynamic>> generalNotifications = [];
  final List<Map<String, dynamic>> criticalNotifications = [];

  void initialize(String deviceId) {
    _generalChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/notifications/general/${globals.globalDeviceId}'),
    );

    _criticalChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/notifications/critical/${globals.globalDeviceId}'),
    );

    _dataChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/data/${globals.globalDeviceId}'),
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

    // Listen to dashboard data
    _dataChannel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message);
        if (decodedMessage is Map<String, dynamic>) {

          // Update global data
          final newEntry = {
            'time': DateTime.now(),
            'temperature': decodedMessage['temperature'],
            'pH': decodedMessage['pH'],
            'turbidity': decodedMessage['turbidity'],
            'tds_value': decodedMessage['tds_value'],
          };
          globals.globalData.add(newEntry);

          if (globals.globalData.length > 10) {
            globals.globalData.removeAt(0);
          }
        }
      } catch (e) {
        //print('Error decoding dashboard data: $e');
      }
    });

  }

  void dispose() {
    _generalChannel.sink.close(status.goingAway);
    _criticalChannel.sink.close(status.goingAway);
    _dataChannel.sink.close(status.goingAway); // Close dataChannel
  }
}