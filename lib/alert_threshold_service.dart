import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'worker_model.dart';

class AlertThresholdService {
  // ✅ CORRECTED: Send to Audio_Command instead of Commands/Worker
  final DatabaseReference _audioCommandRef = FirebaseDatabase.instance.ref(
    "EVOK_System/Audio_Command",
  );

  // ✅ Store ACTIVE alerts per worker (vestId → Set of alert types)
  final Map<String, Set<String>> _activeAlerts = {};

  // ✅ Store RESOLVED alerts per worker (vestId → Set of alert types)
  final Map<String, Set<String>> _resolvedAlerts = {};

  // ✅ Thresholds
  static const int LOW_HEART_RATE = 50;
  static const int HIGH_HEART_RATE = 120;
  static const double LOW_TEMPERATURE = 25.0; // below 25°C = too cold
  static const double HIGH_TEMPERATURE = 42.0; // above 42°C = too hot
  static const int LOW_SPO2 = 90;
  static const int HIGH_GAS = 50;
  static const int LOW_OXYGEN = 19;
  static const double FALL_ACCEL_THRESHOLD = 2.0;

  Set<String> getActiveAlerts(String vestId) {
    return _activeAlerts[vestId] ?? {};
  }

  Set<String> getResolvedAlerts(String vestId) {
    return _resolvedAlerts[vestId] ?? {};
  }

  void clearAllAlerts(String vestId) {
    // Move all active alerts to resolved
    final active = _activeAlerts[vestId] ?? {};
    _resolvedAlerts[vestId] = {...(_resolvedAlerts[vestId] ?? {}), ...active};
    _activeAlerts[vestId] = {};
  }

  // ✅ Resolve a specific alert type
  void resolveSpecificAlert(String vestId, String alertType) {
    debugPrint("🔧 AlertThresholdService: Resolving $alertType for $vestId");

    // Remove from active alerts
    _activeAlerts[vestId]?.remove(alertType);

    // Add to resolved alerts
    if (_resolvedAlerts[vestId] == null) {
      _resolvedAlerts[vestId] = {};
    }
    _resolvedAlerts[vestId]!.add(alertType);

    debugPrint("🔧 Active alerts for $vestId: ${_activeAlerts[vestId]}");
    debugPrint("🔧 Resolved alerts for $vestId: ${_resolvedAlerts[vestId]}");
  }

  void checkWorkerThresholds(Worker worker) {
    final vestId = worker.vestId;
    final previousAlerts = Set<String>.from(_activeAlerts[vestId] ?? {});
    final currentAlerts = <String>{};

    // ✅ Check heart rate
    if (worker.heartRate > 0) {
      if (worker.heartRate < LOW_HEART_RATE) {
        currentAlerts.add('LOW_HEART_RATE');
      } else if (worker.heartRate > HIGH_HEART_RATE) {
        currentAlerts.add('HIGH_HEART_RATE');
      }
    }

    // ✅ Check temperature (both LOW and HIGH)
    if (worker.temperature > 0) {
      if (worker.temperature < LOW_TEMPERATURE) {
        currentAlerts.add('LOW_TEMPERATURE');
      } else if (worker.temperature > HIGH_TEMPERATURE) {
        currentAlerts.add('HIGH_TEMPERATURE');
      }
    }

    // ✅ Check SpO2
    if (worker.spo2 > 0 && worker.spo2 < LOW_SPO2) {
      currentAlerts.add('LOW_SPO2');
    }

    // ✅ Check gas levels
    if (worker.gasRate > HIGH_GAS) {
      currentAlerts.add('HIGH_GAS');
    }

    // ✅ Check oxygen levels
    if (worker.oxygenRate > 0 && worker.oxygenRate < LOW_OXYGEN) {
      currentAlerts.add('LOW_OXYGEN');
    }

    // ✅ Check for fall detection
    if (worker.accelX.abs() > FALL_ACCEL_THRESHOLD ||
        worker.accelY.abs() > FALL_ACCEL_THRESHOLD ||
        worker.accelZ.abs() > FALL_ACCEL_THRESHOLD) {
      currentAlerts.add('FALL_DETECTED');
    }

    // ✅ Update active alerts
    _activeAlerts[vestId] = currentAlerts;

    // ✅ Find NEW alerts (not in previous, but in current)
    final newAlerts = currentAlerts.difference(previousAlerts);

    // ✅ Find RESOLVED alerts (in previous, but NOT in current)
    final naturallyResolvedAlerts = previousAlerts.difference(currentAlerts);

    // ✅ Send audio commands for NEW alerts
    for (final alertType in newAlerts) {
      debugPrint("🚨 NEW ALERT: $alertType for ${worker.name}");
      sendAlertCommand(worker, alertType);
    }

    // ✅ Move naturally resolved alerts to resolved set
    if (naturallyResolvedAlerts.isNotEmpty) {
      debugPrint(
          "✅ Naturally resolved alerts for ${worker.name}: $naturallyResolvedAlerts");
      for (final alertType in naturallyResolvedAlerts) {
        if (_resolvedAlerts[vestId] == null) {
          _resolvedAlerts[vestId] = {};
        }
        _resolvedAlerts[vestId]!.add(alertType);
      }
    }
  }

  // ✅ CORRECTED: Send to Audio_Command with proper format
  Future<void> sendAlertCommand(Worker worker, String alertType) async {
    final commandCode = _getCommandCode(alertType);
    final timestamp = DateTime.now().toIso8601String();

    debugPrint("🔊 Sending Audio Command: $commandCode");
    debugPrint("🔊 Timestamp: $timestamp");

    try {
      await _audioCommandRef.update({
        'command': commandCode,
        'timestamp': timestamp,
      });
      debugPrint(
          "✅ Audio command sent successfully to EVOK_System/Audio_Command");
    } catch (e) {
      debugPrint("❌ Error sending audio command: $e");
    }
  }

  String _getCommandCode(String alertType) {
    switch (alertType) {
      case 'LOW_HEART_RATE':
        return "LOW_HEART_RATE_DETECTED";
      case 'HIGH_HEART_RATE':
        return "HIGH_HEART_RATE_DETECTED";
      case 'LOW_TEMPERATURE': // ✅ NEW
        return "LOW_TEMPERATURE_DETECTED";
      case 'HIGH_TEMPERATURE':
        return "HIGH_TEMPERATURE_DETECTED";
      case 'LOW_SPO2':
        return "LOW_SPO2_DETECTED";
      case 'HIGH_GAS':
        return "HIGH_GAS_DETECTED";
      case 'LOW_OXYGEN':
        return "LOW_OXYGEN_DETECTED";
      case 'FALL_DETECTED':
        return "FALL_DETECTED";
      case 'PANIC_BUTTON':
        return "PANIC_BUTTON_PRESSED";
      default:
        return "ALERT_DETECTED";
    }
  }

  static String getAlertDisplayName(String alertType) {
    switch (alertType) {
      case 'LOW_HEART_RATE':
        return 'Low Heart Rate';
      case 'HIGH_HEART_RATE':
        return 'High Heart Rate';
      case 'LOW_TEMPERATURE': // ✅ NEW
        return 'Low Temperature';
      case 'HIGH_TEMPERATURE':
        return 'High Temperature';
      case 'LOW_SPO2':
        return 'Low SpO₂';
      case 'HIGH_GAS':
        return 'High Gas Level';
      case 'LOW_OXYGEN':
        return 'Low Oxygen';
      case 'FALL_DETECTED':
        return 'Fall Detected';
      case 'PANIC_BUTTON':
        return 'Panic Alert';
      default:
        return 'Alert';
    }
  }

  static Color getAlertColor(String alertType) {
    switch (alertType) {
      case 'FALL_DETECTED':
      case 'PANIC_BUTTON':
      case 'LOW_SPO2':
      case 'LOW_OXYGEN':
        return Colors.red;
      case 'HIGH_HEART_RATE':
      case 'HIGH_TEMPERATURE':
      case 'HIGH_GAS':
        return Colors.orange;
      case 'LOW_HEART_RATE':
        return Colors.yellow;
      case 'LOW_TEMPERATURE': // ✅ NEW
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static IconData getAlertIcon(String alertType) {
    switch (alertType) {
      case 'LOW_HEART_RATE':
      case 'HIGH_HEART_RATE':
        return Icons.favorite;
      case 'LOW_TEMPERATURE': // ✅ NEW
        return Icons.ac_unit;
      case 'HIGH_TEMPERATURE':
        return Icons.thermostat;
      case 'LOW_SPO2':
        return Icons.air;
      case 'HIGH_GAS':
        return Icons.warning;
      case 'LOW_OXYGEN':
        return Icons.bubble_chart;
      case 'FALL_DETECTED':
        return Icons.person_off;
      case 'PANIC_BUTTON':
        return Icons.pan_tool;
      default:
        return Icons.error;
    }
  }
}
