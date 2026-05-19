import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlCtrl = TextEditingController();
  int _interval = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlCtrl.text = prefs.getString('server_url') ?? '';
      _interval = prefs.getInt('interval') ?? 5;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _urlCtrl.text.trim());
    await prefs.setInt('interval', _interval);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saqlandi ✓')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Server URL', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              hintText: 'http://192.168.1.100:8000',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cloud_upload),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          const Text('O\'qish intervali', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _interval.toDouble(),
                  min: 1, max: 60,
                  divisions: 59,
                  label: '$_interval sek',
                  onChanged: (v) => setState(() => _interval = v.round()),
                ),
              ),
              Text('$_interval sek', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }
}
