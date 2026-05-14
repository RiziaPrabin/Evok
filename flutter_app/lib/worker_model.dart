import 'package:flutter/material.dart';

class Worker {
  final String name;
  final String id;
  final String vestId;
  final String shift;
  final String department;
  final String location;
  final String assigned;
  final String status;
  final Color statusColor;

  // 🔥 LIVE VALUES
  final int heartRate;
  final double temperature;
  final int spo2;
  final double latitude;
  final double longitude;
  final DateTime? lastUpdated;
  final int gasRate;
  final int oxygenRate;
  final double accelX;
  final double accelY; // Added for 3D fall detection
  final double accelZ; // Added for 3D fall detection
  final int panic;
  Worker({
    required this.name,
    required this.id,
    required this.vestId,
    required this.shift,
    required this.department,
    required this.location,
    required this.assigned,
    this.status = 'OFFLINE',
    this.statusColor = Colors.grey,
    this.heartRate = 0,
    this.temperature = 0.0,
    this.spo2 = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.lastUpdated,
    this.gasRate = 0,
    this.accelX = 0.0,
    this.accelY = 0.0,
    this.accelZ = 0.0,
    this.panic = 0,
    this.oxygenRate = 0,
  });

  Worker copyWith({
    int? heartRate,
    double? temperature,
    int? spo2,
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
    String? status,
    Color? statusColor,
    int? gasRate,
    double? accelX,
    double? accelY,
    double? accelZ,
    int? panic,
    int? oxygenRate,
  }) {
    return Worker(
      name: name,
      id: id,
      vestId: vestId,
      shift: shift,
      department: department,
      location: location,
      assigned: assigned,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      spo2: spo2 ?? this.spo2,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      gasRate: gasRate ?? this.gasRate,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      panic: panic ?? this.panic,
      oxygenRate: oxygenRate ?? this.oxygenRate,
    );
  }
}
