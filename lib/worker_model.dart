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
  });
}
