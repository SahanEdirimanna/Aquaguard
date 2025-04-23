String globalDeviceId = '2';
String globalTime = '';
String globalInterval = '10';
DateTime globalTimefull = DateTime.now();

List<Map<String, dynamic>> globalData = [
    {'time': DateTime.now().subtract(Duration(minutes: 10)), 'temperature': 25.0, 'pH': 7.0, 'turbidity': 1.2, 'tds_value': 300},
    {'time': DateTime.now().subtract(Duration(minutes: 8)), 'temperature': 26.5, 'pH': 7.2, 'turbidity': 1.3, 'tds_value': 310},
    {'time': DateTime.now().subtract(Duration(minutes: 6)), 'temperature': 27.0, 'pH': 7.1, 'turbidity': 1.1, 'tds_value': 320},
    {'time': DateTime.now().subtract(Duration(minutes: 4)), 'temperature': 26.8, 'pH': 7.3, 'turbidity': 1.4, 'tds_value': 330},
    {'time': DateTime.now().subtract(Duration(minutes: 2)), 'temperature': 27.5, 'pH': 7.4, 'turbidity': 1.5, 'tds_value': 340},

];