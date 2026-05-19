import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/log_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});
  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  void initState() {
    super.initState();
    LogService.listeners.add(_refresh);
  }

  @override
  void dispose() {
    LogService.listeners.remove(_refresh);
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Nusxa olish',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: LogService.logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nusxa olindi ✓')));
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: () { LogService.logs.clear(); setState(() {}); }),
        ],
      ),
      body: ListView.builder(
        itemCount: LogService.logs.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (_, i) => Text(LogService.logs[i], style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
      ),
    );
  }
}
