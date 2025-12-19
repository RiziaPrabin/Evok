final _DbRef = FirebaseDatabase.instance.ref("sensorData");

class VestData {
  final double bpm;
  final double spo2;
  final double temp;
  final double lpgPpm;
  final double lat;
  final double lon;
  final String lastUpdate;

  VestData({
    required this.bpm,
    required this.spo2,
    required this.temp,
    required this.lpgPpm,
    required this.lat,
    required this.lon,
    required this.lastUpdate,
  });

  // This function takes the Map from Firebase and turns it into a VestData object
  factory VestData.fromMap(Map<dynamic, dynamic> map) {
    return VestData(
      bpm: (map['health']['bpm'] ?? 0).toDouble(),
      spo2: (map['health']['spo2'] ?? 0).toDouble(),
      temp: (map['environment']['temp'] ?? 0).toDouble(),
      lpgPpm: (map['gases']['lpg_ppm'] ?? 0).toDouble(),
      lat: (map['gps']['lat'] ?? 0).toDouble(),
      lon: (map['gps']['lon'] ?? 0).toDouble(),
      lastUpdate: map['last_update'] ?? "No data",
    );
  }
}