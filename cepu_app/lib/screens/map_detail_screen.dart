import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cepu_app/models/post.dart';

class MapDetailScreen extends StatefulWidget {
  final Post post;

  const MapDetailScreen({super.key, required this.post});

  @override
  State<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends State<MapDetailScreen> {
  late double lat;
  late double lng;

  @override
  void initState() {
    super.initState();

    // ✅ FIX: handle string → double dengan aman
    lat = double.tryParse(widget.post.latitude ?? '') ?? 0.0;
    lng = double.tryParse(widget.post.longitude ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // ❗ kalau lokasi kosong
    if (lat == 0.0 && lng == 0.0) {
      return Scaffold(
        appBar: AppBar(title: const Text("Map Detail")),
        body: const Center(
          child: Text("Lokasi tidak tersedia"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Detail"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 16,
        ),
        children: [
          // 🗺️ Map layer
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.cepu_app',
          ),

          // 📍 Marker
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}