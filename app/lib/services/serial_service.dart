import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import '../models/soil_reading.dart';
import 'log_service.dart';

class SerialService {
  UsbPort? _port;
  bool get isConnected => _port != null;

  int _crc16(Uint8List data) {
    int crc = 0xFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc;
  }

  Future<bool> connect() async {
    final devices = await UsbSerial.listDevices();
    LogService.log('USB qurilmalar: ${devices.length} ta topildi');
    for (final d in devices) {
      LogService.log('  - ${d.productName} (VID:${d.vid} PID:${d.pid})');
    }
    if (devices.isEmpty) return false;

    _port = await devices.first.create();
    if (_port == null) {
      LogService.log('Port yaratib bo\'lmadi');
      return false;
    }

    final ok = await _port!.open();
    if (!ok) {
      LogService.log('Port ochib bo\'lmadi');
      _port = null;
      return false;
    }

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    LogService.log('Port ochildi: 9600 baud');
    return true;
  }

  Future<SoilReading?> readSensor() async {
    if (_port == null) {
      LogService.log('Port null - ulanmagan');
      return null;
    }

    final request = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x08]);
    final crc = _crc16(request);
    final fullReq = Uint8List.fromList([...request, crc & 0xFF, (crc >> 8) & 0xFF]);

    LogService.log('TX: ${fullReq.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');
    await _port!.write(fullReq);

    // inputStream tekshirish
    final stream = _port!.inputStream;
    if (stream == null) {
      LogService.log('inputStream null - port stream yo\'q');
      return null;
    }

    final completer = Completer<Uint8List>();
    final buffer = <int>[];
    StreamSubscription? sub;

    sub = stream.listen((data) {
      buffer.addAll(data);
      LogService.log('RX chunk: ${data.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")} (total: ${buffer.length} bytes)');
      if (buffer.length >= 21 && !completer.isCompleted) {
        sub?.cancel();
        completer.complete(Uint8List.fromList(buffer));
      }
    });

    final response = await completer.future.timeout(const Duration(seconds: 3), onTimeout: () {
      sub?.cancel();
      LogService.log('Timeout - ${buffer.length} bytes olindi');
      return Uint8List.fromList(buffer);
    });

    if (response.isEmpty) {
      LogService.log('Javob kelmadi (0 bytes)');
      return null;
    }

    LogService.log('RX full: ${response.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');

    if (response.length < 21) {
      LogService.log('Javob qisqa: ${response.length} bytes (21 kerak)');
      return null;
    }

    final byteCount = response[2];
    if (byteCount != 16) {
      LogService.log('Byte count: $byteCount (16 kutilgan)');
      return null;
    }

    final regs = <int>[];
    for (int i = 3; i < 19; i += 2) {
      regs.add((response[i] << 8) | response[i + 1]);
    }

    int temp = regs[1];
    if (temp > 32767) temp -= 65536;

    return SoilReading(
      timestamp: DateTime.now(),
      moisture: regs[0] * 0.1,
      temperature: temp * 0.1,
      ec: regs[2].toDouble(),
      ph: regs[3] * 0.1,
      nitrogen: regs[4].toDouble(),
      phosphorus: regs[5].toDouble(),
      potassium: regs[6].toDouble(),
      salinity: regs[7].toDouble(),
    );
  }

  Future<void> disconnect() async {
    await _port?.close();
    _port = null;
    LogService.log('Port yopildi');
  }
}
