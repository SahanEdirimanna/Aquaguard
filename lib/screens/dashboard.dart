//import 'package:aquaguard/globals.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For formatting DateTime
import 'package:aquaguard/globals.dart' as globals;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late WebSocketChannel _dataChannel;

  Map<String, dynamic> _data = {};

  String _nextFeedTime = 'Calculating...';
  String _timeRemaining = 'Calculating...';

  // Define lastFeedTime with a default value
  DateTime lastFeedTime = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // Example: Current time in GMT+5:30
  //DateTime lastFeedTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(globals.globalTime);

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

    // Calculate next feeding time and remaining time
    _calculateFeedingTimes();
  }

  void _calculateFeedingTimes() {
    try {
      // Parse global time and interval
      final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // Current time in GMT+5:30
   
        
      final int interval = int.tryParse(globals.globalInterval) ?? 0;

      // Calculate next feeding time
      final DateTime nextFeedTime = lastFeedTime.add(Duration(hours: interval));

      // Calculate remaining time
      final Duration remainingDuration = nextFeedTime.difference(now);

      setState(() {
        _nextFeedTime = DateFormat('yyyy-MM-dd hh:mm a').format(nextFeedTime); // Format next feed time
        _timeRemaining = remainingDuration.isNegative
            ? 'Feeding overdue'
            : '${remainingDuration.inHours} hours ${remainingDuration.inMinutes % 60} minutes';
      });
    } catch (e) {
      setState(() {
        _nextFeedTime = 'Error calculating time';
        _timeRemaining = 'Error calculating time';
      });
    }
  }

  @override
  void dispose() {
    _dataChannel.sink.close();
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
            //Text('Time: ${globals.globalTime}'),
            //Text('Interval: ${globals.globalInterval}'),
            const SizedBox(height: 16.0),

            // Feeding Time Panel
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Text(
                      'Next Feeding Time',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Next Feed Time: $_nextFeedTime',
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Time Remaining: $_timeRemaining',
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
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