import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../authentication/data/auth_repository.dart';
import '../../home/data/fahrzeug_provider.dart';
import '../../home/objects/fahrzeug.dart';

class KarteScreen extends ConsumerStatefulWidget {
  const KarteScreen({super.key});

  @override
  ConsumerState<KarteScreen> createState() => _KarteScreenState();
}

class _KarteScreenState extends ConsumerState<KarteScreen> {
  Position? _currentPosition;
  List<Fahrzeug> fahrzeuge = [];
  Timer? _timer;
  final _popupController = PopupController();
  Marker? lastOpenedMarker; // lokal merken

  @override
  void initState() {
    super.initState();
    // Verwende addPostFrameCallback, damit _loadPosition()
    // erst nach dem ersten Build-Frame ausgeführt wird.
    // Dadurch wird sichergestellt, dass der Location-Permission-Dialog
    // sauber angezeigt werden kann (ohne das musste man etwas anklicken damit der Dialog kommt).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadPosition();

      await _syncFahrzeuge(); // initialer fetch
      _startTimer();
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer =
        Timer.periodic(const Duration(seconds: 3), (_) => _syncFahrzeuge());
  }

  Future<void> _syncFahrzeuge() async {
    try {
      final user = await ref.read(userProvider.future);
      final repo = ref.read(fahrzeugRepositoryProvider);
      final fetched =
          await repo.fetchAndStoreFahrzeuge(user.personalnummer.toString());
      setState(() => fahrzeuge = fetched);
    } catch (e) {
      debugPrint("Fehler beim Synchronisieren: $e → fallback auf lokale Daten");
      final repo = ref.read(fahrzeugRepositoryProvider);
      setState(() => fahrzeuge = repo.getLocalFahrzeuge());
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
                  Text('Standort wird geladen...',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pfx_fuhrpark',
                ),

                // Eigene Position
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      width: 50,
                      height: 50,
                      rotate: true,
                      child: const Icon(Icons.location_on,
                          size: 40.0, color: Colors.blue),
                    ),
                  ],
                ),

                // Fahrzeuge
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupController,

                    markers: fahrzeuge
                        .where((f) => f.latitude != null && f.longitude != null)
                        .map((f) {
                      final markerPoint = LatLng(f.latitude!, f.longitude!);
                      final markerKey = ValueKey(f.fahrzeugId);

                      // Marker muss vorher definiert werden
                      late Marker marker;

                      marker = Marker(
                        key: markerKey,
                        point: markerPoint,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            if (lastOpenedMarker?.key == marker.key) {
                              _popupController.hideAllPopups();
                              lastOpenedMarker = null;
                            } else {
                              _popupController.showPopupsOnlyFor([marker]);
                              lastOpenedMarker = marker;
                            }
                          },
                          child: Icon(
                            Icons.directions_car_filled,
                            color: f.ignition == true ? Colors.green : Colors.red,
                            size: 30,
                          ),
                        ),
                      );

                      return marker;
                    })
                        .toList(),

                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        final fzg = fahrzeuge.firstWhere(
                              (f) =>
                          f.latitude == marker.point.latitude &&
                              f.longitude == marker.point.longitude,
                          orElse: () => Fahrzeug(name: "Unbekannt", gpsTimeString: "-"),
                        );

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          builder: (ctx, scale, child) => Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: scale.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => _popupController.hideAllPopups(),
                            child: Card(
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fzg.name ?? "Fahrzeug",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Letzte Aktualisierung:",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      fzg.gpsTimeString ?? "-",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
