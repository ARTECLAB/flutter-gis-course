// =============================================================
// ✅ SOLUCIÓN — Clase 02: App GeoCollect con Mapa y Marcadores
// =============================================================
// Módulo 1 · Clase 02
// Curso Flutter GIS — Daniel Quisbert
//
// Este es el estado del proyecto geo_collect al finalizar
// la Clase 02 (fin del Módulo 1).
//
// DEPENDENCIAS NECESARIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//
// PERMISO NECESARIO en android/app/src/main/AndroidManifest.xml:
//   <uses-permission android:name="android.permission.INTERNET"/>
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const GeoCollectApp());
}

/// Widget raíz de la aplicación
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

/// Pantalla principal con el mapa
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Controlador del mapa — necesario para moverlo programáticamente
  final MapController _mapController = MapController();

  // Centro inicial — La Paz, Bolivia
  final LatLng _centroInicial = const LatLng(-16.5000, -68.1500);
  final double _zoomInicial = 14.0;

  // Lista de puntos de interés con sus atributos
  final List<Map<String, dynamic>> _puntosInteres = [
    {
      'nombre': 'Plaza Murillo',
      'posicion': const LatLng(-16.4955, -68.1336),
      'icono': Icons.account_balance,
      'color': Colors.red,
    },
    {
      'nombre': 'Iglesia San Francisco',
      'posicion': const LatLng(-16.4963, -68.1383),
      'icono': Icons.church,
      'color': Colors.blue,
    },
    {
      'nombre': 'Parque Urbano Central',
      'posicion': const LatLng(-16.5113, -68.1238),
      'icono': Icons.park,
      'color': Colors.green,
    },
    {
      'nombre': 'Mercado Lanza',
      'posicion': const LatLng(-16.4978, -68.1369),
      'icono': Icons.store,
      'color': Colors.orange,
    },
  ];

  // Índice del punto actual (para el reto extra de navegar entre puntos)
  int _puntoActual = 0;

  /// Navega al siguiente punto de interés
  void _irAlSiguientePunto() {
    setState(() {
      _puntoActual = (_puntoActual + 1) % _puntosInteres.length;
    });
    LatLng destino = _puntosInteres[_puntoActual]['posicion'];
    _mapController.move(destino, 16.0);
  }

  /// Genera la lista de marcadores desde los puntos de interés
  List<Marker> _generarMarcadores() {
    return _puntosInteres.map((punto) {
      return Marker(
        point: punto['posicion'],
        width: 40,
        height: 40,
        child: Icon(
          punto['icono'],
          color: punto['color'],
          size: 36,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoCollect'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mapa — ocupa todo el espacio disponible
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centroInicial,
                initialZoom: _zoomInicial,
              ),
              children: [
                // Capa base — OpenStreetMap
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.geo_collect',
                ),
                // Capa de marcadores
                MarkerLayer(
                  markers: _generarMarcadores(),
                ),
              ],
            ),
          ),
          // Barra de información inferior
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📍 La Paz, Bolivia',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Puntos: ${_puntosInteres.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      // Botón flotante — navegar entre puntos (Reto Extra)
      floatingActionButton: FloatingActionButton(
        onPressed: _irAlSiguientePunto,
        tooltip: 'Ir al siguiente punto',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}