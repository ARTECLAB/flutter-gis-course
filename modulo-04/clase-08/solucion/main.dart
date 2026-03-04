// =============================================================
// ✅ SOLUCIÓN — Clase 08: GeoCollect con WMS, CQL y GetFeatureInfo
// =============================================================
// Módulo 4 · Clase 08 — Estado del proyecto al final del Módulo 4
// Curso Flutter GIS — Daniel Quisbert
//
// DEPENDENCIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   flutter_map_marker_popup: ^7.0.0
//   geolocator: ^12.0.0
//   http: ^1.2.0
// =============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Mapa ──
  final LatLng _centroInicial = const LatLng(-16.5000, -68.1500);
  double _zoomActual = 14.0;
  LatLng _centroActual = const LatLng(-16.5, -68.15);
  String _capaBase = TileProviders.osm;
  String _nombreCapaBase = 'Calles';
  final Map<String, String> _capasBase = {
    'Calles': TileProviders.osm,
    'Satélite': TileProviders.satelite,
    'Oscuro': TileProviders.oscuro,
  };

  // ── GPS ──
  LatLng? _posicionGPS;
  bool _siguiendo = false;
  StreamSubscription<Position>? _posStream;

  // ── Puntos capturados ──
  List<Map<String, dynamic>> _puntos = [];

  // ── WMS ──
  // IMPORTANTE: Reemplaza esta URL con tu GeoServer real
  final String _geoserverBase = 'https://tu-servidor.com/geoserver/wms?';
  final String _workspace = 'tu_workspace';

  Map<String, bool> _capasWMS = {
    'departamentos': true,
    'rios': false,
    'carreteras': false,
    'municipios': false,
  };

  // Filtro CQL activo
  String _filtroCQL = '';

  // ── Permisos GPS ──
  Future<bool> _verificarPermisos() async {
    bool gps = await Geolocator.isLocationServiceEnabled();
    if (!gps) return false;
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return false;
    }
    if (p == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> _obtenerUbicacion() async {
    bool ok = await _verificarPermisos();
    if (!ok) return;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() => _posicionGPS = LatLng(pos.latitude, pos.longitude));
    _mapController.move(_posicionGPS!, 16.0);
  }

  void _toggleSeguimiento() async {
    if (_siguiendo) {
      _posStream?.cancel();
      setState(() => _siguiendo = false);
    } else {
      bool ok = await _verificarPermisos();
      if (!ok) return;
      setState(() => _siguiendo = true);
      _posStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        setState(
            () => _posicionGPS = LatLng(pos.latitude, pos.longitude));
      });
    }
  }

  void _capturarPunto() {
    if (_posicionGPS == null) return;
    setState(() {
      _puntos.add({
        'lat': _posicionGPS!.latitude,
        'lng': _posicionGPS!.longitude,
        'pos': LatLng(_posicionGPS!.latitude, _posicionGPS!.longitude),
        'fecha': DateTime.now().toIso8601String(),
      });
    });
  }

  // ── WMS GetFeatureInfo ──
  Future<void> _consultarWMS(LatLng punto) async {
    final bounds = _mapController.camera.visibleBounds;
    final size = MediaQuery.of(context).size;

    final x = ((punto.longitude - bounds.west) /
            (bounds.east - bounds.west) * size.width)
        .round();
    final y = ((bounds.north - punto.latitude) /
            (bounds.north - bounds.south) * size.height)
        .round();

    // Buscar la primera capa WMS activa para consultar
    String? capaConsulta;
    for (var e in _capasWMS.entries) {
      if (e.value) { capaConsulta = e.key; break; }
    }
    if (capaConsulta == null) return;

    final url = Uri.parse(
      '${_geoserverBase}service=WMS&version=1.1.1&request=GetFeatureInfo'
      '&layers=$_workspace:$capaConsulta'
      '&query_layers=$_workspace:$capaConsulta'
      '&info_format=application/json'
      '&x=$x&y=$y'
      '&width=${size.width.round()}&height=${size.height.round()}'
      '&bbox=${bounds.west},${bounds.south},${bounds.east},${bounds.north}'
      '&srs=EPSG:4326',
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final props = data['features'][0]['properties'];
          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Atributos — $capaConsulta'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: props.entries.map<Widget>((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('${e.key}: ${e.value}',
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error GetFeatureInfo: $e');
    }
  }

  // ── Leyenda ──
  String _urlLeyenda(String capa) {
    return '${_geoserverBase}service=WMS&version=1.1.1'
        '&request=GetLegendGraphic'
        '&layer=$_workspace:$capa&format=image/png'
        '&width=20&height=20';
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('GeoCollect'),
        leading: IconButton(
          icon: const Icon(Icons.layers),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          DropdownButton<String>(
            value: _nombreCapaBase,
            dropdownColor: Colors.teal.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: const SizedBox(),
            icon: const Icon(Icons.map, color: Colors.white),
            items: _capasBase.keys.map((n) =>
                DropdownMenuItem(value: n, child: Text(n))).toList(),
            onChanged: (n) {
              if (n != null) {
                setState(() {
                  _nombreCapaBase = n;
                  _capaBase = _capasBase[n]!;
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Drawer — Panel de capas WMS
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Capas WMS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._capasWMS.entries.map((e) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: Text(e.key[0].toUpperCase() + e.key.substring(1)),
                      value: e.value,
                      onChanged: (v) =>
                          setState(() => _capasWMS[e.key] = v),
                    ),
                    if (e.value)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, bottom: 8),
                        child: Image.network(
                          _urlLeyenda(e.key),
                          height: 30,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                  ],
                );
              }).toList(),
              const Divider(),
              const Text('Filtro CQL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: "departamento='La Paz'",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (v) {
                  setState(() => _filtroCQL = v);
                  Navigator.pop(context);
                },
              ),
              if (_filtroCQL.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text('Activo: $_filtroCQL',
                          style: const TextStyle(fontSize: 12))),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => _filtroCQL = ''),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
                    onTap: (_, latLng) => _consultarWMS(latLng),
                    onLongPress: (_, latLng) {},
                    onPositionChanged: (cam, _) {
                      setState(() {
                        _zoomActual = cam.zoom;
                        _centroActual = cam.center;
                      });
                    },
                  ),
                  children: [
                    // Capa base
                    TileLayer(
                      urlTemplate: _capaBase,
                      userAgentPackageName: 'com.example.geo_collect',
                    ),
                    // Capas WMS activas
                    ..._capasWMS.entries
                        .where((e) => e.value)
                        .map((e) {
                      final params = <String, String>{
                        'SRS': 'EPSG:4326',
                      };
                      if (_filtroCQL.isNotEmpty) {
                        params['CQL_FILTER'] = _filtroCQL;
                      }
                      return TileLayer(
                        wmsOptions: WMSTileLayerOptions(
                          baseUrl: _geoserverBase,
                          layers: ['$_workspace:${e.key}'],
                          transparent: true,
                          format: 'image/png',
                          version: '1.1.1',
                          otherParameters: params,
                        ),
                      );
                    }).toList(),
                    // Traza de recorrido
                    if (_puntos.length >= 2)
                      PolylineLayer(polylines: [
                        Polyline(
                          points: _puntos.map<LatLng>((p) => p['pos']).toList(),
                          color: Colors.green,
                          strokeWidth: 3.0,
                        ),
                      ]),
                    // Puntos capturados
                    MarkerLayer(
                      markers: _puntos.map((p) => Marker(
                        point: p['pos'],
                        width: 20, height: 20,
                        child: const Icon(Icons.circle,
                            color: Colors.green, size: 12),
                      )).toList(),
                    ),
                    // GPS
                    if (_posicionGPS != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _posicionGPS!,
                          width: 30, height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.blue, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.my_location,
                                  color: Colors.blue, size: 16),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
                // Botones
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'gps',
                        onPressed: _obtenerUbicacion,
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'track',
                        backgroundColor:
                            _siguiendo ? Colors.red : Colors.teal,
                        onPressed: _toggleSeguimiento,
                        child: Icon(
                            _siguiendo ? Icons.stop : Icons.play_arrow),
                      ),
                      const SizedBox(height: 8),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.teal.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _posicionGPS != null
                      ? '📍 ${_posicionGPS!.latitude.toStringAsFixed(4)}, ${_posicionGPS!.longitude.toStringAsFixed(4)}'
                      : '📍 Sin GPS',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Text(
                  'WMS: ${_capasWMS.values.where((v) => v).length} · '
                  'Pts: ${_puntos.length} · Z: ${_zoomActual.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}