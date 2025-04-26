import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
  late WebSocketChannel _feedingChannel; // WebSocket for feeding notifications

  String _nextFeedTime = 'Calculating...';
  String _timeRemaining = 'Calculating...';

  // Define lastFeedTime with a default value
  DateTime lastFeedTime = globals.globalTimefull;

  @override
  void initState() {
    super.initState();


    // WebSocket for feeding notifications
    _feedingChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/dashboard/feeding/${globals.globalDeviceId}'),
    );

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
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
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
                    globals.globalData.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                        _buildDashboardCard(Icons.water_drop, 'pH', globals.globalData.last['pH']),
                        _buildDashboardCard(Icons.thermostat, 'Temperature', globals.globalData.last['temperature']),
                        _buildDashboardCard(Icons.opacity, 'Turbidity', globals.globalData.last['turbidity']),
                        _buildDashboardCard(Icons.filter_alt, 'TDS Value', globals.globalData.last['tds_value']),
                        ],
                      ),

                  const SizedBox(height: 16.0),

                  // Temperature Chart
                  _buildTemperatureChart(),
                  const SizedBox(height: 16.0),

                // pH Chart
                  _buildpHChart(),
                  const SizedBox(height: 16.0),

                  _buildTurbidityChart(),
                  const SizedBox(height: 16.0),


                  _buildTDSChart(),
                  const SizedBox(height: 16.0),

                  // Display global data list
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                          child: Text(
                            'Recent Data Entries',
                            style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 91, 31, 229),
                            ),
                          ),
                          ),
                          const SizedBox(height: 8.0),
                          ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: globals.globalData.length,
                          itemBuilder: (context, index) {
                            final entry = globals.globalData[globals.globalData.length - 1 - index];
                            return ListTile(
                            leading: Icon(Icons.data_usage, color: Colors.blue),
                            title: Text(
                              'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(entry['time'])}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            subtitle: Text(
                              'Temperature: ${entry['temperature']}°C, pH: ${entry['pH']}, Turbidity: ${entry['turbidity']}, TDS: ${entry['tds_value']}',
                              style: TextStyle(fontSize: 12.0),
                            ),
                            );
                          },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                ],
              ),
            ),
          ),

          // Fixed "Feed Now" button at the bottom-right corner
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Add padding to position the button
              child: ElevatedButton(
                onPressed: () {
                  _feedingChannel.sink.add('device_id:${globals.globalDeviceId}; feed_now:1');
                  lastFeedTime = DateTime.now(); // Update lastFeedTime
                  globals.globalTimefull = lastFeedTime; // Update globalTimefull
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Manual feeding message sent'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                ),
                child: Text(
                  'Feed Now'
             ),
              ),

              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, dynamic value) {
    // Define ranges for each title
    Map<String, Map<String, double>> ranges = {
      'pH': {'min': 6.5, 'max': 8.5},
      'Temperature': {'min': 18.0, 'max': 30.0},
      'Turbidity': {'min': 0.0, 'max': 5.0},
      'TDS Value': {'min': 200.0, 'max': 500.0},
    };

    // Determine the color based on the value and range
    Color valueColor = Colors.blue; // Default color
    if (value != null && ranges.containsKey(title)) {
      double min = ranges[title]!['min']!;
      double max = ranges[title]!['max']!;
      if (value is num) {
        if (value < min) {
          valueColor = Colors.green;
        } else if (value > max) {
          valueColor = Colors.red;
        } else {
          valueColor = Colors.blue; // Within range
        }
      }
    }

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
              Icon(icon, size: 36.0, color: valueColor), // Reduced icon size
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
                      color: valueColor, // Set the color based on the range
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
    final limitedTemperatureData = globals.globalData.length > 10
        ? globals.globalData.sublist(globals.globalData.length - 10)
        : globals.globalData;

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
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                //color: Color.fromARGB(255, 91, 31, 229),
              ),
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
                          .where((entry) => entry.value['temperature'] != null && entry.value['temperature'] is num)
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                (entry.value['temperature'] as num).toDouble(),
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

  Widget _buildpHChart() {
    // Limit the data to the last 10 points
    final limitedpHData = globals.globalData.length > 10
        ? globals.globalData.sublist(globals.globalData.length - 10)
        : globals.globalData;

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
              'Time vs pH',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                //color: Color.fromARGB(255, 91, 31, 229),
              ),
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
                          if (index >= 0 && index < limitedpHData.length) {
                            final time = limitedpHData[index]['time'] as DateTime;
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
                      spots: limitedpHData
                          .asMap()
                          .entries
                          .where((entry) => entry.value['pH'] != null && entry.value['pH'] is num)
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                (entry.value['pH'] as num).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: const Color.fromARGB(255, 3, 195, 61),
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

Widget _buildTDSChart() {
    // Limit the data to the last 10 points
    final limitedTDSData = globals.globalData.length > 10
        ? globals.globalData.sublist(globals.globalData.length - 10)
        : globals.globalData;

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
              'Time vs TDS Value',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                //color: Color.fromARGB(255, 91, 31, 229),
              ),
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
                          if (index >= 0 && index < limitedTDSData.length) {
                            final time = limitedTDSData[index]['time'] as DateTime;
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
                      spots: limitedTDSData
                          .asMap()
                          .entries
                          .where((entry) => entry.value['tds_value'] != null && entry.value['tds_value'] is num)
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                (entry.value['tds_value'] as num).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
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



Widget _buildTurbidityChart() {
    // Limit the data to the last 10 points
    final limitedTurbidityData = globals.globalData.length > 10
        ? globals.globalData.sublist(globals.globalData.length - 10)
        : globals.globalData;

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
              'Time vs Turbidity',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                //color: Color.fromARGB(255, 91, 31, 229),
              ),
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
                          if (index >= 0 && index < limitedTurbidityData.length) {
                            final time = limitedTurbidityData[index]['time'] as DateTime;
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
                      spots: limitedTurbidityData
                          .asMap()
                          .entries
                          .where((entry) => entry.value['turbidity'] != null && entry.value['turbidity'] is num)
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                (entry.value['turbidity'] as num).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.purple,
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