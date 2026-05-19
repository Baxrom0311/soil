import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/soil_reading.dart';
import '../services/db_service.dart';
import '../services/excel_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SoilReading> _readings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DbService.getAll();
    setState(() { _readings = data; _loading = false; });
  }

  Future<void> _export() async {
    if (_readings.isEmpty) return;
    final path = await ExcelService.export(_readings);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saqlandi: $path')));
    // Share the file
    await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'Soil sensor data'));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarix'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.file_download), onPressed: _export, tooltip: 'Excel export'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _readings.isEmpty
              ? const Center(child: Text('Ma\'lumot yo\'q'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Sana')),
                        DataColumn(label: Text('Namlik%')),
                        DataColumn(label: Text('°C')),
                        DataColumn(label: Text('EC')),
                        DataColumn(label: Text('pH')),
                        DataColumn(label: Text('N')),
                        DataColumn(label: Text('P')),
                        DataColumn(label: Text('K')),
                        DataColumn(label: Text('Tuz')),
                      ],
                      rows: _readings.map((r) => DataRow(cells: [
                        DataCell(Text(fmt.format(r.timestamp))),
                        DataCell(Text(r.moisture.toStringAsFixed(1))),
                        DataCell(Text(r.temperature.toStringAsFixed(1))),
                        DataCell(Text(r.ec.toStringAsFixed(0))),
                        DataCell(Text(r.ph.toStringAsFixed(1))),
                        DataCell(Text(r.nitrogen.toStringAsFixed(0))),
                        DataCell(Text(r.phosphorus.toStringAsFixed(0))),
                        DataCell(Text(r.potassium.toStringAsFixed(0))),
                        DataCell(Text(r.salinity.toStringAsFixed(0))),
                      ])).toList(),
                    ),
                  ),
                ),
    );
  }
}
