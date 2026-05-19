import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/soil_reading.dart';
import 'serial_service.dart';
import 'server_service.dart';
import 'db_service.dart';
import 'log_service.dart';

class SensorController extends ChangeNotifier {
  static final SensorController instance = SensorController._();
  SensorController._();

  final _serial = SerialService();
  Timer? _timer;
  SoilReading? reading;
  bool get isConnected => _serial.isConnected;
  bool sending = false;
  String status = 'Ulanmagan';

  Future<void> connect() async {
    if (isConnected) return;
    status = 'Ulanmoqda...';
    notifyListeners();
    LogService.log('USB ulanmoqda...');

    final ok = await _serial.connect();
    status = ok ? 'Ulangan ✓' : 'Ulanib bo\'lmadi';
    LogService.log(ok ? 'USB ulandi ✓' : 'USB ulanib bo\'lmadi ✗');
    notifyListeners();
    if (ok) _startTimer();
  }

  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
    await _serial.disconnect();
    status = 'Ulanmagan';
    LogService.log('Foydalanuvchi uzdi');
    notifyListeners();
  }

  Future<void> _startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getInt('interval') ?? 5;
    _timer?.cancel();
    LogService.log('Timer: har $interval sekundda');
    _timer = Timer.periodic(Duration(seconds: interval), (_) => _read());
    _read();
  }

  Future<void> _read() async {
    final data = await _serial.readSensor();
    if (data == null) {
      LogService.log('Sensor javob bermadi');
      return;
    }
    reading = data;
    LogService.log('DATA: M=${data.moisture.toStringAsFixed(1)}% T=${data.temperature.toStringAsFixed(1)}°C EC=${data.ec} pH=${data.ph} N=${data.nitrogen} P=${data.phosphorus} K=${data.potassium} S=${data.salinity}');
    notifyListeners();
    await DbService.insert(data);
    _sendToServer(data);
  }

  Future<void> _sendToServer(SoilReading data) async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('server_url') ?? '';
    if (url.isEmpty) return;
    sending = true;
    notifyListeners();
    final ok = await ServerService(url).send(data);
    sending = false;
    status = ok ? 'Ulangan ✓ | Server ✓' : 'Ulangan ✓ | Server ✗';
    LogService.log(ok ? 'Server ✓' : 'Server ✗');
    notifyListeners();
  }
}
