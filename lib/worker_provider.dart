import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'worker_model.dart';
import 'alert_sound_service.dart';
import 'alert_threshold_service.dart';

class WorkerProvider extends ChangeNotifier {
  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref(
    "EVOK_System/Live_Data",
  );

  final AlertSoundService _alertSound = AlertSoundService();
  final AlertThresholdService _thresholdService = AlertThresholdService();
  final Map<String, int> _previousPanicStates = {};
  // ✅ NEW: Track if supervisor initiated the emergency broadcast
  bool _supervisorInitiatedBroadcast = false;
  // ✅ Store leader's oxygen value to share with worker
  int _leaderOxygenRate = 0;

  // ✅ Convert Fahrenheit to Celsius
  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  List<Worker> _workers = [
    Worker(
      name: 'Marcus Johnson',
      id: '001',
      vestId: 'VEST-001',
      shift: 'Day Shift',
      department: 'Excavation',
      location: 'Tunnel A-2',
      assigned: '2025-01-20',
    ),
    Worker(
      name: 'Sarah Chen',
      id: '002',
      vestId: 'VEST-002',
      shift: 'Day Shift',
      department: 'Safety Inspection',
      location: 'Tunnel B-1',
      assigned: '2025-01-20',
    ),
  ];

  WorkerProvider() {
    // ✅ Start listening to Leader FIRST to get oxygen value
    _listenLeader();
    _listenWorker();
  }

  List<Worker> get workers => _workers;

  int get activeWorkersCount =>
      _workers.where((w) => w.status == 'ONLINE' || w.status == 'ALERT').length;

  int get alertsCount => _workers.where((w) => w.status == 'ALERT').length;

  int get offlineWorkersCount =>
      _workers.where((w) => w.status == 'OFFLINE').length;

  bool get hasActiveAlert => _workers.any((w) => w.status == 'ALERT');

  // ✅ Get active alerts for a specific worker
  Set<String> getWorkerAlerts(String vestId) {
    return _thresholdService.getActiveAlerts(vestId);
  }

  // ✅ Get resolved alerts for a specific worker
  Set<String> getResolvedAlerts(String vestId) {
    return _thresholdService.getResolvedAlerts(vestId);
  }

  void _listenWorker() {
    _rootRef.child("Worker").onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      final accel =
          double.tryParse(event.snapshot.child('ax').value.toString()) ?? 0.0;
      final accelY =
          double.tryParse(event.snapshot.child('ay').value.toString()) ?? 0.0;
      final accelZ =
          double.tryParse(event.snapshot.child('az').value.toString()) ?? 0.0;

      final panic =
          int.tryParse(event.snapshot.child('panic').value.toString()) ?? 0;

      debugPrint("🔥 Marcus AccelX = $accel, Panic = $panic");
      debugPrint("🔥 Marcus using Leader's O2 = $_leaderOxygenRate");

      _updateWorker(
        vestId: "VEST-001",
        bpm: int.tryParse(event.snapshot.child('bpm').value.toString()) ?? 0,
        temp: _fahrenheitToCelsius(
            double.tryParse(event.snapshot.child('temp').value.toString()) ??
                0.0),
        spo2: int.tryParse(event.snapshot.child('spo2').value.toString()) ?? 0,
        panic: panic,
        lat: double.tryParse(event.snapshot.child('lat').value.toString()) ??
            0.0,
        lng: double.tryParse(event.snapshot.child('lng').value.toString()) ??
            0.0,
        gas: int.tryParse(event.snapshot.child('Pres').value.toString()) ?? 0,
        accelX: accel,
        accelY: accelY,
        accelZ: accelZ,
        oxygenRate: _leaderOxygenRate, // ✅ Use leader's oxygen value
      );
    });
  }

  void _listenLeader() {
    _rootRef.child("Leader").onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      final accel =
          double.tryParse(event.snapshot.child('ax').value.toString()) ?? 0.0;
      final accelY =
          double.tryParse(event.snapshot.child('ay').value.toString()) ?? 0.0;
      final accelZ =
          double.tryParse(event.snapshot.child('az').value.toString()) ?? 0.0;

      final panic =
          int.tryParse(event.snapshot.child('panic').value.toString()) ?? 0;

      final oxygenRate =
          int.tryParse(event.snapshot.child('oxy').value.toString()) ?? 0;

      // ✅ Update the stored oxygen value
      _leaderOxygenRate = oxygenRate;

      debugPrint("🔥 Sarah AccelX = $accel, Panic = $panic");
      debugPrint("🔥 Sarah O2 from Firebase = $oxygenRate");
      debugPrint("🔥 Updated _leaderOxygenRate = $_leaderOxygenRate");

      // ✅ Update Leader (Sarah)
      _updateWorker(
        vestId: "VEST-002",
        bpm: int.tryParse(event.snapshot.child('bpm').value.toString()) ?? 0,
        temp: _fahrenheitToCelsius(
            double.tryParse(event.snapshot.child('temp').value.toString()) ??
                0.0),
        spo2: int.tryParse(event.snapshot.child('spo2').value.toString()) ?? 0,
        panic: panic,
        lat: double.tryParse(event.snapshot.child('lat').value.toString()) ??
            0.0,
        lng: double.tryParse(event.snapshot.child('lng').value.toString()) ??
            0.0,
        gas: int.tryParse(event.snapshot.child('Pres').value.toString()) ?? 0,
        accelX: accel,
        accelY: accelY,
        accelZ: accelZ,
        oxygenRate: oxygenRate,
      );

      // ✅ ALSO update Marcus (Worker) with the same oxygen value
      final workerIndex = _workers.indexWhere((w) => w.vestId == "VEST-001");
      if (workerIndex != -1) {
        _workers[workerIndex] = _workers[workerIndex].copyWith(
          oxygenRate: _leaderOxygenRate,
        );
        debugPrint("🔥 FORCE Updated Marcus oxygen to: $_leaderOxygenRate");

        // ✅ Check thresholds for Marcus after oxygen update
        _thresholdService.checkWorkerThresholds(_workers[workerIndex]);

        // ✅ CRITICAL: Notify listeners after threshold check
        notifyListeners();
      }
    });
  }

  void _updateWorker({
    required String vestId,
    required int bpm,
    required double temp,
    required int spo2,
    required int panic,
    required double lat,
    required double lng,
    required int gas,
    required double accelX,
    required double accelY,
    required double accelZ,
    required int oxygenRate,
  }) {
    final index = _workers.indexWhere((w) => w.vestId == vestId);
    if (index == -1) return;

    final previousPanic = _previousPanicStates[vestId] ?? 0;
    final isNewAlert = previousPanic == 0 && panic == 1;
    final isAlertResolved = previousPanic == 1 && panic == 0;

    _previousPanicStates[vestId] = panic;

    final status = panic == 1 ? 'ALERT' : 'ONLINE';
    final color = panic == 1 ? Colors.red : const Color(0xFF00FF41);

    _workers[index] = _workers[index].copyWith(
      heartRate: bpm,
      temperature: temp,
      spo2: spo2,
      latitude: lat,
      longitude: lng,
      gasRate: gas,
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
      oxygenRate: oxygenRate,
      panic: panic,
      lastUpdated: DateTime.now(),
      status: status,
      statusColor: color,
    );

    // ✅ CHECK ALL THRESHOLDS AND SEND AUDIO COMMANDS
    _thresholdService.checkWorkerThresholds(_workers[index]);

    // ✅ CRITICAL: Always notify listeners after updating worker data
    // This ensures the UI updates immediately when Firebase sends new data
    notifyListeners();

    // ✅ PLAY/STOP ALERT SOUND - BUT ONLY IF NOT SUPERVISOR-INITIATED
    if (isNewAlert && !_supervisorInitiatedBroadcast) {
      // Worker pressed panic button → Play sound
      debugPrint("🚨 WORKER PANIC ALERT for $vestId - STARTING SOUND");
      _alertSound.playPanicAlert();
    } else if (isNewAlert && _supervisorInitiatedBroadcast) {
      // Supervisor triggered broadcast → Don't play sound
      debugPrint("🔇 SUPERVISOR BROADCAST for $vestId - NO SOUND");
    } else if (isAlertResolved) {
      debugPrint("✅ Panic resolved for $vestId - STOPPING SOUND");
      // ✅ Only reset supervisor flag if ALL workers are no longer in panic
      if (!_workers.any((w) => w.panic == 1)) {
        _supervisorInitiatedBroadcast = false;
        debugPrint("🔄 Reset supervisor broadcast flag");
      }
      // Only stop if no other workers are in alert
      if (!hasActiveAlert) {
        _alertSound.stopAlert();
      }
    }
  }

  void addWorker(Worker worker) {
    _workers.add(worker);
    notifyListeners();
  }

  void removeWorker(String id) {
    _workers.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  String getNextWorkerId() {
    return (_workers.length + 1).toString().padLeft(3, '0');
  }

  // ✅ Manual alert command trigger for supervisors
  Future<void> sendManualAlertCommand(String vestId, String alertType) async {
    final worker = _workers.firstWhere(
      (w) => w.vestId == vestId,
      orElse: () => throw Exception('Worker not found'),
    );

    await _thresholdService.sendAlertCommand(worker, alertType);
  }

  // ✅ NEW: Resolve only a SPECIFIC alert type for a worker
  Future<void> resolveSpecificAlert(String vestId, String alertType) async {
    debugPrint("🔧 Resolving specific alert: $alertType for $vestId");

    // ✅ Mark this specific alert as resolved in the threshold service
    _thresholdService.resolveSpecificAlert(vestId, alertType);

    // ✅ If it's a PANIC_BUTTON alert, also reset Firebase panic state
    if (alertType == 'PANIC_BUTTON') {
      String node;
      if (vestId == 'VEST-001') {
        node = 'Worker';
      } else if (vestId == 'VEST-002') {
        node = 'Leader';
      } else {
        return;
      }

      await _rootRef.child(node).update({'panic': 0});

      final index = _workers.indexWhere((w) => w.vestId == vestId);
      if (index != -1) {
        _workers[index] = _workers[index].copyWith(
          panic: 0,
        );
      }
    }

    // ✅ Check if worker still has any active alerts
    final activeAlerts = _thresholdService.getActiveAlerts(vestId);
    final index = _workers.indexWhere((w) => w.vestId == vestId);

    if (index != -1) {
      // If no more active alerts, update worker status to ONLINE
      if (activeAlerts.isEmpty && _workers[index].panic == 0) {
        _workers[index] = _workers[index].copyWith(
          status: 'ONLINE',
          statusColor: const Color(0xFF00FF41),
        );
      }
    }

    // ✅ Stop alert sound if no more active alerts across all workers
    if (!hasActiveAlert &&
        !_workers.any(
            (w) => _thresholdService.getActiveAlerts(w.vestId).isNotEmpty)) {
      _alertSound.stopAlert();
    }

    notifyListeners();
  }

  // ✅ DEPRECATED: Old method that cleared all alerts (kept for backward compatibility)
  Future<void> resolveWorkerAlert(String vestId) async {
    String node;
    if (vestId == 'VEST-001') {
      node = 'Worker';
    } else if (vestId == 'VEST-002') {
      node = 'Leader';
    } else {
      return;
    }

    await _rootRef.child(node).update({'panic': 0});

    final index = _workers.indexWhere((w) => w.vestId == vestId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        panic: 0,
        status: 'ONLINE',
        statusColor: const Color(0xFF00FF41),
      );

      // ✅ Clear all threshold alerts for this worker
      _thresholdService.clearAllAlerts(vestId);

      if (!hasActiveAlert) {
        _alertSound.stopAlert();
      }

      notifyListeners();
    }
  }

// ✅ Emergency Broadcast - Set panic to 1 for ALL workers
// ✅ Check if emergency broadcast is currently active
  bool get isEmergencyBroadcastActive {
    // Only return true if supervisor initiated it, not if workers pressed panic
    return _supervisorInitiatedBroadcast;
  }

  Future<void> toggleEmergencyBroadcast() async {
    if (_supervisorInitiatedBroadcast) {
      // STOP emergency broadcast
      debugPrint("🛑 STOPPING EMERGENCY BROADCAST");

      try {
        // Reset the flag FIRST
        _supervisorInitiatedBroadcast = false;

        // Notify listeners immediately so button updates
        notifyListeners();

        // Set panic = 0 for Worker (Marcus)
        await _rootRef.child("Worker").update({'panic': 0});

        // Set panic = 0 for Leader (Sarah)
        await _rootRef.child("Leader").update({'panic': 0});

        // Clear all alerts for both workers
        _thresholdService.clearAllAlerts('VEST-001');
        _thresholdService.clearAllAlerts('VEST-002');

        // Stop alert sound
        _alertSound.stopAlert();

        debugPrint("✅ Emergency broadcast stopped");
      } catch (e) {
        debugPrint("❌ Error stopping emergency broadcast: $e");
        _supervisorInitiatedBroadcast = true; // Revert on error
        notifyListeners();
      }
    } else {
      // START emergency broadcast
      debugPrint("🚨 STARTING EMERGENCY BROADCAST");

      try {
        // ✅ SET FLAG: This is supervisor-initiated
        _supervisorInitiatedBroadcast = true;

        // Notify listeners immediately so button updates
        notifyListeners();

        // Set panic = 1 for Worker (Marcus)
        await _rootRef.child("Worker").update({'panic': 1});

        // Set panic = 1 for Leader (Sarah)
        await _rootRef.child("Leader").update({'panic': 1});

        debugPrint("✅ Emergency broadcast activated (silent mode)");
      } catch (e) {
        debugPrint("❌ Error activating emergency broadcast: $e");
        _supervisorInitiatedBroadcast = false; // Reset on error
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _alertSound.dispose();
    super.dispose();
  }
}
