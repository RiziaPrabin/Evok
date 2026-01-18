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
      status: 'OFFLINE',
      statusColor: Colors.grey,
    ),
    Worker(
      name: 'Sarah Chen',
      id: '002',
      vestId: 'VEST-002',
      shift: 'Day Shift',
      department: 'Safety Inspection',
      location: 'Tunnel B-1',
      assigned: '2025-01-20',
      status: 'OFFLINE',
      statusColor: Colors.grey,
    ),
  ];

  WorkerProvider() {
    _listenLeader();
    _listenWorker();
  }

  List<Worker> get workers => _workers;

  List<Worker> get activeWorkers =>
      _workers.where((w) => w.status != 'OFFLINE').toList();

  int get activeWorkersCount =>
      _workers.where((w) => w.status == 'ONLINE' || w.status == 'ALERT').length;

  int get alertsCount => _workers.where((w) => w.status == 'ALERT').length;

  int get offlineWorkersCount =>
      _workers.where((w) => w.status == 'OFFLINE').length;

  // ================= LEADER =================
  void _listenLeader() {
    _rootRef.child("Leader").onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      _updateWorker(
        vestId: "VEST-001",
        bpm: data['BPM'] ?? 0,
        temp: (data['Temp'] ?? 0).toDouble(),
        spo2: data['SpO2'] ?? 0,
        panic: data['Panic'] ?? 0,
        lat: (data['Lat'] ?? 0).toDouble(),
        lng: (data['Lng'] ?? 0).toDouble(),
        gas: data['Gas'] ?? 0,
        accelX: (data['AcceLX'] ?? 0).toDouble(),
        oxygenRate: data['O2'] ?? 0,
      );
    });
  }

  // ================= WORKER =================
  void _listenWorker() {
    _rootRef.child("Worker").onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      _updateWorker(
        vestId: "VEST-002",
        bpm: data['BPM'] ?? 0,
        temp: (data['Temp'] ?? 0).toDouble(),
        spo2: data['SpO2'] ?? 0,
        panic: data['Panic'] ?? 0,
        lat: (data['Lat'] ?? 0).toDouble(),
        lng: (data['Lng'] ?? 0).toDouble(),
        gas: data['Gas'] ?? 0,
        accelX: (data['AcceLX'] ?? 0).toDouble(),
        oxygenRate: data['O2'] ?? 0,
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

  void removeWorker(String id) {
    _workers.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void addWorker(Worker worker) {
    _workers.add(worker);
    notifyListeners();
  }

  String getNextWorkerId() {
    return (_workers.length + 1).toString().padLeft(3, '0');
  }
}
