import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'worker_provider.dart';

class LiveTrackingPage extends StatelessWidget {
  final String vestId;
  final String name;

  const LiveTrackingPage({super.key, required this.vestId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracking $name")),
      body: Consumer<WorkerProvider>(
        builder: (context, provider, _) {
          final worker = provider.workers.firstWhere((w) => w.vestId == vestId);

          final LatLng pos = LatLng(worker.latitude, worker.longitude);

          return FlutterMap(
            options: MapOptions(
              initialCenter: pos,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 36,
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
}
