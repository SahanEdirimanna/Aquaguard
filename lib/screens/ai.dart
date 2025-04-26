// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:aquaguard/globals.dart'; // Import global variables

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => AIPageState();
}

class AIPageState extends State<AIPage> {
  DateTime? _selectedDate; // Variable to store the selected date
  String? _responseBody; // Variable to store the server response

  @override
  void initState() {
    super.initState();
    _selectedDate = globalCleanedday; // Set globalCleanedday as the default date
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Use the selected date or current date
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        globalCleanedday = picked; // Update the globalCleanedday variable
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Date selected: ${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendDateToServer() async {
    if (_selectedDate == null) return;

    const String url = "https://my-iotinference-app.azurewebsites.net/predict";
    final formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        Uri.parse(url),
      body:{'data': formattedDate}, // Send the selected date as a string in the "data" field
    
      );

      if (response.statusCode == 200) {
        //final responseData = jsonDecode(response.body);
        setState(() {
          _responseBody = response.body; // Update the response body to display on the page
        });
        //print('Response from server: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Date sent successfully: $formattedDate'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        //print('Failed to send date. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send date. Try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      //print('Error sending date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending date. Check your connection.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI assistance'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Open the date picker
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 202, 216, 240),
              ),
              child: Text('Select Last Cleaned Date'),
            ),
            if (_selectedDate != null) ...[
              SizedBox(height: 20),
              Text(
                'Selected Date: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendDateToServer, // Send the selected date to the server
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 202, 216, 240),
                ),
                child: Text('Send Date'),
              ),
            ],
            if (_responseBody != null) ...[
              SizedBox(height: 20),
              Text(
                'Next Cleaning day:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                _responseBody!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}