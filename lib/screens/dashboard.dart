import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:aquaguard/globals.dart' as globals;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late WebSocketChannel _dataChannel;
  late WebSocketChannel _timeChannel;

  Map<String, dynamic> _data = {};
  Map<String, dynamic> _timeData = {};

  @override
  void initState() {
    super.initState();

    // WebSocket for dashboard data
    _dataChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/data/${globals.globalDeviceId}'),
    );

    _dataChannel.stream.listen((message) {
      setState(() {
        _data = jsonDecode(message);
      });
    });

    // WebSocket for time data
    _timeChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/time/${globals.globalDeviceId}'),
    );

    _timeChannel.stream.listen((message) {
      setState(() {
        _timeData = jsonDecode(message);
      });
    });
  }

  @override
  void dispose() {
    _dataChannel.sink.close();
    _timeChannel.sink.close();
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
        child: Column(
          children: [
            Text(
              'Device ID: ${globals.globalDeviceId}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Time Data Panel
            _timeData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Feeding Time',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Device ID: ${_timeData['device_id'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            'Next Feed Time: ${_timeData['next_feed_time'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            'Time Remaining: ${_timeData['time_remaining'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16.0),

            // Dashboard Data
            Expanded(
              child: _data.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      children: [
                        _buildDashboardCard(Icons.water_drop, 'pH', _data['pH']),
                        _buildDashboardCard(Icons.thermostat, 'Temperature', _data['temp']),
                        _buildDashboardCard(Icons.opacity, 'Turbidity', _data['turbidity']),
                        _buildDashboardCard(Icons.filter_alt, 'TDS Value', _data['tds_value']),
                      ],
                    ),
            ),
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
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 91, 31, 229),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}