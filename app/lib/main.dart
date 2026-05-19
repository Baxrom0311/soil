import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/monitor_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/log_screen.dart';
import 'services/sensor_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Controller ni ishga tushirish
  SensorController.instance;
  runApp(const SoilApp());
}

class SoilApp extends StatelessWidget {
  const SoilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoilSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> with WidgetsBindingObserver {
  int _idx = 0;
  final _screens = const [MonitorScreen(), HistoryScreen(), SettingsScreen(), LogScreen()];

  static const _channel = MethodChannel('com.soil.soil_monitor/service');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startForegroundService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App background/foreground - hech narsa qilmaymiz, controller ishlayveradi
  }

  Future<void> _startForegroundService() async {
    try {
      await _channel.invokeMethod('startService');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors), label: 'Monitor'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Tarix'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Sozlama'),
          NavigationDestination(icon: Icon(Icons.bug_report), label: 'Log'),
        ],
      ),
    );
  }
}
