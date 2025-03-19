import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late WebSocketChannel _channel;
  final TextEditingController _fishTypeCountController = TextEditingController();
  int _fishTypeCount = 0;
  List<Map<String, dynamic>> _fishInputs = [];
  final List<String> _fishNames = ['Goldfish', 'Betta', 'Guppy', 'Tetra', 'Angelfish'];

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://159.89.173.231:1880/ws/settings'), // Replace with your WebSocket URL
    );
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

  void _sendMessage() {
    final fishData = _fishInputs.map((fishInput) {
      return {
        'name': fishInput['name'] ?? '',
        'count': fishInput['count']?.text ?? '',
        'age': fishInput['age']?.text ?? '',
      };
    }).toList();

    final message = fishData.map((fish) {
      return 'Fish Type: ${fish['name']}, Count: ${fish['count']}, Average Age: ${fish['age']}';
    }).join('; ');

    if (message.isNotEmpty) {
      _channel.sink.add(message);
    }
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _fishTypeCountController.dispose();
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
              TextField(
                controller: _fishTypeCountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter number of fish types',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _generateFishInputs,
                child: Text('Generate Input Fields'),
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
              if (_fishInputs.isNotEmpty)
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send Message'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}