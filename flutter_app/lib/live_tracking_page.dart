import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'worker_provider.dart';

class LiveTrackingPage extends StatefulWidget {
  final String vestId;
  final String name;

  const LiveTrackingPage({
    super.key,
    required this.vestId,
    required this.name,
  });

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final MapController _mapController = MapController();

  LatLng? supervisorPos;
  List<LatLng> routePoints = [];

  StreamSubscription<Position>? _positionStream;
  LatLng? _lastRoutedSupervisorPos;

  @override
  void initState() {
    super.initState();
    _startSupervisorTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ================= SUPERVISOR LIVE GPS =================
  void _startSupervisorTracking() async {
    await Geolocator.requestPermission();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    ).listen((position) async {
      final newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        supervisorPos = newPos;

        if (routePoints.isNotEmpty) {
          routePoints = _trimRoute(routePoints, newPos);
        }
      });

      // Auto-recenter map
      _mapController.move(newPos, _mapController.camera.zoom);

      // Re-route only if moved significantly
      if (_lastRoutedSupervisorPos == null ||
          const Distance().as(
                LengthUnit.Meter,
                _lastRoutedSupervisorPos!,
                newPos,
              ) >
              20) {
        _lastRoutedSupervisorPos = newPos;

        final worker = context
            .read<WorkerProvider>()
            .workers
            .firstWhere((w) => w.vestId == widget.vestId);

        if (worker.latitude != 0 && worker.longitude != 0) {
          final points = await _fetchRoute(
            newPos,
            LatLng(worker.latitude, worker.longitude),
          );

          if (points.isNotEmpty && mounted) {
            setState(() {
              routePoints = points;
            });
          }
        }
      }
    });
  }

  // ================= ROUTE FETCH (ORS WALKING) =================
  Future<List<LatLng>> _fetchRoute(LatLng start, LatLng end) async {
    const apiKey =
        "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjJlNDRlMDk4YWMwMzRkMmNiY2IzZjNiZTI0ZDc3MTg4IiwiaCI6Im11cm11cjY0In0=";

    final url = "https://api.openrouteservice.org/v2/directions/foot-walking"
        "?start=${start.longitude},${start.latitude}"
        "&end=${end.longitude},${end.latitude}"
        "&radiuses=2000,2000";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": apiKey,
        "Accept": "application/geo+json;charset=UTF-8",
      },
    );

    if (response.statusCode != 200) {
      debugPrint("ORS ERROR: ${response.body}");
      return [];
    }

    final data = jsonDecode(response.body);

    if (data == null || data['features'] == null || data['features'].isEmpty) {
      return [];
    }

    final coords = data['features'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracking ${widget.name}")),
      body: Consumer<WorkerProvider>(
        builder: (context, provider, _) {
          final worker =
              provider.workers.firstWhere((w) => w.vestId == widget.vestId);

          final workerPos = LatLng(worker.latitude, worker.longitude);

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: workerPos,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.evok_app',
              ),

              // ROUTE
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),

              // MARKERS
              MarkerLayer(
                markers: [
                  // Supervisor
                  if (supervisorPos != null)
                    Marker(
                      point: supervisorPos!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Color.fromARGB(255, 243, 33, 33),
                        size: 40,
                      ),
                    ),

                  // Worker
                  Marker(
                    point: workerPos,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color.fromARGB(255, 14, 103, 27),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<LatLng> _trimRoute(
    List<LatLng> route,
    LatLng currentPos,
  ) {
    if (route.isEmpty) return route;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < route.length; i++) {
      final d = const Distance().as(
        LengthUnit.Meter,
        currentPos,
        route[i],
      );

      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    return route.sublist(closestIndex);
  }
}
