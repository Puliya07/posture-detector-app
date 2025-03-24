# Posture Detector App

A Flutter app that monitors and improves user posture by:
- Receiving real-time sensor data via MQTT from ESP32
- Providing instant feedback on posture quality
- Offering customizable alerts and historical trend analysis

## ✨ Key Features

- **Real-time Posture Monitoring**
  - Continuous angle measurement
  - Instant posture classification (Good/Needs Improvement/Bad)
  
- **Smart Notifications**
  - Visual status updates
  - Customizable sound/vibration alerts
  - Configurable sensitivity thresholds

- **Data Integration**
  - Secure MQTT communication with ESP32
  - Local data persistence
  - Posture history tracking

## 🛠️ Setup Instructions

### Hardware Requirements
- ESP32 with IMU sensor
- MQTT broker (e.g., HiveMQ Cloud)

### App Installation
```bash
# Clone repository
git clone https://github.com/your-username/posture-detector-app.git

# Install dependencies
flutter pub get

# Run the app (choose your device)
flutter run
