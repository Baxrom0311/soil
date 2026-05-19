import 'package:flutter/material.dart';

class LogService {
  static final List<String> _logs = [];
  static final listeners = <VoidCallback>[];

  static List<String> get logs => _logs;

  static void log(String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    _logs.insert(0, '[$time] $msg');
    if (_logs.length > 200) _logs.removeLast();
    for (final l in listeners) { l(); }
  }
}
