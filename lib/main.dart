import 'package:flutter/material.dart';
//import 'screens/weather.dart'; // Import the WebSocket page
//import 'screens/conversation.dart'; // Import the Conversation page
import 'screens/homepage.dart'; // Import the Home page
import 'screens/dashboard.dart';
import 'screens/marketplace.dart';
import 'screens/notifications.dart';
import '/screens/settings.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 10, 135, 237)),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> get _widgetOptions => <Widget>[
    HomePage(), // Use the HomePage widget
    DashboardPage(), // Use the WebSocketPage widget
    MarketplacePage(), 
    NotificationsPage(), // Use the NotificationsPage widget
    SettingsPage()// Use the ConversationPage widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'AquaGuard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Dashboard',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Marketplace',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
