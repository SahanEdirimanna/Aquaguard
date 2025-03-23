import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:aquaguard/globals.dart'; // Import the global variable
import 'package:intl/intl.dart'; // For formatting time

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late WebSocketChannel _fishDetailsChannel;
  late WebSocketChannel _tankParametersChannel;

  final TextEditingController _fishTypeCountController = TextEditingController();

  // Tank Parameters Controllers
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _tankSizeController = TextEditingController();
  final TextEditingController _lightIntensityController = TextEditingController();

  int _fishTypeCount = 0;
  List<Map<String, dynamic>> _fishInputs = [];
  final List<String> _fishNames = ['Goldfish', 'Koi', 'Guppy', 'Tetra', 'Angelfish'];

  String _selectedTime = globalTime; // Store the selected time as a string

  @override
  void initState() {
    super.initState();
    _intervalController.text = globalInterval; // Pre-fill with global interval

    _fishDetailsChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/settings/fsh_details'),
    );
    _tankParametersChannel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/settings/tank_parameters'),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final formattedTime = DateFormat('hh:mm a').format(selectedDateTime);

      setState(() {
        _selectedTime = formattedTime; // Update the selected time
        globalTime = formattedTime;
        globalTimefull = selectedDateTime; // Update the global time as a string
      });
    }
  }

  void _generateFishInputs() {
    setState(() {
      _fishTypeCount = int.tryParse(_fishTypeCountController.text) ?? 0;
      _fishInputs = List.generate(_fishTypeCount, (_) {
        return {
          'name': null, // Dropdown selection
          'count': TextEditingController(),
          'age': TextEditingController(),
        };
      });
    });
  }

  void _sendFishDetails() {
    final fishData = _fishInputs.map((fishInput) {
      return {
        'name': fishInput['name'] ?? '',
        'count': fishInput['count']?.text ?? '',
        'age': fishInput['age']?.text ?? '',
      };
    }).toList();

    final deviceId = globalDeviceId; // Use the global device ID

    final message = {
      'deviceId': deviceId,
      'fishData': fishData,
    };

    if (deviceId.isNotEmpty && fishData.isNotEmpty) {
      _fishDetailsChannel.sink.add(message.toString());
    }
  }

  void _sendTankParameters() {
    final deviceId = globalDeviceId; // Use the global device ID
    final interval = _intervalController.text.trim();
    final tankSize = _tankSizeController.text.trim();
    final lightIntensity = _lightIntensityController.text.trim();

    // Update global variables
    globalInterval = interval;

    final message = {
      'device_id': deviceId,
      'time': _selectedTime,
      'interval': interval,
      'tank_size': tankSize,
      'light_intensity': lightIntensity,
    };

    if (deviceId.isNotEmpty && _selectedTime.isNotEmpty && interval.isNotEmpty ) {
      _tankParametersChannel.sink.add(message.toString());
    }
  }

  @override
  void dispose() {
    _fishDetailsChannel.sink.close();
    _tankParametersChannel.sink.close();

    _fishTypeCountController.dispose();
    _intervalController.dispose();
    _tankSizeController.dispose();
    _lightIntensityController.dispose();

    for (var fishInput in _fishInputs) {
      fishInput['count']?.dispose();
      fishInput['age']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fish Details Section
              TextField(
                controller: _fishTypeCountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter number of fish types',
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                  ),
                  onPressed: _generateFishInputs,
                  child: Text('Generate Fish Inputs'),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_fishInputs.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _fishInputs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
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
                                'Fish Type ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              DropdownButtonFormField<String>(
                                value: _fishInputs[index]['name'],
                                items: _fishNames.map((fishName) {
                                  return DropdownMenuItem(
                                    value: fishName,
                                    child: Text(fishName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _fishInputs[index]['name'] = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Select Fish Type',
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextField(
                                controller: _fishInputs[index]['count'],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Fish Count',
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextField(
                                controller: _fishInputs[index]['age'],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Average Age of Fish',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                  ),
                  onPressed: _sendFishDetails,
                  child: Text('Send Fish Details'),
                ),
              ),
              const SizedBox(height: 32.0),

              // Tank Parameters Section
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: _selectedTime),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Interval',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _tankSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Tank Size',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _lightIntensityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Light Intensity',
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                  ),
                  onPressed: _sendTankParameters,
                  child: Text('Send Tank Parameters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
