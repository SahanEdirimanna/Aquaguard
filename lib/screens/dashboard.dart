//import 'package:aquaguard/globals.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
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
  //DateTime lastFeedTime = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // Example: Current time in GMT+5:30
  DateTime lastFeedTime = globals.globalTimefull;

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

    // Start a periodic timer to calculate feeding time in real-time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // Cancel the timer if the widget is no longer mounted
      } else {
        _calculateFeedingTimes();
      }
    });
  }

  void _calculateFeedingTimes() {
    try {
      // Parse global time and interval
      final DateTime now = DateTime.now(); // Current time
      final int interval = int.tryParse(globals.globalInterval) ?? 0;

      // Calculate next feeding time
      DateTime nextFeedTime = lastFeedTime.add(Duration(minutes: interval));

      // Check if the next feed time has passed or is equal to the current time
      if (!nextFeedTime.isAfter(now)) {
        // Update last feed time to the current next feed time
        lastFeedTime = nextFeedTime;
        globals.globalTimefull = nextFeedTime; // Update the global last feed time

        // Recalculate the next feed time
        nextFeedTime = lastFeedTime.add(Duration(minutes: interval));
      }

      // Calculate remaining time
      final Duration remainingDuration = nextFeedTime.difference(now);

      setState(() {
        _nextFeedTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(nextFeedTime); // Format next feed time with seconds
        _timeRemaining = remainingDuration.isNegative
            ? 'Feeding overdue'
            : '${remainingDuration.inHours} hours ${remainingDuration.inMinutes % 60} minutes ${remainingDuration.inSeconds % 60} seconds';
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
            //Text('global time: ${globals.globalTime}'),
            //Text('global timefulll: ${globals.globalTimefull}'),
            //Text('Interval: ${globals.globalInterval}'),
            //Text('last feed time: $lastFeedTime'),

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
                      'Feeding Times',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Icon(Icons.access_time, color: Colors.blue, size: 24.0),
                        Text(
                          'Last Fed Time',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        DateFormat('yyyy-MM-dd hh:mm:ss a').format(lastFeedTime),
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24.0, thickness: 1.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Icon(Icons.schedule, color: Colors.green, size: 24.0),
                        Text(
                          'Next Feed Time',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _nextFeedTime,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24.0, thickness: 1.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Icon(Icons.timer, color: Colors.red, size: 24.0),
                        Text(
                          'Time Remaining',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _timeRemaining,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      ],
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