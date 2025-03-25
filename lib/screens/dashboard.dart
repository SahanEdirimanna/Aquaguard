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
  late WebSocketChannel _feedingChannel; // WebSocket for feeding notifications

  Map<String, dynamic> _data = {};

  String _nextFeedTime = 'Calculating...';
  String _timeRemaining = 'Calculating...';

  // Define lastFeedTime with a default value
  DateTime lastFeedTime = globals.globalTimefull;

  @override
  void initState() {
    super.initState();

    // WebSocket for dashboard data
    _dataChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/data/${globals.globalDeviceId}'),
    );

    // WebSocket for feeding notifications
    _feedingChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/feeding/${globals.globalDeviceId}'),
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
    final DateTime now = DateTime.now(); // Get current time
    final int interval = int.tryParse(globals.globalInterval) ?? 0;

    // If lastFeedTime is set in the future, wait until it's time
    if (lastFeedTime.isAfter(now)) {
      final Duration remainingDuration = lastFeedTime.difference(now);
      
      setState(() {
      _nextFeedTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(lastFeedTime);
      _timeRemaining = '${remainingDuration.inHours} H ${remainingDuration.inMinutes % 60} Min ${remainingDuration.inSeconds % 60} Sec';
      });

      // Check if the remaining duration is very close to zero
      /*if (remainingDuration.inSeconds == 0) {
        
        // Send feeding message via WebSocket
       _feedingChannel.sink.add('Future Set time reached! Feeding fish now');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Future Set time reached! Feeding fish now'),
        duration: Duration(seconds: 2),
        ),
      );
      }*/

      return; // Exit function early to avoid unnecessary feeding
    }

    // Calculate next feed time
    DateTime nextFeedTime = lastFeedTime.add(Duration(seconds: interval));

    // If it's time to feed the fish
    if (!nextFeedTime.isAfter(now)) {
      // Send feeding message via WebSocket
      //_feedingChannel.sink.add('Feeding fish now');

      // Show SnackBar notification
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feeding fish now'),
          duration: Duration(seconds: 2),
        ),
      );*/

      // Update lastFeedTime to the existing nextFeedTime
      lastFeedTime = nextFeedTime;
      globals.globalTimefull = nextFeedTime; // Update global last feed time

      // Recalculate next feeding time
      nextFeedTime = lastFeedTime.add(Duration(seconds: interval));
    }

    // Calculate remaining time until next feeding
    final Duration remainingDuration = nextFeedTime.difference(now);

    // Update UI with next feeding time
    setState(() {
      _nextFeedTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(nextFeedTime);
      _timeRemaining = remainingDuration.isNegative
          ? 'Feeding overdue'
          : '${remainingDuration.inHours} H ${remainingDuration.inMinutes % 60} Min ${remainingDuration.inSeconds % 60} Sec';
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
    _feedingChannel.sink.close(); // Close the feeding WebSocket
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                  'Feeding Times',
                  style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 91, 31, 229),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  if (lastFeedTime.isAfter(DateTime.now()))
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.access_time, color: Colors.blue, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                    'Future Feeding Time :',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                    DateFormat('yyyy-MM-dd hh:mm:ss a').format(lastFeedTime),
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    ),
                    ],
                    )
                  else ...[
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.access_time, color: Colors.blue, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                    'Last Fed Time :',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                    DateFormat('yyyy-MM-dd hh:mm:ss a').format(lastFeedTime),
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    ),
                    ],
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(height: 16.0, thickness: 0.5),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.schedule, color: Colors.green, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                    'Next Feeding Time :',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                    _nextFeedTime,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    ),
                    ],
                    ),
                  ],
                  const Divider(height: 16.0, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.timer, color: Colors.red, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Time Remaining :',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      _timeRemaining,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    ],
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

            const SizedBox(height: 16.0),

            // Button to send a message to the feeding channel
            ElevatedButton(
              onPressed: () {
              _feedingChannel.sink.add('device_id:${globals.globalDeviceId}; feed_now:1');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text('Manual feeding message sent'),
                duration: Duration(seconds: 2),
                ),
              );
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
              ),
              child: Text('Feed Now'),
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
        borderRadius: BorderRadius.circular(8.0), // Reduced border radius
      ),
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Added padding to make the card smaller
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36.0, color: Colors.blue), // Reduced icon size
              SizedBox(height: 4.0), // Reduced spacing
              Text(
                title,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0), // Reduced padding
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
      ),
    );
  }
}