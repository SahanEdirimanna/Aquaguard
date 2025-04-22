import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // For formatting DateTime
import 'package:aquaguard/globals.dart' as globals;
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late WebSocketChannel _dataChannel;
  late WebSocketChannel _feedingChannel; // WebSocket for feeding notifications

 Map<String, dynamic> _data = {
  'device_id': 'Unknown',
  'power_level': 0,
  'pH': 7.0, // Default pH is neutral
  'temp': 25.0, // Default temperature
  'turbidity': 0.0,
  'tds_value': 0.0,
};

  String _nextFeedTime = 'Calculating...';
  String _timeRemaining = 'Calculating...';

  // Define lastFeedTime with a default value
  DateTime lastFeedTime = globals.globalTimefull;

  List<Map<String, dynamic>> temperatureData = [
    {'time': DateTime.now().subtract(Duration(minutes: 10)), 'temperature': 25.0},
    {'time': DateTime.now().subtract(Duration(minutes: 8)), 'temperature': 26.5},
    {'time': DateTime.now().subtract(Duration(minutes: 6)), 'temperature': 27.0},
    {'time': DateTime.now().subtract(Duration(minutes: 4)), 'temperature': 26.8},
    {'time': DateTime.now().subtract(Duration(minutes: 2)), 'temperature': 27.5},
  ]; // Data for temperature chart

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
      final decodedMessage = jsonDecode(message);
      setState(() {
        _data = {
        'device_id': decodedMessage['device_id'] ?? 'Unknown',
        'power_level': decodedMessage['power_level'] ?? 'Unknown',
        'pH': decodedMessage['pH'] ?? 'Unknown', // Default pH is neutral
        'temp': decodedMessage['temp'] ?? 'Unknown', // Default temperature
        'turbidity': decodedMessage['turbidity'] ?? 'Unknown',
        'tds_value': decodedMessage['tds_value'] ?? 'Unknown',
    };

        // Add new temperature data
        if (decodedMessage['temp'] != null) {
          temperatureData.add({
            'time': DateTime.now(),
            'temperature': decodedMessage['temp'],
          });

          // Keep only the last 10 data points
          if (temperatureData.length > 10) {
            temperatureData.removeAt(0);
          }
        }
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

        return; // Exit function early to avoid unnecessary feeding
      }

      // Calculate next feed time
      DateTime nextFeedTime = lastFeedTime.add(Duration(seconds: interval));

      // If it's time to feed the fish
      if (!nextFeedTime.isAfter(now)) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Device ID: ${globals.globalDeviceId}',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
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
              _data.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardCard(Icons.water_drop, 'pH', _data['pH']),
                        _buildDashboardCard(Icons.thermostat, 'Temperature', _data['temp']),
                        _buildDashboardCard(Icons.opacity, 'Turbidity', _data['turbidity']),
                        _buildDashboardCard(Icons.filter_alt, 'TDS Value', _data['tds_value']),
                      ],
                    ),

              const SizedBox(height: 16.0),

              // Temperature Chart
              _buildTemperatureChart(),

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

  Widget _buildTemperatureChart() {
    // Limit the data to the last 10 points
    final limitedTemperatureData = temperatureData.length > 10
        ? temperatureData.sublist(temperatureData.length - 10)
        : temperatureData;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Time vs Temperature',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0, // Set the height of the chart
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true), // Hide grid lines
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1), // Show y-axis values
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide right titles
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide top titles
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < limitedTemperatureData.length) {
                            final time = limitedTemperatureData[index]['time'] as DateTime;
                            return Text(
                              DateFormat('HH:mm').format(time), // Show x-axis values
                              style: TextStyle(fontSize: 10.0),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: limitedTemperatureData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value['temperature'] as double,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4.0,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}