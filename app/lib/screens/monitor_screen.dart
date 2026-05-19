import 'package:flutter/material.dart';
import '../services/sensor_controller.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});
  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  final _ctrl = SensorController.instance;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_update);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_update);
    super.dispose();
  }

  void _update() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final r = _ctrl.reading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 SoilSense'),
        actions: [
          if (_ctrl.sending) const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Card(
              child: ListTile(
                dense: true,
                leading: Icon(
                  _ctrl.isConnected ? Icons.usb : Icons.usb_off,
                  color: _ctrl.isConnected ? Colors.green : Colors.red,
                ),
                title: Text(_ctrl.status, style: const TextStyle(fontSize: 14)),
                trailing: _ctrl.isConnected
                    ? TextButton(onPressed: _ctrl.disconnect, child: const Text('Uzish'))
                    : FilledButton(onPressed: _ctrl.connect, child: const Text('Ulash')),
              ),
            ),
          ),
          if (r != null) Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              childAspectRatio: 2.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _card('Namlik', '${r.moisture.toStringAsFixed(1)}%', Icons.water_drop, Colors.blue),
                _card('Harorat', '${r.temperature.toStringAsFixed(1)}°C', Icons.thermostat, Colors.orange),
                _card('EC', '${r.ec.toStringAsFixed(0)} µs/cm', Icons.electric_bolt, Colors.yellow),
                _card('pH', r.ph.toStringAsFixed(1), Icons.science, Colors.purple),
                _card('Azot (N)', '${r.nitrogen.toStringAsFixed(0)} mg/kg', Icons.grass, Colors.green),
                _card('Fosfor (P)', '${r.phosphorus.toStringAsFixed(0)} mg/kg', Icons.eco, Colors.teal),
                _card('Kaliy (K)', '${r.potassium.toStringAsFixed(0)} mg/kg', Icons.spa, Colors.amber),
                _card('Tuzlilik', '${r.salinity.toStringAsFixed(0)} mg/L', Icons.water, Colors.cyan),
              ],
            ),
          ) else const Expanded(
            child: Center(child: Text('Sensorni USB orqali ulang', style: TextStyle(fontSize: 16, color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[400]), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
