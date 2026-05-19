class SoilReading {
  final int? id;
  final DateTime timestamp;
  final double moisture;
  final double temperature;
  final double ec;
  final double ph;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double salinity;

  SoilReading({
    this.id,
    required this.timestamp,
    required this.moisture,
    required this.temperature,
    required this.ec,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
  });

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp.toIso8601String(),
    'moisture': moisture,
    'temperature': temperature,
    'ec': ec,
    'ph': ph,
    'nitrogen': nitrogen,
    'phosphorus': phosphorus,
    'potassium': potassium,
    'salinity': salinity,
  };

  factory SoilReading.fromMap(Map<String, dynamic> m) => SoilReading(
    id: m['id'] as int?,
    timestamp: DateTime.parse(m['timestamp'] as String),
    moisture: (m['moisture'] as num).toDouble(),
    temperature: (m['temperature'] as num).toDouble(),
    ec: (m['ec'] as num).toDouble(),
    ph: (m['ph'] as num).toDouble(),
    nitrogen: (m['nitrogen'] as num).toDouble(),
    phosphorus: (m['phosphorus'] as num).toDouble(),
    potassium: (m['potassium'] as num).toDouble(),
    salinity: (m['salinity'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => toMap();
}
