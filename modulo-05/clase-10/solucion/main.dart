// =============================================================
// ✅ SOLUCIÓN FINAL — GeoCollect v1.0
// =============================================================
// Curso Flutter GIS — Daniel Quisbert
// Estado del proyecto al finalizar el curso completo (Módulo 6)
//
// DEPENDENCIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   geolocator: ^12.0.0
//   shared_preferences: ^2.2.0
//   path_provider: ^2.1.0
//   share_plus: ^9.0.0
//
// PERMISOS en AndroidManifest.xml:
//   <uses-permission android:name="android.permission.INTERNET"/>
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
// =============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
      home: const HomeScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TILE PROVIDERS
// ═══════════════════════════════════════════════════════════

class TileProviders {
  static const String osm =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String satelite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String oscuro =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
}

// ═══════════════════════════════════════════════════════════
// HOME SCREEN — BottomNavigationBar: Mapa ↔ Lista
// ═══════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pantalla = 0;
  final MapController _mapController = MapController();

  // Datos
  List<Map<String, dynamic>> _puntos = [];

  // GPS
  LatLng? _posicionGPS;
  bool _siguiendo = false;
  StreamSubscription<Position>? _posStream;

  // Mapa
  String _capaBase = TileProviders.osm;
  String _nombreCapa = 'Calles';
  double _zoomActual = 14.0;
  final Map<String, String> _capas = {
    'Calles': TileProviders.osm,
    'Satélite': TileProviders.satelite,
    'Oscuro': TileProviders.oscuro,
  };

  @override
  void initState() {
    super.initState();
    _cargarPuntos();
  }

  // ── Persistencia ──────────────────────────────────

  Future<void> _cargarPuntos() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('puntos_campo');
    if (str != null) {
      final List<dynamic> lista = json.decode(str);
      setState(() {
        _puntos = lista.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _guardarPuntos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('puntos_campo', json.encode(_puntos));
  }

  void _agregarPunto(Map<String, dynamic> punto) {
    setState(() => _puntos.add(punto));
    _guardarPuntos();
  }

  void _eliminarPunto(int index) {
    setState(() => _puntos.removeAt(index));
    _guardarPuntos();
  }

  // ── GPS ────────────────────────────────────────────

  Future<bool> _verificarPermisos() async {
    bool gps = await Geolocator.isLocationServiceEnabled();
    if (!gps) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Activa el GPS de tu teléfono')),
        );
      }
      return false;
    }
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
        setState(() => _posicionGPS = LatLng(pos.latitude, pos.longitude));
      });
    }
  }

  // ── Formulario ────────────────────────────────────

  void _abrirFormulario() {
    if (_posicionGPS == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Obtén tu ubicación GPS primero')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioPunto(
          posicion: _posicionGPS!,
          onGuardar: _agregarPunto,
        ),
      ),
    );
  }

  // ── GeoJSON ───────────────────────────────────────

  String _generarGeoJSON() {
    final features = _puntos.map((p) {
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [p['longitud'], p['latitud']],
        },
        'properties': {
          'nombre': p['nombre'],
          'tipo': p['tipo'],
          'estado': p['estado'],
          'observacion': p['observacion'] ?? '',
          'fecha': p['fecha'],
        },
      };
    }).toList();

    final geojson = {
      'type': 'FeatureCollection',
      'features': features,
    };

    return const JsonEncoder.withIndent('  ').convert(geojson);
  }

  Future<void> _exportarGeoJSON() async {
    if (_puntos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay puntos para exportar')),
      );
      return;
    }

    try {
      final geojsonStr = _generarGeoJSON();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/geocollect_$timestamp.geojson');
      await file.writeAsString(geojsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'GeoCollect — ${_puntos.length} puntos capturados',
        subject: 'Exportación GeoCollect',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  // ── Navegación ────────────────────────────────────

  void _verEnMapa(double lat, double lng) {
    setState(() => _pantalla = 0);
    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.move(LatLng(lat, lng), 17.0);
    });
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pantalla,
        children: [
          _buildMapa(),
          _buildLista(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pantalla,
        onTap: (i) => setState(() => _pantalla = i),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_puntos.length}'),
              isLabelVisible: _puntos.isNotEmpty,
              child: const Icon(Icons.list),
            ),
            label: 'Datos',
          ),
        ],
      ),
    );
  }

  // ── Pantalla Mapa ─────────────────────────────────

  Widget _buildMapa() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoCollect'),
        actions: [
          DropdownButton<String>(
            value: _nombreCapa,
            dropdownColor: Colors.teal.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: const SizedBox(),
            icon: const Icon(Icons.layers, color: Colors.white),
            items: _capas.keys
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (n) {
              if (n != null) {
                setState(() {
                  _nombreCapa = n;
                  _capaBase = _capas[n]!;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar GeoJSON',
            onPressed: _exportarGeoJSON,
          ),
          const SizedBox(width: 4),
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
                    initialCenter: const LatLng(-16.5, -68.15),
                    initialZoom: 14.0,
                    onPositionChanged: (cam, _) {
                      _zoomActual = cam.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _capaBase,
                      userAgentPackageName: 'com.example.geo_collect',
                    ),
                    // Puntos capturados
                    MarkerLayer(
                      markers: _puntos.map((p) {
                        return Marker(
                          point: LatLng(p['latitud'], p['longitud']),
                          width: 30,
                          height: 30,
                          child: Icon(
                            _iconoPorTipo(p['tipo'] ?? ''),
                            color:
                                _colorPorEstado(p['estado'] ?? 'Bueno'),
                            size: 28,
                          ),
                        );
                      }).toList(),
                    ),
                    // GPS
                    if (_posicionGPS != null)
                      MarkerLayer(markers: [
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
                        onPressed: _abrirFormulario,
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
                  'Puntos: ${_puntos.length} · $_nombreCapa',
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

  // ── Pantalla Lista ────────────────────────────────

  Widget _buildLista() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos (${_puntos.length})'),
        actions: [
          if (_puntos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Exportar GeoJSON',
              onPressed: _exportarGeoJSON,
            ),
        ],
      ),
      body: _puntos.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay puntos capturados',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Ve al mapa y captura tu primer punto',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _puntos.length,
              itemBuilder: (ctx, i) {
                final p = _puntos[i];
                return Dismissible(
                  key: Key(p['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child:
                        const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar punto'),
                        content: Text(
                            '¿Eliminar "${p['nombre']}"?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _eliminarPunto(i),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _colorPorEstado(p['estado'] ?? 'Bueno')
                              .withOpacity(0.15),
                      child: Icon(
                        _iconoPorTipo(p['tipo'] ?? ''),
                        color:
                            _colorPorEstado(p['estado'] ?? 'Bueno'),
                      ),
                    ),
                    title: Text(p['nombre'] ?? 'Sin nombre'),
                    subtitle: Text(
                      '${p['tipo'] ?? '-'} · ${p['estado'] ?? '-'}\n'
                      '${(p['latitud'] as num).toStringAsFixed(4)}, '
                      '${(p['longitud'] as num).toStringAsFixed(4)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.map_outlined),
                      tooltip: 'Ver en mapa',
                      onPressed: () =>
                          _verEnMapa(p['latitud'], p['longitud']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'Poste':
        return Icons.electrical_services;
      case 'Árbol':
        return Icons.park;
      case 'Edificio':
        return Icons.apartment;
      case 'Muestra':
        return Icons.science;
      default:
        return Icons.location_on;
    }
  }

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'Bueno':
        return Colors.green;
      case 'Regular':
        return Colors.orange;
      case 'Malo':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// FORMULARIO DE CAPTURA
// ═══════════════════════════════════════════════════════════

class FormularioPunto extends StatefulWidget {
  final LatLng posicion;
  final Function(Map<String, dynamic>) onGuardar;

  const FormularioPunto({
    required this.posicion,
    required this.onGuardar,
    super.key,
  });

  @override
  State<FormularioPunto> createState() => _FormularioPuntoState();
}

class _FormularioPuntoState extends State<FormularioPunto> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();
  String? _tipo;
  String _estado = 'Bueno';

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final punto = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreCtrl.text.trim(),
        'tipo': _tipo,
        'estado': _estado,
        'observacion': _observacionCtrl.text.trim(),
        'latitud': widget.posicion.latitude,
        'longitud': widget.posicion.longitude,
        'fecha': DateTime.now().toIso8601String(),
      };
      widget.onGuardar(punto);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ "${_nombreCtrl.text}" guardado')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Punto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coordenadas GPS (solo lectura)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed, color: Colors.teal),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Coordenadas GPS',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          Text(
                            '${widget.posicion.latitude.toStringAsFixed(6)}, '
                            '${widget.posicion.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del punto *',
                  hintText: 'Ej: Poste eléctrico #42',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nombre obligatorio' : null,
              ),
              const SizedBox(height: 14),
              // Tipo
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de punto *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: ['Poste', 'Árbol', 'Edificio', 'Muestra', 'Otro']
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v),
                validator: (v) =>
                    v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 18),
              // Estado
              const Text('Estado:',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ...['Bueno', 'Regular', 'Malo'].map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _estado,
                    onChanged: (v) => setState(() => _estado = v!),
                    dense: true,
                  )),
              const SizedBox(height: 14),
              // Observaciones
              TextFormField(
                controller: _observacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Notas adicionales...',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              // Botón guardar
              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Punto'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}