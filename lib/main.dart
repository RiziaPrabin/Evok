import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'worker_model.dart'; // Import the worker model
import 'add_worker_page.dart'; // Import the add worker page
import 'package:provider/provider.dart';
import 'worker_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'live_mine_map.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'live_tracking_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math' as math;
import 'alert_sound_service.dart';
import 'alert_threshold_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkerProvider(),
      child: const EvokApp(),
    ),
  );
}

class EvokApp extends StatelessWidget {
  const EvokApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVOK',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1520),
        primaryColor: const Color(0xFF00FF41),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const SupervisorLoginPage(),
    );
  }
}

// ==================== LOGIN PAGE ====================
class SupervisorLoginPage extends StatefulWidget {
  const SupervisorLoginPage({Key? key}) : super(key: key);

  @override
  State<SupervisorLoginPage> createState() => _SupervisorLoginPageState();
}

class _SupervisorLoginPageState extends State<SupervisorLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'supervisor' && password == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SupervisorDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials. Use supervisor/123'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FF41).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 80,
                      color: Color(0xFF00FF41),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'EVOK',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FF41),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2230),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00FF41).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Secure Access',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter supervisor credentials to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3344),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Supervisor Username',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF00FF41),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3344),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Secure Password',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF00FF41),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF41),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Access Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN DASHBOARD CONTAINER ====================
class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;

  // The 5 Content Pages
  final List<Widget> _pages = [
    const HomeContent(),
    const WorkerManagementContent(),
    const SafetyAlertsContent(),
    const CommunicationHubContent(),
    const AnalyticsDashboardContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of each page when switching
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F2230),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00FF41),
          unselectedItemColor: Colors.white54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Workers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Comms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 1. HOME CONTENT ====================
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);
  String _getDisplayName(Worker worker) {
    if (worker.vestId == 'VEST-001') {
      return '${worker.name} (W)'; // Marcus = Worker
    } else if (worker.vestId == 'VEST-002') {
      return '${worker.name} (L)'; // Sarah = Leader
    }
    return worker.name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        final allWorkers = workerProvider.workers;
        return SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00FF41).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: Color(0xFF00FF41),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EVOK SUPERVISOR',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'DASHBOARD',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Real-time Worker Monitoring',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupervisorLoginPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards - Now using real data
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Active\nWorkers',
                              workerProvider.activeWorkersCount.toString(),
                              'Currently online',
                              const Color(0xFF00FF41),
                              Icons.people_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Active\nAlerts',
                              workerProvider.alertsCount.toString(),
                              'Requiring attention',
                              Colors.red,
                              Icons.warning_amber_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Offline\nWorkers',
                              workerProvider.offlineWorkersCount.toString(),
                              'Connection lost',
                              Colors.grey,
                              Icons.signal_wifi_off,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Mine Layout - Live Positions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMineLayout(workerProvider),
                      const SizedBox(height: 24),
                      const Text(
                        'Worker Status Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display real worker data
                      if (allWorkers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No active workers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...allWorkers.map((worker) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildWorkerCard(
                              _getDisplayName(worker),
                              worker.vestId,
                              '${worker.heartRate} BPM',
                              '${worker.temperature.toStringAsFixed(1)}°C',
                              '${worker.spo2}% SpO₂',
                              worker.status,
                              worker.statusColor,
                              worker.lastUpdated == null ? '—' : 'Live',
                            ),
                          );
                        }).toList(),
                      const SizedBox(height: 24),

                      // Quick Actions section
                      const SizedBox(height: 24),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

// Emergency Broadcast Toggle Button - FULL WIDTH
                      Consumer<WorkerProvider>(
                        builder: (context, provider, child) {
                          final isActive = provider.isEmergencyBroadcastActive;

                          return SizedBox(
                            width: double.infinity, // ✅ Full width
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Show confirmation dialog
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF0F2230),
                                    title: Text(
                                      isActive
                                          ? '🛑 Stop Emergency Broadcast'
                                          : '⚠️ Start Emergency Broadcast',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      isActive
                                          ? 'This will clear all panic alerts and stop the emergency broadcast.'
                                          : 'This will trigger a panic alert for ALL workers.',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive
                                              ? Colors.orange
                                              : Colors.red,
                                        ),
                                        child:
                                            Text(isActive ? 'STOP' : 'CONFIRM'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // Toggle emergency broadcast
                                  await provider.toggleEmergencyBroadcast();

                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isActive
                                              ? '✅ Emergency broadcast stopped'
                                              : '🚨 Emergency broadcast activated',
                                        ),
                                        backgroundColor: isActive
                                            ? Colors.orange
                                            : Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                  isActive ? Icons.stop_circle : Icons.campaign,
                                  size: 24),
                              label: Text(
                                isActive
                                    ? 'Stop Emergency Broadcast'
                                    : 'Emergency Broadcast',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isActive ? Colors.orange : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18), // ✅ More vertical padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2230),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMineLayout(WorkerProvider provider) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const LiveMineMap(), // ✅ external widget
    );
  }

  Widget _buildWorkerDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(
    String name,
    String vestId,
    String bpm,
    String temp,
    String spo2,
    String status,
    Color statusColor,
    String lastUpdate,
  ) {
    bool isOffline = status == 'OFFLINE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Vest ID: $vestId',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          if (!isOffline) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildVitalSign(Icons.favorite, bpm, Colors.red),
                const SizedBox(width: 20),
                _buildVitalSign(Icons.thermostat, temp, Colors.orange),
                const SizedBox(width: 20),
                _buildVitalSign(Icons.air, spo2, Colors.blue),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Last update: $lastUpdate',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSign(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================== 2. WORKER MANAGEMENT CONTENT ====================
// Replace the entire WorkerManagementContent class with this:

// ==================== 2. WORKER MANAGEMENT CONTENT ====================
// Replace the entire WorkerManagementContent class with this:

class WorkerManagementContent extends StatefulWidget {
  const WorkerManagementContent({Key? key}) : super(key: key);

  @override
  State<WorkerManagementContent> createState() =>
      _WorkerManagementContentState();
}

class _WorkerManagementContentState extends State<WorkerManagementContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Worker> _getFilteredWorkers(List<Worker> workers) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return workers;

    return workers.where((w) {
      return w.name.toLowerCase().contains(query) ||
          w.vestId.toLowerCase().contains(query) ||
          w.id.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, _) {
        final filteredWorkers = _getFilteredWorkers(workerProvider.workers);

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00FF41).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: Color(0xFF00FF41),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WORKER MANAGEMENT',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Smart Vest Allocation & Tracking',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF41),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () async {
                          final newWorker = await Navigator.push<Worker>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddWorkerPage(
                                nextWorkerId: workerProvider.getNextWorkerId(),
                              ),
                            ),
                          );

                          if (newWorker != null) {
                            workerProvider.addWorker(newWorker);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search workers or vest IDs...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF1A3344),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildWorkerDetailCard(worker),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= CARD =================
  Widget _buildWorkerDetailCard(Worker worker) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                worker.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                worker.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: worker.statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'ID: ${worker.id} • Vest: ${worker.vestId}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          _buildDetailRow('Shift:', worker.shift),
          _buildDetailRow('Department:', worker.department),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                worker.latitude == 0
                    ? worker.location
                    : 'Lat: ${worker.latitude.toStringAsFixed(5)}, '
                        'Lng: ${worker.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildDetailRow('Assigned:', worker.assigned),

          const SizedBox(height: 16),

          // TRACK + DELETE
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveTrackingPage(
                          vestId: worker.vestId,
                          name: worker.name,
                        ),
                      ),
                    );
                  },
                  child: const Text('Track'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Worker'),
                        content: const Text(
                          'Are you sure you want to delete this worker permanently?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      context.read<WorkerProvider>().removeWorker(worker.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Worker deleted successfully'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // RESOLVE ALERT
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Resolve Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: worker.status == 'ALERT'
                  ? () async {
                      await context
                          .read<WorkerProvider>()
                          .resolveWorkerAlert(worker.vestId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alert resolved. Worker is ONLINE'),
                          backgroundColor: Color(0xFF00C853),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ROW =================
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ==================== 3. SAFETY ALERTS CONTENT ====================

class SafetyAlertsContent extends StatefulWidget {
  const SafetyAlertsContent({Key? key}) : super(key: key);

  @override
  State<SafetyAlertsContent> createState() => _SafetyAlertsContentState();
}

class _SafetyAlertsContentState extends State<SafetyAlertsContent> {
  String _selectedFilter = 'Active';

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        // ✅ Generate alerts IMMEDIATELY from current worker state
        final alerts = _generateAlertsFromWorkers(workerProvider);

        // Filter alerts based on selected filter
        final filteredAlerts = _filterAlerts(alerts, _selectedFilter);

        // Count alerts by status
        final activeCount = alerts.where((a) => a['status'] == 'ACTIVE').length;
        final resolvedCount =
            alerts.where((a) => a['status'] == 'RESOLVED').length;

        return SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00FF41).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: Color(0xFF00FF41),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SAFETY ALERTS',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Real-time Worker Safety Monitoring',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ ONLY 2 NAVIGATION TABS: ACTIVE & RESOLVED
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterTab(
                        label: 'Active',
                        count: activeCount,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterTab(
                        label: 'Resolved',
                        count: resolvedCount,
                        color: const Color(0xFF00FF41),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: filteredAlerts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFilter == 'Active'
                                  ? Icons.check_circle_outline
                                  : Icons.history,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Active'
                                  ? 'No active alerts'
                                  : 'No resolved alerts',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilter == 'Active'
                                  ? 'All workers are safe'
                                  : 'No alerts have been resolved yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = filteredAlerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildAlertCard(
                              context: context,
                              alert: alert,
                              workerProvider: workerProvider,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateAlertsFromWorkers(
      WorkerProvider provider) {
    final alerts = <Map<String, dynamic>>[];

    for (final worker in provider.workers) {
      // ✅ ONLY SHOW MARCUS JOHNSON (VEST-001) ALERTS
      if (worker.vestId != 'VEST-001') {
        continue;
      }

      // ✅ Get ACTIVE alerts from threshold service
      final activeAlerts = provider.getWorkerAlerts(worker.vestId);

      // ✅ Get RESOLVED alerts from threshold service
      final resolvedAlerts = provider.getResolvedAlerts(worker.vestId);

      // ✅ Generate cards for ACTIVE alerts
      for (final alertType in activeAlerts) {
        alerts.add({
          'type': AlertThresholdService.getAlertDisplayName(alertType),
          'alertType': alertType,
          'title': _getAlertTitle(alertType, worker),
          'workerName': worker.name,
          'vestId': worker.vestId,
          'location': worker.location,
          'time': _getTimeAgo(worker.lastUpdated),
          'status': 'ACTIVE',
          'severity': _getAlertSeverity(alertType),
          'statusColor': AlertThresholdService.getAlertColor(alertType),
          'cardColor': AlertThresholdService.getAlertColor(alertType),
          'icon': AlertThresholdService.getAlertIcon(alertType),
          'vitals': _getVitalsString(worker, alertType),
          'worker': worker,
        });
      }

      // ✅ Generate cards for RESOLVED alerts
      for (final alertType in resolvedAlerts) {
        // Don't show if it's also in active (means it triggered again)
        if (!activeAlerts.contains(alertType)) {
          alerts.add({
            'type': AlertThresholdService.getAlertDisplayName(alertType),
            'alertType': alertType,
            'title': _getAlertTitle(alertType, worker),
            'workerName': worker.name,
            'vestId': worker.vestId,
            'location': worker.location,
            'time': _getTimeAgo(worker.lastUpdated),
            'status': 'RESOLVED',
            'severity': _getAlertSeverity(alertType),
            'statusColor': AlertThresholdService.getAlertColor(alertType),
            'cardColor': AlertThresholdService.getAlertColor(alertType),
            'icon': AlertThresholdService.getAlertIcon(alertType),
            'vitals': _getVitalsString(worker, alertType),
            'worker': worker,
          });
        }
      }

      // ✅ Add panic alert if panic button is pressed
      if (worker.panic == 1) {
        final hasPanicAlert = alerts.any((a) =>
            a['vestId'] == worker.vestId && a['alertType'] == 'PANIC_BUTTON');

        if (!hasPanicAlert) {
          alerts.add({
            'type': 'PANIC ALERT',
            'alertType': 'PANIC_BUTTON',
            'title': 'Emergency panic button activated',
            'workerName': worker.name,
            'vestId': worker.vestId,
            'location': worker.location,
            'time': _getTimeAgo(worker.lastUpdated),
            'status': 'ACTIVE',
            'severity': 'CRITICAL',
            'statusColor': Colors.red,
            'cardColor': Colors.red,
            'icon': Icons.pan_tool,
            'vitals': _getVitalsString(worker, 'PANIC_BUTTON'),
            'worker': worker,
          });
        }
      }
    }

    // Sort: Active alerts first (by severity), then resolved alerts
    alerts.sort((a, b) {
      // Active alerts always come first
      if (a['status'] == 'ACTIVE' && b['status'] != 'ACTIVE') {
        return -1;
      }
      if (b['status'] == 'ACTIVE' && a['status'] != 'ACTIVE') {
        return 1;
      }

      // Within same status, critical first
      if (a['severity'] == 'CRITICAL' && b['severity'] != 'CRITICAL') {
        return -1;
      }
      if (b['severity'] == 'CRITICAL' && a['severity'] != 'CRITICAL') {
        return 1;
      }

      // Then by time
      final timeA = a['worker'].lastUpdated ?? DateTime.now();
      final timeB = b['worker'].lastUpdated ?? DateTime.now();
      return timeB.compareTo(timeA);
    });

    return alerts;
  }

  String _getAlertTitle(String alertType, worker) {
    switch (alertType) {
      case 'LOW_HEART_RATE':
        return 'Low heart rate detected - ${worker.heartRate} BPM';
      case 'HIGH_HEART_RATE':
        return 'High heart rate detected - ${worker.heartRate} BPM';
      case 'HIGH_TEMPERATURE':
        return 'High body temperature - ${worker.temperature.toStringAsFixed(1)}°C';
      case 'LOW_TEMPERATURE':
        return 'Low body temperature - ${worker.temperature.toStringAsFixed(1)}°C';
      case 'LOW_SPO2':
        return 'Critical SpO₂ levels detected - ${worker.spo2}%';
      case 'HIGH_GAS':
        return 'Dangerous gas level detected - ${worker.gasRate} ppm';
      case 'LOW_OXYGEN':
        return 'Low oxygen level - ${worker.oxygenRate}%';
      case 'FALL_DETECTED':
        return 'Fall detection triggered - worker may need assistance';
      case 'PANIC_BUTTON':
        return 'Emergency panic button activated';
      default:
        return 'Safety alert triggered';
    }
  }

  String _getVitalsString(worker, String alertType) {
    switch (alertType) {
      case 'LOW_HEART_RATE':
      case 'HIGH_HEART_RATE':
        return '${worker.heartRate} BPM  •  ${worker.temperature.toStringAsFixed(1)}°C  •  ${worker.spo2}% SpO₂';
      case 'LOW_SPO2':
        return '${worker.heartRate} BPM  •  ${worker.temperature.toStringAsFixed(1)}°C  •  ${worker.spo2}% SpO₂';
      case 'HIGH_TEMPERATURE':
        return '${worker.heartRate} BPM  •  ${worker.temperature.toStringAsFixed(1)}°C';
      case 'LOW_TEMPERATURE':
        return '${worker.heartRate} BPM  •  ${worker.temperature.toStringAsFixed(1)}°C';
      case 'HIGH_GAS':
        return '${worker.gasRate} ppm Gas  •  ${worker.oxygenRate}% O₂';
      case 'LOW_OXYGEN':
        return '${worker.oxygenRate}% O₂  •  ${worker.gasRate} ppm Gas';
      case 'FALL_DETECTED':
        return 'X: ${worker.accelX.toStringAsFixed(2)}g  •  Y: ${worker.accelY.toStringAsFixed(2)}g  •  Z: ${worker.accelZ.toStringAsFixed(2)}g';
      case 'PANIC_BUTTON':
        return '${worker.heartRate} BPM  •  ${worker.temperature.toStringAsFixed(1)}°C  •  ${worker.spo2}% SpO₂';
      default:
        return '';
    }
  }

  String _getAlertSeverity(String alertType) {
    switch (alertType) {
      case 'FALL_DETECTED':
      case 'PANIC_BUTTON':
      case 'LOW_SPO2':
      case 'LOW_OXYGEN':
        return 'CRITICAL';
      case 'LOW_TEMPERATURE':
        return 'WARNING';
      default:
        return 'WARNING';
    }
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';

    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// ✅ SIMPLIFIED FILTER - ONLY ACTIVE OR RESOLVED
  List<Map<String, dynamic>> _filterAlerts(
      List<Map<String, dynamic>> alerts, String filter) {
    if (filter == 'Active') {
      return alerts.where((a) => a['status'] == 'ACTIVE').toList();
    } else if (filter == 'Resolved') {
      return alerts.where((a) => a['status'] == 'RESOLVED').toList();
    }
    return alerts;
  }

  /// ✅ UPDATED TAB WITH COUNT BADGE
  Widget _buildFilterTab({
    required String label,
    required int count,
    required Color color,
  }) {
    bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A4A5F) : const Color(0xFF1A3344),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (label == 'Active' ? Colors.white : Colors.black)
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required Map<String, dynamic> alert,
    required WorkerProvider workerProvider,
  }) {
    final isActive = alert['status'] == 'ACTIVE';
    final isResolved = alert['status'] == 'RESOLVED';
    final isCritical = alert['severity'] == 'CRITICAL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isResolved
            ? Colors.grey.withOpacity(0.2)
            : (alert['cardColor'] as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved
              ? Colors.grey.withOpacity(0.5)
              : (alert['cardColor'] as Color).withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(alert['icon'],
                      color: isResolved ? Colors.grey : alert['statusColor'],
                      size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['type'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isResolved ? Colors.grey : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isCritical && !isResolved)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: const Text(
                            'CRITICAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.red : const Color(0xFF00FF41),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert['status'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert['title'],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isResolved ? Colors.grey : Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person,
                  color: isResolved ? Colors.grey : Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${alert['workerName']} (${alert['vestId']})',
                style: TextStyle(
                    fontSize: 13,
                    color: isResolved ? Colors.grey : Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on,
                  color: isResolved ? Colors.grey : Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                alert['location'],
                style: TextStyle(
                    fontSize: 13,
                    color: isResolved ? Colors.grey : Colors.white),
              ),
            ],
          ),
          if (alert['vitals'] != null &&
              alert['vitals'].toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart,
                    size: 14,
                    color: isResolved ? Colors.grey : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert['vitals'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isResolved ? Colors.grey : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time,
                  color: isResolved ? Colors.grey : Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                alert['time'],
                style: TextStyle(
                    fontSize: 12,
                    color: isResolved ? Colors.grey : Colors.white70),
              ),
            ],
          ),

          // ✅ SHOW BUTTONS ONLY FOR ACTIVE ALERTS
          if (isActive) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await workerProvider.sendManualAlertCommand(
                        alert['vestId'],
                        alert['alertType'],
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔊 Voice alert sent to leader'),
                            backgroundColor: Colors.purple,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Send Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // ✅ CRITICAL FIX: Resolve ONLY this specific alert
                      await workerProvider.resolveSpecificAlert(
                        alert['vestId'],
                        alert['alertType'],
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ ${alert['type']} resolved for ${alert['workerName']}',
                            ),
                            backgroundColor: const Color(0xFF00FF41),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF41),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ✅ SHOW RESOLVED BADGE FOR RESOLVED ALERTS
          if (isResolved) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF41).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00FF41).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF00FF41),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Alert Resolved - Condition Normal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF41),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// ==================== COMMUNICATION HUB CONTENT ====================

class CommunicationHubContent extends StatefulWidget {
  const CommunicationHubContent({Key? key}) : super(key: key);

  @override
  State<CommunicationHubContent> createState() =>
      _CommunicationHubContentState();
}

class _CommunicationHubContentState extends State<CommunicationHubContent> {
  String _selectedTab = 'Messaging';

  // Firebase reference
  final DatabaseReference _audioCommandRef = FirebaseDatabase.instance.ref(
    "EVOK_System/Audio_Command",
  );

  Position? _currentPosition;
  String _currentAddress = "";

  // Predefined commands with emojis
  final List<Map<String, dynamic>> commands = [
    {
      "command": "FIRE_DETECTED",
      "display": "Fire Detected",
      "emoji": "🔥",
      "color": Colors.red,
    },
    {
      "command": "EVACUATE",
      "display": "Evacuate",
      "emoji": "🚨",
      "color": Colors.orange,
    },
    {
      "command": "STOP_WORK",
      "display": "Stop Work",
      "emoji": "✋",
      "color": Colors.amber,
    },
    {
      "command": "ROCK_FALL_WARNING",
      "display": "Rock Fall Warning",
      "emoji": "⛰️",
      "color": Colors.red,
    },
    {
      "command": "GAS_DETECTED",
      "display": "Gas Detected",
      "emoji": "💨",
      "color": Colors.purple,
    },
    {
      "command": "EQUIPMENT_FAILURE",
      "display": "Equipment Failure",
      "emoji": "⚠️",
      "color": Colors.yellow,
    },
    {
      "command": "ALL_CLEAR",
      "display": "All Clear",
      "emoji": "✅",
      "color": Colors.green,
    },
    {
      "command": "RETURN_TO_STATION",
      "display": "Return to Station",
      "emoji": "🏠",
      "color": Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      _showSnackBar('Error getting location');
    }
  }

  // Send audio command to Firebase
  Future<void> _sendAudioCommand(String command, String displayText) async {
    try {
      await _audioCommandRef.set({
        'command': command,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Show confirmation dialog
      _showCommandConfirmation(displayText, command);
    } catch (e) {
      debugPrint("Error sending command: $e");
      _showSnackBar('Failed to send command');
    }
  }

  void _showCommandConfirmation(String displayText, String command) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2F3F),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00FF41)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Command Sent',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broadcasting to all workers:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF41).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF00FF41)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText,
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Command: $command',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00FF41),
                foregroundColor: Colors.black,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // Auto close after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A3344),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _activateProtocol(String protocolName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2F3F),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Activate Protocol',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to activate:\n\n$protocolName',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('$protocolName activated successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Activate'),
            ),
          ],
        );
      },
    );
  }

  // Find nearest place using Overpass API (OpenStreetMap - Free, no API key needed)
  Future<Map<String, dynamic>?> _findNearestPlace(String placeType) async {
    if (_currentPosition == null) {
      _showSnackBar('Location not available. Please wait...');
      return null;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2F3F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF00FF41)),
                SizedBox(height: 16),
                Text(
                  'Finding nearest $placeType...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );

      // Overpass API query - simplified and faster with 5km radius
      String query;

      if (placeType == 'police') {
        query = '''
        [out:json][timeout:15];
        (
          node["amenity"="police"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["amenity"="police"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          node["office"="government"]["government"="police"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["office"="government"]["government"="police"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
        );
        out center;
        ''';
      } else if (placeType == 'hospital') {
        query = '''
        [out:json][timeout:15];
        (
          node["amenity"="hospital"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["amenity"="hospital"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          node["amenity"="clinic"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["amenity"="clinic"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
        );
        out center;
        ''';
      } else if (placeType == 'fire_station') {
        query = '''
        [out:json][timeout:15];
        (
          node["amenity"="fire_station"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["amenity"="fire_station"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
        );
        out center;
        ''';
      } else {
        query = '''
        [out:json][timeout:15];
        (
          node["amenity"="$placeType"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
          way["amenity"="$placeType"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
        );
        out center;
        ''';
      }

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(
        url,
        body: query,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> elements = data['elements'] ?? [];

        if (elements.isEmpty) {
          _showSnackBar('No nearby $placeType found within 5km');
          _showEmergencyNumbersFallback(placeType);
          return null;
        }

        // Find the nearest one by calculating distance
        Map<String, dynamic>? nearest;
        double minDistance = double.infinity;

        for (var element in elements) {
          double? lat;
          double? lon;

          if (element['lat'] != null && element['lon'] != null) {
            lat = element['lat'].toDouble();
            lon = element['lon'].toDouble();
          } else if (element['center'] != null) {
            lat = element['center']['lat'].toDouble();
            lon = element['center']['lon'].toDouble();
          }

          if (lat != null && lon != null) {
            double distance = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lon,
            );

            if (distance < minDistance) {
              minDistance = distance;
              nearest = {
                'name': element['tags']?['name'] ??
                    element['tags']?['operator'] ??
                    'Unnamed $placeType',
                'lat': lat,
                'lon': lon,
                'distance': (distance / 1000).toStringAsFixed(2),
                'phone': element['tags']?['phone'] ??
                    element['tags']?['contact:phone'] ??
                    element['tags']?['emergency:phone'] ??
                    'Not available',
                'address': element['tags']?['addr:full'] ??
                    '${element['tags']?['addr:street'] ?? ''} ${element['tags']?['addr:city'] ?? ''}'
                        .trim(),
              };
            }
          }
        }

        if (nearest == null) {
          _showSnackBar('Could not find location details');
          return null;
        }

        return nearest;
      } else {
        _showSnackBar('Error finding nearby places');
        return null;
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      debugPrint("Error finding nearest place: $e");
      _showSnackBar('Error: $e');
      return null;
    }
  }

  Future<void> _callNearestService(
    String serviceType,
    String serviceName,
  ) async {
    final placeInfo = await _findNearestPlace(serviceType);

    if (placeInfo == null) {
      return;
    }

    String phoneNumber = placeInfo['phone'];
    bool hasPhoneNumber = phoneNumber != 'Not available';

    bool? action = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2F3F),
          title: Text(
            'Nearest $serviceName Found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 Location:',
                style: TextStyle(
                  color: Color(0xFF00FF41),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                placeInfo['name'],
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (placeInfo['address'].isNotEmpty) ...[
                SizedBox(height: 6),
                Text(
                  placeInfo['address'],
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.directions, color: Color(0xFF00FF41), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Distance: ${placeInfo['distance']} km',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (hasPhoneNumber) ...[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF00FF41).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF00FF41), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color(0xFF00FF41), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                color: Color(0xFF00FF41),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Phone number available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Phone number not available',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tip: Open in Google Maps to find contact details and get directions',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            if (hasPhoneNumber)
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(Icons.phone, size: 18),
                label: Text('Call Now'),
              ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00FF41),
                foregroundColor: Colors.black,
              ),
              icon: Icon(Icons.map, size: 18),
              label: Text('Open Maps'),
            ),
          ],
        );
      },
    );

    if (action == true && hasPhoneNumber) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

      try {
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
          _showSnackBar('Calling ${placeInfo['name']}');
        } else {
          _showSnackBar('Could not launch phone app');
        }
      } catch (e) {
        debugPrint("Error making call: $e");
        _showSnackBar('Error: $e');
      }
    } else if (action == false) {
      _openInGoogleMaps(placeInfo['lat'], placeInfo['lon'], placeInfo['name']);
    }
  }

  Future<void> _openInGoogleMaps(
    double lat,
    double lon,
    String placeName,
  ) async {
    try {
      final Uri googleMapsApp = Uri.parse('google.navigation:q=$lat,$lon');
      final Uri geoUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
      final Uri googleMapsWeb = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
      );
      final Uri genericMaps = Uri.parse(
        'geo:0,0?q=$lat,$lon(${Uri.encodeComponent(placeName)})',
      );

      bool launched = false;

      if (await canLaunchUrl(googleMapsApp)) {
        launched = await launchUrl(
          googleMapsApp,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          _showSnackBar('Opening in Google Maps...');
          return;
        }
      }

      if (!launched && await canLaunchUrl(geoUri)) {
        launched = await launchUrl(
          geoUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          _showSnackBar('Opening in Maps...');
          return;
        }
      }

      if (!launched && await canLaunchUrl(googleMapsWeb)) {
        launched = await launchUrl(
          googleMapsWeb,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          _showSnackBar('Opening in browser...');
          return;
        }
      }

      if (!launched && await canLaunchUrl(genericMaps)) {
        launched = await launchUrl(
          genericMaps,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          _showSnackBar('Opening in Maps...');
          return;
        }
      }

      _showSnackBar('Could not open maps. Coordinates: $lat, $lon');
      _showManualMapsDialog(lat, lon, placeName);
    } catch (e) {
      debugPrint("Error opening maps: $e");
      _showSnackBar('Error opening maps');
      _showManualMapsDialog(lat, lon, placeName);
    }
  }

  void _showManualMapsDialog(double lat, double lon, String placeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2F3F),
          title: Text(
            'Location Coordinates',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not open maps automatically. Here are the coordinates:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF41).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF00FF41)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName,
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      'Latitude: ${lat.toStringAsFixed(6)}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    SelectableText(
                      'Longitude: ${lon.toStringAsFixed(6)}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Copy these coordinates and paste in Google Maps',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '$lat, $lon'));
                Navigator.of(context).pop();
                _showSnackBar('Coordinates copied to clipboard');
              },
              child: Text(
                'Copy Coordinates',
                style: TextStyle(color: Color(0xFF00FF41)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00FF41),
                foregroundColor: Colors.black,
              ),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, String serviceName) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2F3F),
          title: Text(
            'Emergency Call',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calling: $serviceName',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Number: $phoneNumber',
                style: TextStyle(color: Color(0xFF00FF41), fontSize: 14),
              ),
              if (_currentAddress.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Your Location:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _currentAddress,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
              if (_currentPosition != null) ...[
                SizedBox(height: 4),
                Text(
                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                  'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Call Now'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

      try {
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
          _showSnackBar('Calling $serviceName...');
        } else {
          _showSnackBar('Could not launch phone app');
        }
      } catch (e) {
        debugPrint("Error making call: $e");
        _showSnackBar('Error making call: $e');
      }
    }
  }

  void _showEmergencyNumbersFallback(String placeType) {
    String emergencyNumber = '';
    String serviceName = '';

    if (placeType == 'police') {
      emergencyNumber = '100';
      serviceName = 'Police Emergency (India)';
    } else if (placeType == 'hospital') {
      emergencyNumber = '108';
      serviceName = 'Ambulance Emergency (India)';
    } else if (placeType == 'fire_station') {
      emergencyNumber = '101';
      serviceName = 'Fire Emergency (India)';
    }

    if (emergencyNumber.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A2F3F),
            title: Row(
              children: [
                Icon(Icons.phone, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use Emergency Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to find nearby location. Use the national emergency number instead:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF00FF41).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color(0xFF00FF41), size: 20),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emergencyNumber,
                            style: TextStyle(
                              color: Color(0xFF00FF41),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            serviceName,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _makePhoneCall(emergencyNumber, serviceName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Call Now'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00FF41).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shield_outlined,
                          size: 28,
                          color: Color(0xFF00FF41),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMMUNICATION HUB',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Multilingual Safety Communications',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Messaging',
                    Icons.message,
                    _selectedTab == 'Messaging',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    'Emergency',
                    Icons.phone,
                    _selectedTab == 'Emergency',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedTab == 'Messaging'
                ? _buildMessagingContent()
                : _buildEmergencyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3344),
          borderRadius: BorderRadius.circular(10),
          border: isSelected && label == 'Emergency'
              ? Border.all(color: const Color(0xFF00FF41), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00FF41) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF00FF41) : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NEW MESSAGING CONTENT ====================
  Widget _buildMessagingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predefined Commands
          const Text(
            'Audio Commands',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a command to broadcast it to all workers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Command Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final command = commands[index];
              return _buildCommandCard(
                emoji: command['emoji'],
                label: command['display'],
                color: command['color'],
                onTap: () => _sendAudioCommand(
                  command['command'],
                  command['display'],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCommandCard({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2F3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: color, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Tap to send',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMERGENCY CONTENT (UNCHANGED) ====================
  // ... [Keep all imports and Messaging logic exactly as they were] ...

  // ==================== EMERGENCY CONTENT ====================
  // ==================== EMERGENCY CONTENT (UPDATED) ====================
  Widget _buildEmergencyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header (Address Display)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2F3F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.red, size: 50),
                const SizedBox(height: 12),
                const Text(
                  'Emergency Response',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Direct Dial & Proximity Search',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.6)),
                ),
                if (_currentAddress.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF41).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF00FF41), size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _currentAddress,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF00FF41)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Emergency Grid
          Row(
            children: [
              Expanded(
                child: _buildEmergencyCard(
                  '🚒',
                  'Fire Dept.',
                  '101',
                  onCall: () =>
                      _makePhoneCall('101', 'Fire Department'), // Dials 101
                  onLocate: () => _callNearestService('fire_station',
                      'Fire Department'), // Existing Search Logic
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyCard(
                  '👮',
                  'Police',
                  '100',
                  onCall: () =>
                      _makePhoneCall('100', 'Police Emergency'), // Dials 100
                  onLocate: () => _callNearestService(
                      'police', 'Police Emergency'), // Existing Search Logic
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyCard(
                  '🚑',
                  'Ambulance',
                  '108',
                  onCall: () =>
                      _makePhoneCall('108', 'Medical Emergency'), // Dials 108
                  onLocate: () => _callNearestService(
                      'hospital', 'Medical Emergency'), // Existing Search Logic
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyCard(
                  '🏢',
                  'Safety Office',
                  'SITE-HQ',
                  onCall: () =>
                      _makePhoneCall('+911123456789', 'Mine Safety Office'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildEmergencyCard(
              '👷',
              'Site Manager (Urgent)',
              '+91 9876543210',
              isFullWidth: true,
              onCall: () => _makePhoneCall('+919876543210', 'Site Manager'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // UPDATED CARD WIDGET: Dual-action for Dial and Locate
  Widget _buildEmergencyCard(
    String emoji,
    String title,
    String number, {
    bool isFullWidth = false,
    required VoidCallback onCall,
    VoidCallback? onLocate, // Optional locator button
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            number,
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ACTION 1: Direct Phone Call
              GestureDetector(
                onTap: onCall,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.phone, color: Colors.white, size: 20),
                ),
              ),
              // ACTION 2: Location Search (If provided)
              if (onLocate != null) ...[
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: onLocate,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF41).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF00FF41), width: 1),
                    ),
                    child: const Icon(Icons.my_location,
                        color: Color(0xFF00FF41), size: 20),
                  ),
                ),
              ],
            ],
          ),
          if (onLocate != null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Dial   |   Locate',
                style: TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2F3F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
// ==================== 5. ANALYTICS DASHBOARD CONTENT ====================
// ==================== 5. ANALYTICS DASHBOARD CONTENT ====================
// ==================== 5. ANALYTICS DASHBOARD CONTENT ====================
// ==================== 5. ANALYTICS DASHBOARD CONTENT ====================

/// ===== ANIMATED VITAL CARD =====
class AnalyticsDashboardContent extends StatefulWidget {
  const AnalyticsDashboardContent({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardContent> createState() =>
      _AnalyticsDashboardContentState();
}

class _AnalyticsDashboardContentState extends State<AnalyticsDashboardContent>
    with SingleTickerProviderStateMixin {
  String? selectedVestId; // Keep this as nullable
  late AnimationController _rotationController;
  bool _isInitialized = false;
  bool _wasFallDetected = false; // ✅ Add this flag

  Worker? selectedWorker; // 🔹 Add this line to fix the getter/setter errors

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // 1. Logic to convert AccelX number into "Stable" or "FALL!"
  String _getFallStatus(double x, double y, double z) {
    if (x.isNaN || y.isNaN || z.isNaN || (x == 0 && y == 0 && z == 0))
      return "Stable";

    // Calculate total resultant acceleration
    double magnitude = math.sqrt(x * x + y * y + z * z);

    // Threshold matching your friend's Arduino '2.5G' logic
    // If your sensor gives m/s², use 25.0. If it gives Gs, use 2.5.
    if (magnitude > 25.0 || magnitude < 2.0) {
      return "FALL DETECTED!";
    }
    return "Stable";
  }

  // 2. Updated: Accepts 3 arguments (X, Y, Z)
  Color _getFallColor(double x, double y, double z) {
    if (x.isNaN || y.isNaN || z.isNaN || (x == 0 && y == 0 && z == 0))
      return Colors.purple;

    double magnitude = math.sqrt(x * x + y * y + z * z);

    if (magnitude > 25.0 || magnitude < 2.0) {
      return Colors.red; // Alert color
    }
    return Colors.purple; // Normal color
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();

    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    DatabaseReference workerRef =
        FirebaseDatabase.instance.ref("EVOK_System/Live_Data/Worker");
    workerRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          // 1. Get current status from Arduino Server
          int currentPanic = data['Panic'] ?? 0;

          // 2. Fetch 3D Accel values to calculate fall locally
          // Note: Check if your friend is using 'Accel' or 'accel' in Firebase
          double x = (data['Accel']?['X'] ?? 0.0).toDouble();
          double y = (data['Accel']?['Y'] ?? 0.0).toDouble();
          double z = (data['Accel']?['Z'] ?? 0.0).toDouble();

          double magnitude = math.sqrt(x * x + y * y + z * z);

          // 3. Logic: If Server flags Panic OR local math detects high impact
          bool isFalling =
              (currentPanic == 1) || (magnitude > 25.0 || magnitude < 2.0);

          // 4. Trigger the Sound/Notification ONLY once per event
          if (isFalling && !_wasFallDetected) {
            _showFallNotification();
            _wasFallDetected = true;
          } else if (!isFalling) {
            _wasFallDetected = false; // Reset so it can trigger again later
          }

          // 5. Update your selectedWorker so the UI Gauges move
          if (selectedWorker != null) {
            selectedWorker = selectedWorker!.copyWith(
              heartRate: data['HeartRate'] ?? 0,
              spo2: data['SpO2'] ?? 0,
              temperature: (data['BodyTemp'] ?? 0.0).toDouble(),
              accelX: x,
              accelY: y,
              accelZ: z,
              panic: currentPanic,
            );
          }
        });
      }
    });
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showFallNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fall_alert_channel', // ID
      'Fall Alerts', // Name
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // 🔥 Enables Sound
      enableVibration: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      '⚠️ FALL DETECTED!',
      'A worker has fallen. Immediate action required.',
      platformChannelSpecifics,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, provider, _) {
        final workers = provider.workers;

        if (workers.isEmpty) {
          return const Center(
            child: Text("No workers available",
                style: TextStyle(color: Colors.white)),
          );
        }

        if (!_isInitialized && workers.isNotEmpty) {
          selectedVestId = workers.first.vestId;
          _isInitialized = true;
          // Force a rebuild after initialization
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }

        final String currentVestId = selectedVestId ?? workers.first.vestId;
        final selectedWorker = workers.firstWhere(
          (w) => w.vestId == currentVestId,
          orElse: () => workers.first,
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00FF41).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shield_outlined,
                          size: 28,
                          color: Color(0xFF00FF41),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WORKER DETAILED VIEW',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Real-time Vitals Display',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3344),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1A3344),
                      value:
                          currentVestId, // ✅ This now has a proper initial value
                      isExpanded: true,
                      items: workers.map((w) {
                        return DropdownMenuItem(
                          value: w.vestId,
                          child: Text("${w.name} (${w.vestId})",
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && val != selectedVestId) {
                          // ✅ Added null check
                          setState(() {
                            selectedVestId = val;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ROTATING IMAGE
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    final angle = _rotationController.value * 2 * math.pi;

                    return Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0005)
                          ..rotateY(angle),
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    selectedWorker.vestId == "VEST-001"
                        ? "assets/workers/marcus.png"
                        : "assets/workers/sarah.png",
                    height: 220,
                  ),
                ),

                const SizedBox(height: 16),

                /// VITAL CARDS
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _animatedVitalCard(
                        Icons.favorite,
                        "${selectedWorker.heartRate} BPM",
                        "Heart Rate",
                        Colors.red),
                    _animatedVitalCard(
                        Icons.thermostat,
                        "${selectedWorker.temperature.toStringAsFixed(1)} °C",
                        "Temperature",
                        Colors.orange),
                    _animatedVitalCard(Icons.air, "${selectedWorker.spo2} %",
                        "SpO₂", Colors.blue),
                    _animatedVitalCard(Icons.bloodtype,
                        "${selectedWorker.oxygenRate}", "Oxygen", Colors.cyan),
                    _animatedVitalCard(
                      Icons.cloud,
                      "${selectedWorker.gasRate} PPM", // Unit updated to uppercase PPM
                      "Gas",
                      selectedWorker.gasRate > 400
                          ? Colors.orange
                          : Colors.green, // Dynamic color
                    ),

                    _animatedVitalCard(
                      Icons.screen_rotation,
                      _getFallStatus(selectedWorker.accelX,
                          selectedWorker.accelY, selectedWorker.accelZ),
                      "Fall Status",
                      _getFallColor(selectedWorker.accelX,
                          selectedWorker.accelY, selectedWorker.accelZ),
                    ),

                    /// LOCATION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2F3F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedWorker.latitude == 0
                                  ? selectedWorker.location
                                  : "Lat: ${selectedWorker.latitude.toStringAsFixed(5)}, "
                                      "Lng: ${selectedWorker.longitude.toStringAsFixed(5)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// STATUS
                    Row(
                      children: [
                        const Text("Status: ",
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          selectedWorker.status,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedWorker.statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _animatedVitalCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 70) / 3,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),

          // ✅ FIXED: Removed AnimatedSwitcher that was causing blinking
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER CLASSES ====================
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 0; i <= 3; i++) {
      double y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
