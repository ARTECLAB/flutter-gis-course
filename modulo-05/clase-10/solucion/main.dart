// =============================================================
// ✅ SOLUCIÓN — Clase 10: GeoCollect con Formularios, Lista y Persistencia
// =============================================================
// Módulo 5 · Clase 10 — Estado del proyecto al final del Módulo 5
// Curso Flutter GIS — Daniel Quisbert
//
// DEPENDENCIAS en pubspec.yaml:
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   flutter_map_marker_popup: ^7.0.0
//   geolocator: ^12.0.0
//   http: ^1.2.0
//   shared_preferences: ^2.2.0
// =============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
// HOME — BottomNavigationBar: Mapa ↔ Lista
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

  @override
  void initState() {
    super.initState();
    _cargarPuntos();
  }

  // ── Persistencia ──
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

  void _actualizarPunto(int index, Map<String, dynamic> punto) {
    setState(() => _puntos[index] = punto);
    _guardarPuntos();
  }

  // ── GPS ──
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
        setState(() => _posicionGPS = LatLng(pos.latitude, pos.longitude));
      });
    }
  }

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

  Widget _buildMapa() {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoCollect')),
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
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            color: _colorPorEstado(p['estado'] ?? 'Bueno'),
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
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Text(
                  'Puntos: ${_puntos.length}',
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

  Widget _buildLista() {
    return Scaffold(
      appBar: AppBar(title: Text('Datos (${_puntos.length})')),
      body: _puntos.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay puntos capturados',
                      style: TextStyle(color: Colors.grey)),
                  Text('Ve al mapa y captura tu primer punto',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _eliminarPunto(i),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _colorPorEstado(p['estado'] ?? 'Bueno')
                              .withOpacity(0.15),
                      child: Icon(
                        _iconoPorTipo(p['tipo'] ?? ''),
                        color: _colorPorEstado(p['estado'] ?? 'Bueno'),
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
                      onPressed: () => _verEnMapa(
                        p['latitud'],
                        p['longitud'],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

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
  final Map<String, dynamic>? datosExistentes;

  const FormularioPunto({
    required this.posicion,
    required this.onGuardar,
    this.datosExistentes,
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

  @override
  void initState() {
    super.initState();
    if (widget.datosExistentes != null) {
      _nombreCtrl.text = widget.datosExistentes!['nombre'] ?? '';
      _tipo = widget.datosExistentes!['tipo'];
      _estado = widget.datosExistentes!['estado'] ?? 'Bueno';
      _observacionCtrl.text = widget.datosExistentes!['observacion'] ?? '';
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final punto = {
        'id': widget.datosExistentes?['id'] ??
            DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreCtrl.text,
        'tipo': _tipo,
        'estado': _estado,
        'observacion': _observacionCtrl.text,
        'latitud': widget.posicion.latitude,
        'longitud': widget.posicion.longitude,
        'fecha': widget.datosExistentes?['fecha'] ??
            DateTime.now().toIso8601String(),
      };
      widget.onGuardar(punto);
      Navigator.pop(context);
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
    final bool esEdicion = widget.datosExistentes != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Punto' : 'Nuevo Punto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.posicion.latitude.toStringAsFixed(6)}, '
                        '${widget.posicion.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del punto *',
                  hintText: 'Ej: Poste eléctrico #42',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nombre obligatorio' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: ['Poste', 'Árbol', 'Edificio', 'Muestra', 'Otro']
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v),
                validator: (v) => v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              const Text('Estado:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ...['Bueno', 'Regular', 'Malo'].map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _estado,
                    onChanged: (v) => setState(() => _estado = v!),
                    dense: true,
                  )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(esEdicion ? 'Actualizar' : 'Guardar Punto'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}