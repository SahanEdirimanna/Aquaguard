import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        const Center(
          child: Text(
        'Welcome to AquaGuard!',
        style: TextStyle(
          color: Color.fromARGB(255, 6, 9, 161),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
          ),
        ),
      ],
      ),
    );
  }
}