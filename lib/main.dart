import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this import for JSON decoding

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'AquaGuard Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.1.120:1880/data/second'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON data
      final data = jsonDecode(response.body);
      setState(() {
        _data = data;
      });
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //const Text('Your personal aquarium assistant'),
              if (_data.isNotEmpty) ...[
                Text('Weather: ${_data['weather']}'),
                Text('Detail: ${_data['detail']}'),
                Text('Icon: ${_data['icon']}'),
                Text('Temperature (K): ${_data['tempk']}'),
                Text('Temperature (C): ${_data['tempc']}'),
                Text('Max Temperature (C): ${_data['temp_maxc']}'),
                Text('Min Temperature (C): ${_data['temp_minc']}'),
                Text('Humidity: ${_data['humidity']}'),
                Text('Pressure: ${_data['pressure']}'),
                Text('Max Temperature (K): ${_data['maxtemp']}'),
                Text('Min Temperature (K): ${_data['mintemp']}'),
                Text('Wind Speed: ${_data['windspeed']}'),
                Text('Wind Direction: ${_data['winddirection']}'),
                Text('Location: ${_data['location']}'),
                Text('Sunrise: ${DateTime.fromMillisecondsSinceEpoch(_data['sunrise'] * 1000)}'),
                Text('Sunset: ${DateTime.fromMillisecondsSinceEpoch(_data['sunset'] * 1000)}'),
                Text('Clouds: ${_data['clouds']}'),
                Text('Description: ${_data['description']}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
