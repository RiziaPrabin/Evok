import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'worker_model.dart';

class WorkerProvider extends ChangeNotifier {
  final DatabaseReference _rootRef =
      FirebaseDatabase.instance.ref("EVOK_System/Live_Data");

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
    _listenWorker(); // Marcus
    _listenLeader(); // Sarah
  }

  List<Worker> get workers => _workers;

  int get activeWorkersCount =>
      _workers.where((w) => w.status == 'ONLINE' || w.status == 'ALERT').length;

  int get alertsCount => _workers.where((w) => w.status == 'ALERT').length;

  int get offlineWorkersCount =>
      _workers.where((w) => w.status == 'OFFLINE').length;

  // ================= MARCUS (Worker node) =================
  void _listenWorker() {
    _rootRef.child("Worker").onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      final accel =
          double.tryParse(event.snapshot.child('AccelX').value.toString()) ??
              0.0;

      debugPrint("🔥 Marcus AccelX = $accel");

      _updateWorker(
        vestId: "VEST-001",
        bpm: int.tryParse(event.snapshot.child('BPM').value.toString()) ?? 0,
        temp: double.tryParse(event.snapshot.child('Temp').value.toString()) ??
            0.0,
        spo2: int.tryParse(event.snapshot.child('SpO2').value.toString()) ?? 0,
        panic:
            int.tryParse(event.snapshot.child('Panic').value.toString()) ?? 0,
        lat: double.tryParse(event.snapshot.child('Lat').value.toString()) ??
            0.0,
        lng: double.tryParse(event.snapshot.child('Lng').value.toString()) ??
            0.0,
        gas: int.tryParse(event.snapshot.child('Gas').value.toString()) ?? 0,
        accelX: accel,
        oxygenRate: 0,
      );
    });
  }

  // ================= SARAH (Leader node) =================
  void _listenLeader() {
    _rootRef.child("Leader").onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      final accel =
          double.tryParse(event.snapshot.child('AccelX').value.toString()) ??
              0.0;

      debugPrint("🔥 Sarah AccelX = $accel");

      _updateWorker(
        vestId: "VEST-002",
        bpm: 0,
        temp: double.tryParse(event.snapshot.child('Temp').value.toString()) ??
            0.0,
        spo2: 0,
        panic:
            int.tryParse(event.snapshot.child('Panic').value.toString()) ?? 0,
        lat: double.tryParse(event.snapshot.child('Lat').value.toString()) ??
            0.0,
        lng: double.tryParse(event.snapshot.child('Lng').value.toString()) ??
            0.0,
        gas: int.tryParse(event.snapshot.child('Gas').value.toString()) ?? 0,
        accelX: accel,
        oxygenRate:
            int.tryParse(event.snapshot.child('O2').value.toString()) ?? 0,
      );
    });
  }

  // ================= UPDATE =================
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
    required int oxygenRate,
  }) {
    final index = _workers.indexWhere((w) => w.vestId == vestId);
    if (index == -1) return;

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
      oxygenRate: oxygenRate,
      lastUpdated: DateTime.now(),
      status: status,
      statusColor: color,
    );

    notifyListeners();
  }

  // ================= ADD / REMOVE =================
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

  Future<void> resolveWorkerAlert(String vestId) async {
    // Decide which Firebase node to update
    String node;
    if (vestId == 'VEST-001') {
      node = 'Worker';
    } else if (vestId == 'VEST-002') {
      node = 'Leader';
    } else {
      return;
    }

    // 1️⃣ Update Firebase panic value
    await _rootRef.child(node).update({
      'Panic': 0,
    });

    // 2️⃣ OPTIONAL immediate UI safety update (not strictly required)
    final index = _workers.indexWhere((w) => w.vestId == vestId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        status: 'ONLINE',
        statusColor: const Color(0xFF00FF41),
      );
      notifyListeners();
    }
  }
}
