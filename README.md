# AquaGuard

**AquaGuard** is a mobile app developed using Flutter as part of a smart aquarium system. It helps monitor and control the aquarium environment using real-time sensor data and automated alerts.

## Features

- Shows real-time **pH** and **temperature** readings from the aquarium  
- **Live dashboard** to display sensor data clearly  
- Sends alerts when:
  - Water conditions are not within safe limits  
  - Power outages occur  
- Controls the **oxygen pump**, **lighting**, and **fish feeder**

## How It Works

- The app connects to an IoT system (e.g., ESP32) that collects sensor data and controls devices  
- Communication may use Wi-Fi and cloud services (e.g., Websockets and MQTT)

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/aquaguard.git
   cd aquaguard
   ```

2. Get the packages:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```
 
