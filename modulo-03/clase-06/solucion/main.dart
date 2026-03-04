// =============================================================
// ✅ SOLUCIÓN — Clase 06: GeoCollect con GPS, Seguimiento y Distancias
// =============================================================
// Módulo 3 · Clase 06 — Estado del proyecto al final del Módulo 3
// Curso Flutter GIS — Daniel Quisbert
//
// DEPENDENCIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   flutter_map_marker_popup: ^7.0.0
//   geolocator: ^12.0.0
//
// PERMISOS en AndroidManifest.xml:
//   <uses-permission android:name="android.permission.INTERNET"/>
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
// =============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const GeoCollectApp());
}

class GeoCollectApp extends StatelessWidget {
  const GeoCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoCollect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const MapaScreen(),
    );
  }
}

class TileProviders {
  static const String osm =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String satelite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String oscuro =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
}

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  // Estado del mapa
  final LatLng _centroInicial = const LatLng(-16.5000, -68.1500);
  double _zoomActual = 14.0;
  LatLng _centroActual = const LatLng(-16.5000, -68.1500);
  String _capaActual = TileProviders.osm;
  String _nombreCapa = 'Calles';

  final Map<String, String> _capas = {
    'Calles': TileProviders.osm,
    'Satélite': TileProviders.satelite,
    'Oscuro': TileProviders.oscuro,
  };

  // GPS
  LatLng? _posicionGPS;
  bool _cargandoGPS = false;
  bool _siguiendo = false;
  StreamSubscription<Position>? _posicionStream;

  // Puntos capturados
  List<Map<String, dynamic>> _puntosCapturados = [];

  // ── Permisos ──
  Future<bool> _verificarPermisos() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Activa el GPS de tu teléfono')),
        );
      }
      return false;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Permiso de ubicación denegado')),
          );
        }
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Activa el permiso en Configuración → Permisos'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  // ── Obtener posición actual (una vez) ──
  Future<void> _obtenerUbicacion() async {
    bool listo = await _verificarPermisos();
    if (!listo) return;

    setState(() => _cargandoGPS = true);

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _posicionGPS = LatLng(pos.latitude, pos.longitude);
        _cargandoGPS = false;
      });
      _mapController.move(_posicionGPS!, 16.0);
    } catch (e) {
      setState(() => _cargandoGPS = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error GPS: $e')),
        );
      }
    }
  }

  // ── Seguimiento en tiempo real ──
  void _toggleSeguimiento() async {
    if (_siguiendo) {
      _posicionStream?.cancel();
      setState(() => _siguiendo = false);
    } else {
      bool listo = await _verificarPermisos();
      if (!listo) return;

      setState(() => _siguiendo = true);

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _posicionStream = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen((Position pos) {
        setState(() {
          _posicionGPS = LatLng(pos.latitude, pos.longitude);
        });
      });
    }
  }

  // ── Capturar punto GPS ──
  void _capturarPunto() {
    if (_posicionGPS == null) return;

    final punto = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'latitud': _posicionGPS!.latitude,
      'longitud': _posicionGPS!.longitude,
      'posicion': LatLng(_posicionGPS!.latitude, _posicionGPS!.longitude),
      'fecha': DateTime.now().toIso8601String(),
    };

    setState(() {
      _puntosCapturados.add(punto);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Punto #${_puntosCapturados.length}: '
          '${punto['latitud'].toStringAsFixed(4)}, '
          '${punto['longitud'].toStringAsFixed(4)}',
        ),
      ),
    );
  }

  // ── Calcular distancia total ──
  double _distanciaTotal() {
    if (_puntosCapturados.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < _puntosCapturados.length; i++) {
      total += Geolocator.distanceBetween(
        _puntosCapturados[i - 1]['latitud'],
        _puntosCapturados[i - 1]['longitud'],
        _puntosCapturados[i]['latitud'],
        _puntosCapturados[i]['longitud'],
      );
    }
    return total;
  }

  String _formatearDistancia(double metros) {
    if (metros < 1000) return '${metros.toStringAsFixed(0)} m';
    return '${(metros / 1000).toStringAsFixed(2)} km';
  }

  @override
  void dispose() {
    _posicionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoCollect'),
        centerTitle: true,
        actions: [
          // Selector de capas
          DropdownButton<String>(
            value: _nombreCapa,
            dropdownColor: Colors.teal.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: const SizedBox(),
            icon: const Icon(Icons.layers, color: Colors.white),
            items: _capas.keys.map((n) {
              return DropdownMenuItem(value: n, child: Text(n));
            }).toList(),
            onChanged: (n) {
              if (n != null) {
                setState(() { _nombreCapa = n; _capaActual = _capas[n]!; });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _centroInicial,
                    initialZoom: 14.0,
                    onPositionChanged: (camera, _) {
                      setState(() {
                        _zoomActual = camera.zoom;
                        _centroActual = camera.center;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _capaActual,
                      userAgentPackageName: 'com.example.geo_collect',
                    ),
                    // Traza del recorrido
                    if (_puntosCapturados.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _puntosCapturados
                                .map<LatLng>((p) => p['posicion'])
                                .toList(),
                            color: Colors.green,
                            strokeWidth: 3.0,
                          ),
                        ],
                      ),
                    // Puntos capturados
                    MarkerLayer(
                      markers: _puntosCapturados.map((p) {
                        return Marker(
                          point: p['posicion'],
                          width: 24,
                          height: 24,
                          child: const Icon(Icons.circle,
                              color: Colors.green, size: 14),
                        );
                      }).toList(),
                    ),
                    // Posición GPS del usuario
                    if (_posicionGPS != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _posicionGPS!,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.my_location,
                                    color: Colors.blue, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Botones laterales
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mi ubicación
                      FloatingActionButton.small(
                        heroTag: 'gps',
                        onPressed: _cargandoGPS ? null : _obtenerUbicacion,
                        child: _cargandoGPS
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      // Toggle seguimiento
                      FloatingActionButton.small(
                        heroTag: 'track',
                        backgroundColor:
                            _siguiendo ? Colors.red : Colors.teal,
                        onPressed: _toggleSeguimiento,
                        child: Icon(
                            _siguiendo ? Icons.stop : Icons.play_arrow),
                      ),
                      const SizedBox(height: 8),
                      // Capturar punto
                      FloatingActionButton(
                        heroTag: 'capture',
                        onPressed:
                            _posicionGPS != null ? _capturarPunto : null,
                        child: const Icon(Icons.add_location_alt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Barra inferior
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.teal.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _posicionGPS != null
                      ? '📍 ${_posicionGPS!.latitude.toStringAsFixed(4)}, '
                        '${_posicionGPS!.longitude.toStringAsFixed(4)}'
                      : '📍 Sin GPS',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Text(
                  'Pts: ${_puntosCapturados.length} · '
                  'Dist: ${_formatearDistancia(_distanciaTotal())} · '
                  'Z: ${_zoomActual.toStringAsFixed(1)}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}