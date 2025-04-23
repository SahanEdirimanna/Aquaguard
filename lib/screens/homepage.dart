import 'package:flutter/material.dart';
import 'package:aquaguard/globals.dart'; // Import the global variable
import 'package:aquaguard/websocket_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deviceIdController.text = globalDeviceId; // Load the global deviceId
  }

  void _saveDeviceId() {
    setState(() {
      globalDeviceId = _deviceIdController.text.trim(); // Save the deviceId globally
    });
    // Initialize WebSocketManager with the device ID
    WebSocketManager().initialize(globalDeviceId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device ID saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/test1.gif', // Replace with your GIF path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to AquaGuard!',
                    style: TextStyle(
                      color: Color.fromARGB(255, 6, 9, 161),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                  ),
                    onPressed: () {
                      // Add login logic here
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _deviceIdController,
                      decoration: InputDecoration(
                        labelText: 'Enter Device ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Set the background color
                  ),
                    onPressed: _saveDeviceId,
                    child: const Text('Save Device ID'),
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}