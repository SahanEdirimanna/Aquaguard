import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late WebSocketChannel _channel;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard'), // Replace with your WebSocket URL
    );

    _channel.stream.listen((message) {
      setState(() {
        _data = jsonDecode(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _data.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildDashboardCard(Icons.water_drop, 'pH', _data['pH']),
                  _buildDashboardCard(Icons.thermostat, 'Temperature', _data['temperature']),
                  _buildDashboardCard(Icons.opacity, 'Turbidity', _data['turbidity']),
                  _buildDashboardCard(Icons.filter_alt, 'TDS Value', _data['tds_value']),
                ],
              ),
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, dynamic value) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Colors.blue),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  value.toString(),
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}