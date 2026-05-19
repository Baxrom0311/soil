import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/soil_reading.dart';

class ExcelService {
  static Future<String> export(List<SoilReading> readings) async {
    final excel = Excel.createExcel();
    final sheet = excel['Soil Data'];

    sheet.appendRow([
      TextCellValue('Sana'),
      TextCellValue('Namlik %'),
      TextCellValue('Harorat °C'),
      TextCellValue('EC µs/cm'),
      TextCellValue('pH'),
      TextCellValue('N mg/kg'),
      TextCellValue('P mg/kg'),
      TextCellValue('K mg/kg'),
      TextCellValue('Tuzlilik mg/L'),
    ]);

    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final r in readings) {
      sheet.appendRow([
        TextCellValue(fmt.format(r.timestamp)),
        DoubleCellValue(r.moisture),
        DoubleCellValue(r.temperature),
        DoubleCellValue(r.ec),
        DoubleCellValue(r.ph),
        DoubleCellValue(r.nitrogen),
        DoubleCellValue(r.phosphorus),
        DoubleCellValue(r.potassium),
        DoubleCellValue(r.salinity),
      ]);
    }

    excel.delete('Sheet1');
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/soil_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return path;
  }
}
