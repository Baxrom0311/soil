# SoilSense - IoT Soil Monitoring Application

## Overview
Real-time soil sensor monitoring app that reads data via USB serial (Modbus RTU) and displays moisture, temperature, EC, pH, and NPK levels. Dual architecture: Python backend + Flutter cross-platform frontend.

## Project Structure
```
soil/
├── main.py              # FastAPI backend (serial reader + REST API + SQLite)
├── static/index.html    # Web dashboard (Chart.js, auto-refresh, Uzbek UI)
├── app/                 # Flutter application
│   ├── lib/
│   │   ├── main.dart            # Entry point, Material 3 dark theme
│   │   ├── models/              # Data models (soil_reading.dart)
│   │   ├── screens/             # UI screens (monitor, history, settings, log)
│   │   └── services/            # Business logic (serial, server, db, excel, log)
│   ├── pubspec.yaml             # Flutter dependencies
│   └── [android|ios|linux|macos|web|windows]/  # Platform configs
```

## Tech Stack
- **Backend**: Python, FastAPI, PySerial, SQLite3
- **Frontend**: Flutter/Dart (SDK ^3.10.8), sqflite, usb_serial
- **Web**: HTML5, JavaScript, Chart.js
- **Protocol**: Modbus RTU, 9600 baud, CRC16

## Key Commands
```bash
# Backend
python main.py                    # Start FastAPI server (localhost:8000)

# Flutter
cd app && flutter pub get         # Install dependencies
cd app && flutter run             # Run app
cd app && flutter analyze         # Lint check
cd app && flutter build apk       # Build Android APK
```

## API Endpoints
- `GET /` - Web dashboard
- `GET /api/latest` - Latest sensor reading
- `POST /api/readings` - Insert reading
- `GET /api/history?limit=N` - Historical data

## Database
SQLite table `readings`: id, timestamp, moisture, temperature, ec, ph, nitrogen, phosphorus, potassium

## Notes
- Serial port default: `/dev/cu.usbserial-110` (configurable)
- Sensor polling interval: 5 seconds
- UI language: Uzbek
- No tests implemented yet
