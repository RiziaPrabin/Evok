import 'package:flutter/material.dart';
import 'worker_model.dart';

// WorkerProvider - Manages shared worker data across the app
class WorkerProvider extends ChangeNotifier {
  List<Worker> _workers = [
    Worker(
      name: 'Marcus Johnson',
      id: '001',
      vestId: 'VEST-001',
      shift: 'Day Shift',
      department: 'Excavation',
      location: 'Tunnel A-2',
      assigned: '2025-01-20',
      status: 'ONLINE',
      statusColor: const Color(0xFF00FF41),
    ),
    Worker(
      name: 'Sarah Chen',
      id: '002',
      vestId: 'VEST-002',
      shift: 'Day Shift',
      department: 'Safety Inspection',
      location: 'Tunnel B-1',
      assigned: '2025-01-20',
      status: 'ALERT',
      statusColor: Colors.red,
    ),
    Worker(
      name: 'David Rodriguez',
      id: '003',
      vestId: 'VEST-003',
      shift: 'Night Shift',
      department: 'Maintenance',
      location: 'Central Hub',
      assigned: '2025-01-20',
      status: 'ONLINE',
      statusColor: const Color(0xFF00FF41),
    ),
    Worker(
      name: 'Emily Watson',
      id: '004',
      vestId: 'VEST-004',
      shift: 'Day Shift',
      department: 'Transport',
      location: 'Unknown',
      assigned: '2025-01-19',
      status: 'OFFLINE',
      statusColor: Colors.grey,
    ),
  ];

  List<Worker> get workers => _workers;

  // Get only online workers for home page display
  List<Worker> get onlineWorkers =>
      _workers.where((w) => w.status == 'ONLINE').toList();

  // Get only alert workers for home page display
  List<Worker> get alertWorkers =>
      _workers.where((w) => w.status == 'ALERT').toList();

  // Get all workers for home page display (online + alert)
  List<Worker> get activeWorkers => _workers
      .where((w) => w.status == 'ONLINE' || w.status == 'ALERT')
      .toList();

  int get activeWorkersCount =>
      _workers.where((w) => w.status == 'ONLINE').length;

  int get alertsCount => _workers.where((w) => w.status == 'ALERT').length;

  int get offlineWorkersCount =>
      _workers.where((w) => w.status == 'OFFLINE').length;

  void addWorker(Worker worker) {
    _workers.add(worker);
    notifyListeners();
  }

  void updateWorker(Worker updatedWorker) {
    final index = _workers.indexWhere((w) => w.id == updatedWorker.id);
    if (index != -1) {
      _workers[index] = updatedWorker;
      notifyListeners();
    }
  }

  void removeWorker(String workerId) {
    _workers.removeWhere((w) => w.id == workerId);
    notifyListeners();
  }

  String getNextWorkerId() {
    if (_workers.isEmpty) return '001';

    int maxId = 0;
    for (var worker in _workers) {
      int currentId = int.tryParse(worker.id) ?? 0;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }
    return (maxId + 1).toString().padLeft(3, '0');
  }
}
