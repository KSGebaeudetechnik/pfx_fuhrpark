import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class KarteScreen extends StatefulWidget {
  const KarteScreen({super.key});

  @override
  State<KarteScreen> createState() => _KarteScreenState();
}

class _KarteScreenState extends State<KarteScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    // Verwende addPostFrameCallback, damit _loadPosition()
    // erst nach dem ersten Build-Frame ausgeführt wird.
    // Dadurch wird sichergestellt, dass der Location-Permission-Dialog
    // sauber angezeigt werden kann (ohne das musste man etwas anklicken damit der Dialog kommt).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosition();
    });
  }

  void _loadPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = currentPosition;
        });
      } catch (e) {
        debugPrint('Fehler beim Abrufen der Position: $e');
      }
    } else {
      debugPrint('Standortberechtigung nicht erteilt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Standort wird geladen...',style: TextStyle(color: Colors.black),),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pfx_fuhrpark',
                ),
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 190,
                      height: 190,
                      child: const Icon(
                        Icons.location_on,
                        size: 50.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}