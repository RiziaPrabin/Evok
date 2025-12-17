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

void main() {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        final allWorkers = workerProvider.activeWorkers;

        return SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EVOK Supervisor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 20,
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
                              worker.name,
                              worker.vestId,
                              '75 BPM', // Default vitals
                              '98.6°F',
                              '97% SpO₂',
                              worker.status,
                              worker.statusColor,
                              '2 min ago',
                            ),
                          );
                        }).toList(),
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.campaign),
                              label: const Text('Emergency Broadcast'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
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
    final onlineWorkers = provider.onlineWorkers;
    final alertWorkers = provider.alertWorkers;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: GridPainter(),
          ),
          // Position workers dynamically based on their status
          ...List.generate(onlineWorkers.length, (index) {
            final positions = [
              const Offset(180, 110),
              const Offset(130, 150),
              const Offset(220, 80),
              const Offset(100, 100),
            ];
            if (index < positions.length) {
              return Positioned(
                left: positions[index].dx,
                top: positions[index].dy,
                child: _buildWorkerDot(Colors.green),
              );
            }
            return const SizedBox.shrink();
          }),
          ...List.generate(alertWorkers.length, (index) {
            final positions = [const Offset(280, 80), const Offset(150, 70)];
            if (index < positions.length) {
              return Positioned(
                left: positions[index].dx,
                top: positions[index].dy,
                child: _buildWorkerDot(Colors.red),
              );
            }
            return const SizedBox.shrink();
          }),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  Colors.green,
                  'Online (${onlineWorkers.length})',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, 'Alert (${alertWorkers.length})'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.grey, 'Offline'),
              ],
            ),
          ),
        ],
      ),
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

class WorkerManagementContent extends StatefulWidget {
  const WorkerManagementContent({Key? key}) : super(key: key);

  @override
  State<WorkerManagementContent> createState() =>
      _WorkerManagementContentState();
}

class _WorkerManagementContentState extends State<WorkerManagementContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Worker> filteredWorkers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterWorkers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWorkers() {
    setState(() {}); // Trigger rebuild to update filtered list
  }

  List<Worker> _getFilteredWorkers(List<Worker> workers) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return workers;
    } else {
      return workers.where((worker) {
        return worker.name.toLowerCase().contains(query) ||
            worker.vestId.toLowerCase().contains(query) ||
            worker.id.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        final filteredWorkers = _getFilteredWorkers(workerProvider.workers);

        return SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Worker Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Vest Allocation & Tracking',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3344),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search workers or vest IDs...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF41),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final newWorker = await Navigator.push<Worker>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddWorkerPage(
                                nextWorkerId: workerProvider.getNextWorkerId(),
                              ),
                            ),
                          );

                          if (newWorker != null) {
                            workerProvider.addWorker(newWorker);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${newWorker.name} added successfully',
                                  ),
                                  backgroundColor: const Color(0xFF00FF41),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                        iconSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      workerProvider.workers.length.toString(),
                      'Total Workers',
                      Colors.white,
                    ),
                    _buildStatItem(
                      workerProvider.activeWorkersCount.toString(),
                      'Active',
                      const Color(0xFF00FF41),
                    ),
                    _buildStatItem(
                      workerProvider.alertsCount.toString(),
                      'Alerts',
                      Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredWorkers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No workers added yet'
                                  : 'No workers found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first worker',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredWorkers.length,
                        itemBuilder: (context, index) {
                          final worker = filteredWorkers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildWorkerDetailCard(
                              workerId: worker.id,
                              name: worker.name,
                              id: worker.id,
                              vestId: worker.vestId,
                              shift: worker.shift,
                              department: worker.department,
                              location: worker.location,
                              assigned: worker.assigned,
                              status: worker.status,
                              statusColor: worker.statusColor,
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

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildWorkerDetailCard({
    required String workerId,
    required String name,
    required String id,
    required String vestId,
    required String shift,
    required String department,
    required String location,
    required String assigned,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    status == 'ONLINE'
                        ? Icons.wifi
                        : status == 'ALERT'
                        ? Icons.warning
                        : Icons.wifi_off,
                    color: status == 'OFFLINE'
                        ? Colors.grey[600]
                        : (status == 'ALERT'
                              ? Colors.red
                              : const Color(0xFF00FF41)),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: $id • Vest: $vestId',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Shift:', shift),
          const SizedBox(height: 8),
          _buildDetailRow('Department:', department),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Assigned:', assigned),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A4A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Track'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
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
                      context.read<WorkerProvider>().removeWorker(workerId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Worker deleted successfully'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
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

// ==================== 3. SAFETY ALERTS CONTENT ====================
class SafetyAlertsContent extends StatefulWidget {
  const SafetyAlertsContent({Key? key}) : super(key: key);

  @override
  State<SafetyAlertsContent> createState() => _SafetyAlertsContentState();
}

class _SafetyAlertsContentState extends State<SafetyAlertsContent> {
  String _selectedFilter = 'All';

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
                const Text(
                  'Safety Alerts',
                  style: TextStyle(
                    fontSize: 24,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('1', 'Active', Colors.red),
                _buildStatItem('2', 'Critical', Colors.orange),
                _buildStatItem('1', 'Resolved', const Color(0xFF00FF41)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterTab('All'),
                const SizedBox(width: 12),
                _buildFilterTab('Active'),
                const SizedBox(width: 12),
                _buildFilterTab('Critical'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAlertCard(
                  type: 'BIOMETRIC ALERT',
                  title:
                      'Critical SpO₂ levels detected - immediate attention required',
                  workerName: 'Sarah Chen',
                  vestId: 'VEST-002',
                  location: 'Tunnel B-1',
                  time: '2 min ago',
                  status: 'ACTIVE',
                  statusColor: Colors.red,
                  cardColor: Colors.red,
                  icon: Icons.favorite,
                  vitals: '95 BPM    99.2°F    89% SpO₂',
                  showAcknowledge: true,
                  showResolve: true,
                ),
                const SizedBox(height: 16),
                _buildAlertCard(
                  type: 'PANIC ALERT',
                  title: 'Emergency panic button activated',
                  workerName: 'Marcus Johnson',
                  vestId: 'VEST-001',
                  location: 'Tunnel A-2',
                  time: '5 min ago',
                  status: 'ACKNOWLEDGED',
                  statusColor: Colors.orange,
                  cardColor: Colors.red,
                  icon: Icons.pan_tool,
                  showResolve: true,
                ),
                const SizedBox(height: 16),
                _buildAlertCard(
                  type: 'FALL ALERT',
                  title:
                      'Fall detection triggered - worker may need assistance',
                  workerName: 'David Rodriguez',
                  vestId: 'VEST-003',
                  location: 'Central Hub',
                  time: '12 min ago',
                  status: 'RESOLVED',
                  statusColor: const Color(0xFF00FF41),
                  cardColor: Colors.orange,
                  icon: Icons.trending_down,
                ),
                const SizedBox(height: 16),
                _buildAlertCard(
                  type: 'ENVIRONMENTAL ALERT',
                  title: 'High temperature zone detected',
                  workerName: 'Emily Watson',
                  vestId: 'VEST-004',
                  location: 'Tunnel C-3',
                  time: '18 min ago',
                  status: 'ACKNOWLEDGED',
                  statusColor: Colors.orange,
                  cardColor: Colors.orange[800]!,
                  icon: Icons.thermostat,
                  vitals: '104.5°F',
                  showResolve: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label) {
    bool isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2A4A5F)
                : const Color(0xFF1A3344),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String type,
    required String title,
    required String workerName,
    required String vestId,
    required String location,
    required String time,
    required String status,
    required Color statusColor,
    required Color cardColor,
    required IconData icon,
    String? vitals,
    bool showAcknowledge = false,
    bool showResolve = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == 'ACTIVE'
                      ? Colors.white
                      : status == 'ACKNOWLEDGED'
                      ? Colors.orange[300]
                      : const Color(0xFF00FF41),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '$workerName ($vestId)',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          if (vitals != null) ...[
            const SizedBox(height: 8),
            Text(
              vitals,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (showAcknowledge)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Acknowledge'),
                  ),
                ),
              if (showAcknowledge && showResolve) const SizedBox(width: 8),
              if (showResolve)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF41),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== 4. COMMUNICATION HUB CONTENT ====================
class CommunicationHubContent extends StatefulWidget {
  const CommunicationHubContent({Key? key}) : super(key: key);

  @override
  State<CommunicationHubContent> createState() =>
      _CommunicationHubContentState();
}

class _CommunicationHubContentState extends State<CommunicationHubContent> {
  String _selectedTab = 'Messaging'; // 'Messaging' or 'Emergency'
  final TextEditingController _messageController = TextEditingController();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _translatedMessage = "";
  @override
  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _messageController.dispose();
    super.dispose();
  }

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _sendAudioToBackend(String filePath) async {
    final bytes = await File(filePath).readAsBytes();

    // 1️⃣ Speech-to-Text (Azure STT)
    final sttResponse = await http.post(
      Uri.parse(
        "https://evok-functions-fre8aaf4drg2dke2.centralindia-01.azurewebsites.net/api/stt_api",
      ),
      headers: {"Content-Type": "audio/wav"},
      body: bytes,
    );

    if (sttResponse.statusCode != 200) {
      debugPrint("STT failed");
      return;
    }

    final String recognizedText = sttResponse.body;

    // 2️⃣ Translate (Azure Translator)
    final translateResponse = await http.post(
      Uri.parse(
        "https://evok-functions-fre8aaf4drg2dke2.centralindia-01.azurewebsites.net/api/translate_api",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "text": recognizedText,
        "target_lang": "hi", // Hindi
      }),
    );

    if (translateResponse.statusCode != 200) {
      debugPrint("Translation failed");
      return;
    }

    final String translatedText = translateResponse.body;

    // 3️⃣ Update UI (ONLY state update here)
    setState(() {
      _translatedMessage = translatedText;
    });
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
                const Text(
                  'Communication Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Multilingual Safety Communications',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
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

  Widget _buildMessagingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.warning, size: 20),
                  label: const Text('Emergency Broadcast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.people, size: 20),
                  label: const Text('All-Worker Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF41),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Send Message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recipient',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRecipientChip('All Workers', true),
                const SizedBox(width: 8),
                _buildRecipientChip('Marcus Johnson', false),
                const SizedBox(width: 8),
                _buildRecipientChip('Sarah', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Language',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3344),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.language, color: Color(0xFF00FF41), size: 20),
                SizedBox(width: 8),
                Text('🇺🇸', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'English',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) async {
                    setState(() => _isRecording = true);

                    final dir = await getTemporaryDirectory();
                    final path = '${dir.path}/voice.wav';

                    await _recorder.startRecorder(
                      toFile: path,
                      codec: Codec.pcm16WAV,
                      sampleRate: 16000,
                      numChannels: 1,
                    );
                  },
                  onTapUp: (_) async {
                    setState(() => _isRecording = false);

                    final path = await _recorder.stopRecorder();
                    if (path != null) {
                      await _sendAudioToBackend(path);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isRecording ? 120 : 100,
                    height: _isRecording ? 120 : 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A3344),
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 25,
                                spreadRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Color(0xFF00FF41),
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Hold to record voice message',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3344),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF00FF41),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildMessageCard(
            type: 'ALERT',
            message:
                'Emergency evacuation protocol activated. Proceed to nearest exit immediately.',
            recipient: 'All Workers',
            time: '2 min ago',
            typeColor: Colors.red,
            statusColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildMessageCard(
            type: 'VOICE',
            message: 'Please report to safety station for medical checkup.',
            recipient: 'Sarah Chen',
            time: '5 min ago',
            typeColor: Colors.blue,
            statusColor: Colors.orange,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmergencyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quick access to emergency services',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyCard('🚒', 'Fire Department', '911'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyCard('👮', 'Police Emergency', '911'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyCard('🚑', 'Medical Emergency', '911'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyCard(
                  '🏢',
                  'Mine Safety Office',
                  '+1-555-SAFETY',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildEmergencyCard(
              '🏢',
              'Site Manager',
              '+1-555-MANAGER',
              isFullWidth: true,
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Emergency Protocols',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            icon: Icons.campaign,
            iconColor: Colors.red,
            title: 'Site-Wide Evacuation',
            subtitle: 'Activate immediate evacuation alert',
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            icon: Icons.medical_services,
            iconColor: Colors.orange,
            title: 'Medical Emergency Response',
            subtitle: 'Coordinate medical assistance',
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            icon: Icons.lock,
            iconColor: Colors.blue,
            title: 'Safety Lockdown',
            subtitle: 'Secure area and halt operations',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecipientChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00FF41) : const Color(0xFF1A3344),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 16,
            color: isSelected ? Colors.black : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required String type,
    required String message,
    required String recipient,
    required String time,
    required Color typeColor,
    required Color statusColor,
  }) {
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
              Row(
                children: [
                  Icon(
                    type == 'ALERT'
                        ? Icons.warning
                        : type == 'VOICE'
                        ? Icons.volume_up
                        : Icons.message,
                    color: typeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                recipient,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00FF41),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(
    String emoji,
    String title,
    String number, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(10),
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
  }) {
    return Container(
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
        ],
      ),
    );
  }
}

// ==================== 5. ANALYTICS DASHBOARD CONTENT ====================
class AnalyticsDashboardContent extends StatefulWidget {
  const AnalyticsDashboardContent({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardContent> createState() =>
      _AnalyticsDashboardContentState();
}

class _AnalyticsDashboardContentState extends State<AnalyticsDashboardContent> {
  String _selectedPeriod = 'This Week';

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
                const Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Worker Health & Safety Insights',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildPeriodTab('This Week'),
                const SizedBox(width: 8),
                _buildPeriodTab('This Month'),
                const SizedBox(width: 8),
                _buildPeriodTab('This Quarter'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.warning,
                          value: '0',
                          label: 'Safety Incidents',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time,
                          value: '290',
                          label: 'Work Hours',
                          color: const Color(0xFF00FF41),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite,
                          value: '76',
                          label: 'Avg Heart Rate',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.stars,
                          value: '2',
                          label: 'Alerts Resolved',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biometric Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF41),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.download, size: 14, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'Export',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBiometricCard(
                          icon: Icons.favorite,
                          value: '76 BPM',
                          label: 'Heart Rate',
                          subLabel: 'Avg',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBiometricCard(
                          icon: Icons.thermostat,
                          value: '98.4°F',
                          label: 'Temperature',
                          subLabel: 'Avg',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBiometricCard(
                          icon: Icons.air,
                          value: '98%',
                          label: 'SpO₂',
                          subLabel: 'Avg',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Worker Health Scores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Individual health monitoring and trends',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHealthScoreCard(
                    name: 'Marcus Johnson',
                    score: 92,
                    status: 'Excellent',
                    statusColor: const Color(0xFF00FF41),
                    progress: 0.92,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthScoreCard(
                    name: 'Sarah Chen',
                    score: 78,
                    status: 'Good',
                    statusColor: Colors.orange,
                    progress: 0.78,
                    warning: 'Low SpO₂, Elevated heart rate',
                  ),
                  const SizedBox(height: 12),
                  _buildHealthScoreCard(
                    name: 'David Rodriguez',
                    score: 88,
                    status: 'Good',
                    statusColor: Colors.orange,
                    progress: 0.88,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthScoreCard(
                    name: 'Emily Watson',
                    score: 85,
                    status: 'Good',
                    statusColor: const Color(0xFF00FF41),
                    progress: 0.85,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Incident Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2F3F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIncidentStat(
                          '12',
                          'Total Incidents',
                          'This Month',
                          Colors.white,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildIncidentStat(
                          '-25%',
                          'Month-over-Month',
                          'Improvement',
                          const Color(0xFF00FF41),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildIncidentStat(
                          '2.1',
                          'Incidents per',
                          'Milestone',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Incident Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIncidentTypeBar(
                    'Biometric Alerts (7)',
                    Colors.red,
                    0.7,
                  ),
                  const SizedBox(height: 8),
                  _buildIncidentTypeBar(
                    'Fall Detection (3)',
                    Colors.orange,
                    0.3,
                  ),
                  const SizedBox(height: 8),
                  _buildIncidentTypeBar('Panic Button (2)', Colors.yellow, 0.2),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historical Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.filter_list,
                        color: Colors.white.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2F3F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildBarChart('Week 1', 2, 6, Colors.red),
                              _buildBarChart('Week 2', 1, 6, Colors.red),
                              _buildBarChart('Week 3', 5, 6, Colors.red),
                              _buildBarChart('Week 4', 0, 6, Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Incidents per week',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label) {
    bool isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A3344)
                : const Color(0xFF0F1E2A),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFF00FF41), width: 2)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF00FF41) : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard({
    required IconData icon,
    required String value,
    required String label,
    required String subLabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard({
    required String name,
    required int score,
    required String status,
    required Color statusColor,
    required double progress,
    String? warning,
  }) {
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
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.trending_up, color: statusColor, size: 16),
                ],
              ),
            ],
          ),
          if (warning != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 12),
                const SizedBox(width: 4),
                Text(
                  warning,
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentStat(
    String value,
    String label,
    String sublabel,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
        ),
        Text(
          sublabel,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildIncidentTypeBar(String label, Color color, double value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String label, int value, int maxValue, Color color) {
    double heightRatio = value / maxValue;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 80 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
        ),
      ],
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
