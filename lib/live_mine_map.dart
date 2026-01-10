import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveMineMap extends StatefulWidget {
  const LiveMineMap({super.key});

  @override
  State<LiveMineMap> createState() => _LiveMineMapState();
}

class _LiveMineMapState extends State<LiveMineMap> {
  final MapController _mapController = MapController();

  final DatabaseReference leaderRef =
      FirebaseDatabase.instance.ref("EVOK_System/Live_Data/Leader");

  final DatabaseReference workerRef =
      FirebaseDatabase.instance.ref("EVOK_System/Live_Data/Worker");

  LatLng leaderLocation = const LatLng(0, 0);
  LatLng workerLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();

    leaderRef.onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        leaderLocation = LatLng(
          (data['Lat'] as num).toDouble(),
          (data['Lng'] as num).toDouble(),
        );
      });

      _moveMap();
    });

    workerRef.onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        workerLocation = LatLng(
          (data['Lat'] as num).toDouble(),
          (data['Lng'] as num).toDouble(),
        );
      });

      _moveMap();
    });
  }

  void _moveMap() {
    final centerLat = (leaderLocation.latitude + workerLocation.latitude) / 2;
    final centerLng = (leaderLocation.longitude + workerLocation.longitude) / 2;

    _mapController.move(LatLng(centerLat, centerLng), 17);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: leaderLocation,
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.evok.supervisor',
          ),
          MarkerLayer(
            markers: [
              // Leader marker
              Marker(
                point: leaderLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 36,
                ),
              ),

              // Worker marker
              Marker(
                point: workerLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.green,
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
