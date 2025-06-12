import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../authentication/data/auth_repository.dart';
import '../../home/data/fahrzeug_provider.dart';
import '../../home/objects/fahrzeug.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class KarteScreen extends ConsumerStatefulWidget {
  final Fahrzeug? initialFahrzeug;

  const KarteScreen({super.key, this.initialFahrzeug});

  @override
  ConsumerState<KarteScreen> createState() => _KarteScreenState();
}

class _KarteScreenState extends ConsumerState<KarteScreen> {
  Position? _currentPosition;
  List<Fahrzeug> fahrzeuge = [];
  Timer? _timer;
  final _popupController = PopupController();
  Marker? lastOpenedMarker; // lokal merken
  final _mapController = MapController(); //um auf einzelnes Fahrzeug zu zoomen wenn man von einer Card auf dem HomeScreen kommt
  late LatLng initialCenter;
  double initialZoom = 13.0;
  bool hasZoomedToInitial = false;
  Marker? initialMarkerToShow;

  @override
  void initState() {
    super.initState();

    // wenn ein initiales Fahrzeug übergeben wurde → sofort als Marker anzeigen
    if (widget.initialFahrzeug != null &&
        widget.initialFahrzeug!.latitude != null &&
        widget.initialFahrzeug!.longitude != null) {
      initialCenter = LatLng(
        widget.initialFahrzeug!.latitude!,
        widget.initialFahrzeug!.longitude!,
      );
      initialZoom = 16.0;

      // direkt anzeigen, noch bevor _syncFahrzeuge läuft
      fahrzeuge = [widget.initialFahrzeug!];
    } else {
      // dummy-Koordinaten (wird später ersetzt durch echte Position)
      initialCenter = LatLng(0, 0);
    }

    // initialisierung der Karte verzögert starten
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
  }

  Future<void> _initializeMap() async {
    try {
      await FMTCObjectBoxBackend().initialise();

      await _loadPosition(); // setzt _currentPosition
      await _syncFahrzeuge();
      _startTimer();

      // FOKUS AUF GEWÄHLTES FAHRZEUG
      if (widget.initialFahrzeug != null &&
          widget.initialFahrzeug!.latitude != null &&
          widget.initialFahrzeug!.longitude != null) {
        _mapController.move(
          LatLng(
            widget.initialFahrzeug!.latitude!,
            widget.initialFahrzeug!.longitude!,
          ),
          16.0,
        );
      } else if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          13.0,
        );
      }
    } catch (e) {
      debugPrint('Initialisierung fehlgeschlagen: $e');
    }
  }

  Future<void> _loadPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout bei Standortermittlung'),
        );

        setState(() {
          _currentPosition = currentPosition;
          if (widget.initialFahrzeug == null) {
            initialCenter = LatLng(currentPosition.latitude, currentPosition.longitude);
          }
        });
      } else {
        debugPrint('Standortberechtigung nicht erteilt.');
      }
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Position: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer =
        Timer.periodic(const Duration(seconds: 200), (_) => _syncFahrzeuge());
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
    final bool canRenderMap =
        _currentPosition != null ||
            (widget.initialFahrzeug?.latitude != null &&
                widget.initialFahrzeug?.longitude != null);

    if (!canRenderMap) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Standort wird geladen...', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialMarkerToShow != null && lastOpenedMarker == null) {
        _popupController.showPopupsOnlyFor([initialMarkerToShow!]);
        lastOpenedMarker = initialMarkerToShow;
      }
    });

    return Scaffold(
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter.latitude == 0 && initialCenter.longitude == 0
                ? const LatLng(51.0, 10.0) // Zentrum Deutschland
                : initialCenter,
            initialZoom: initialZoom,
          ),
          children: [
            // Kachel-Layer
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.mapfinder',
            ),

            // Eigene Position
            MarkerLayer(
              markers: _currentPosition != null
                  ? [
                Marker(
                  point: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  width: 50,
                  height: 50,
                  rotate: true,
                  child: const Icon(
                    Icons.location_on,
                    size: 40.0,
                    color: Colors.blue,
                  ),
                ),
              ]
                  : [],
            ),

            // Fahrzeug-Marker + Cluster + Popups
            PopupScope(
              popupController: _popupController,
              child: MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  zoomToBoundsOnClick: false,
                  centerMarkerOnClick: false,

                  popupOptions: PopupOptions(
                    popupController: _popupController,
                    popupBuilder: (context, marker) {
                      final fzg = fahrzeuge.firstWhere(
                            (f) =>
                        f.latitude == marker.point.latitude &&
                            f.longitude == marker.point.longitude,
                        orElse: () =>
                            Fahrzeug(name: "Unbekannt", gpsTimeString: "-"),
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
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Letzte Aktualisierung:",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    fzg.gpsTimeString ?? "-",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  builder: (context, markers) => Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  markers: fahrzeuge
                      .where((f) => f.latitude != null && f.longitude != null)
                      .map((f) {
                    final markerPoint = LatLng(f.latitude!, f.longitude!);
                    final markerKey = ValueKey(f.fahrzeugId);

                    late final Marker marker;

                    marker = Marker(
                      key: markerKey,
                      rotate: true,
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
                        child: _buildFahrzeugIcon(f),
                      ),
                    );

                    // Wenn initialFahrzeug gesetzt ist und Koordinaten übereinstimmen → merken
                    if (widget.initialFahrzeug != null &&
                        f.latitude == widget.initialFahrzeug!.latitude &&
                        f.longitude == widget.initialFahrzeug!.longitude) {
                      initialMarkerToShow = marker;
                    }

                    return marker;
                  }).toList(),
                ),
              ),
            ),
          ],
        )
    );
  }

  /// Hilfsmethoden

  bool isOlderThan2Days(String timeString) {
    final format = DateFormat('dd.MM.yy HH:mm:ss');
    try {
      final dateTime = format.parse(timeString);
      return DateTime.now().difference(dateTime).inDays > 2;
    } catch (e) {
      return false;
    }
  }

  Widget _buildFahrzeugIcon(Fahrzeug f) {
    final isOld = f.gpsTimeString == null || f.gpsTimeString!.isEmpty || isOlderThan2Days(f.gpsTimeString!);
    final isActive = f.ignition == true && !isOld;

    final iconPath = (f.typNummer == "2" || f.typNummer == "1" || f.typNummer == "4" || f.typNummer == null)
        ? 'assets/images/pkw_icon.png'
        : (f.typNummer == "3"
        ? 'assets/images/lkw_icon.png'
        : 'assets/images/anhaenger_icon.png');

    Widget image = Image.asset(iconPath);

    if (isActive) {
      // Fahrzeug fährt → grüner Glow
      image = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(255),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: image,
      );
    } else if (isOld) {
      // Fahrzeugdaten alt → Graufilter
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: image,
      );
    }

    return image;
  }
}
