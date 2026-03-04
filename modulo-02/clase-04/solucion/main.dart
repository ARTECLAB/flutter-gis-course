// =============================================================
// ✅ SOLUCIÓN — Clase 04: GeoCollect con Capas, Popups, Geometrías y Eventos
// =============================================================
// Módulo 2 · Clase 04 — Estado del proyecto al final del Módulo 2
// Curso Flutter GIS — Daniel Quisbert
//
// DEPENDENCIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   flutter_map_marker_popup: ^7.0.0
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

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

/// Proveedores de tiles disponibles
class TileProviders {
  static const String openStreetMap =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String cartoDark =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
  static const String cartoLight =
      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png';
  static const String esriSatelite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String esriTerreno =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
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

  // Centro inicial — La Paz
  final LatLng _centroInicial = const LatLng(-16.5000, -68.1500);

  // Estado del mapa
  double _zoomActual = 14.0;
  LatLng _centroActual = const LatLng(-16.5000, -68.1500);

  // Capa activa
  String _capaActual = TileProviders.openStreetMap;
  String _nombreCapaActual = 'Calles';

  final Map<String, String> _capasDisponibles = {
    'Calles': TileProviders.openStreetMap,
    'Satélite': TileProviders.esriSatelite,
    'Terreno': TileProviders.esriTerreno,
    'Oscuro': TileProviders.cartoDark,
    'Claro': TileProviders.cartoLight,
  };

  // Puntos de interés predefinidos
  final List<Map<String, dynamic>> _puntosInteres = [
    {
      'nombre': 'Plaza Murillo',
      'posicion': const LatLng(-16.4955, -68.1336),
      'icono': Icons.account_balance,
      'color': Colors.red,
      'tipo': 'Plaza',
    },
    {
      'nombre': 'Iglesia San Francisco',
      'posicion': const LatLng(-16.4963, -68.1383),
      'icono': Icons.church,
      'color': Colors.blue,
      'tipo': 'Iglesia',
    },
    {
      'nombre': 'Parque Urbano Central',
      'posicion': const LatLng(-16.5113, -68.1238),
      'icono': Icons.park,
      'color': Colors.green,
      'tipo': 'Parque',
    },
    {
      'nombre': 'Mercado Lanza',
      'posicion': const LatLng(-16.4978, -68.1369),
      'icono': Icons.store,
      'color': Colors.orange,
      'tipo': 'Mercado',
    },
  ];

  // Marcadores creados por el usuario (longPress)
  List<LatLng> _marcadoresUsuario = [];

  // Ruta de ejemplo (polilínea)
  final List<LatLng> _rutaEjemplo = [
    const LatLng(-16.4955, -68.1336),
    const LatLng(-16.4963, -68.1383),
    const LatLng(-16.4978, -68.1369),
    const LatLng(-16.5020, -68.1350),
  ];

  // Zona de estudio (polígono)
  final List<LatLng> _zonaEstudio = [
    const LatLng(-16.490, -68.140),
    const LatLng(-16.490, -68.125),
    const LatLng(-16.505, -68.125),
    const LatLng(-16.505, -68.140),
  ];

  void _cambiarCapa(String nombre, String url) {
    setState(() {
      _nombreCapaActual = nombre;
      _capaActual = url;
    });
  }

  void _moverConAnimacion(LatLng destino, double zoomDestino) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destino.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destino.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoomDestino,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });

    controller.forward();
  }

  void _agregarMarcadorUsuario(LatLng posicion) {
    setState(() {
      _marcadoresUsuario.add(posicion);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📌 Punto: ${posicion.latitude.toStringAsFixed(4)}, '
          '${posicion.longitude.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _limpiarMarcadoresUsuario() {
    setState(() {
      _marcadoresUsuario.clear();
    });
  }

  List<Marker> _generarMarcadores() {
    return _puntosInteres.map((punto) {
      return Marker(
        point: punto['posicion'],
        width: 40,
        height: 40,
        child: Icon(punto['icono'], color: punto['color'], size: 36),
      );
    }).toList();
  }

  Widget _construirPopup(Map<String, dynamic> punto) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(punto['icono'], color: punto['color'], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  punto['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tipo: ${punto['tipo']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          Text(
            'Lat: ${punto['posicion'].latitude.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          Text(
            'Lng: ${punto['posicion'].longitude.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoCollect'),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _nombreCapaActual,
            dropdownColor: Colors.teal.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: const SizedBox(),
            icon: const Icon(Icons.layers, color: Colors.white),
            items: _capasDisponibles.keys.map((nombre) {
              return DropdownMenuItem(value: nombre, child: Text(nombre));
            }).toList(),
            onChanged: (nombre) {
              if (nombre != null) {
                _cambiarCapa(nombre, _capasDisponibles[nombre]!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar marcadores',
            onPressed: _limpiarMarcadoresUsuario,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centroInicial,
                initialZoom: 14.0,
                onTap: (_, latLng) {
                  _popupController.hideAllPopups();
                },
                onLongPress: (_, latLng) {
                  _agregarMarcadorUsuario(latLng);
                },
                onPositionChanged: (camera, hasGesture) {
                  setState(() {
                    _zoomActual = camera.zoom;
                    _centroActual = camera.center;
                  });
                },
              ),
              children: [
                // Capa base dinámica
                TileLayer(
                  urlTemplate: _capaActual,
                  userAgentPackageName: 'com.example.geo_collect',
                ),
                // Polígono — zona de estudio
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _zonaEstudio,
                      color: Colors.teal.withOpacity(0.15),
                      borderColor: Colors.teal,
                      borderStrokeWidth: 2.0,
                      isFilled: true,
                    ),
                  ],
                ),
                // Polilínea — ruta de ejemplo
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _rutaEjemplo,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                // Marcadores del usuario (longPress)
                MarkerLayer(
                  markers: _marcadoresUsuario.map((pos) {
                    return Marker(
                      point: pos,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.push_pin,
                          color: Colors.purple, size: 28),
                    );
                  }).toList(),
                ),
                // Marcadores predefinidos con popups
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupController,
                    markers: _generarMarcadores(),
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (context, marker) {
                        final punto = _puntosInteres.firstWhere(
                          (p) => p['posicion'] == marker.point,
                        );
                        return _construirPopup(punto);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Barra de estado inferior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.teal.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📍 ${_centroActual.latitude.toStringAsFixed(4)}, '
                  '${_centroActual.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Text(
                  'Zoom: ${_zoomActual.toStringAsFixed(1)} · $_nombreCapaActual',
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