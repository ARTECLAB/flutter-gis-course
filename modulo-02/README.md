# Módulo 2 · Mapas Interactivos & Capas Base 🗺️

> **Clases 3 y 4 · 4 horas totales**
> Tu app se convierte en una herramienta profesional con múltiples capas base, marcadores con popups, geometrías sobre el mapa y eventos de interacción.

---

## 🎯 Objetivos del Módulo

- Dominar flutter_map con múltiples proveedores de tiles
- Controlar la cámara del mapa con animaciones
- Crear marcadores interactivos con popups de información
- Dibujar polilíneas y polígonos sobre el mapa
- Capturar eventos de toque sobre el mapa

---

## Clase 03 — Capas Base, Cámara y Marcadores Interactivos

### 🎯 Objetivo de la Clase

Implementar un selector de capas base (calles, satélite, terreno), controlar la cámara del mapa con animaciones suaves, y crear marcadores que muestren información al tocarlos.

### Parte 1 — Múltiples Capas Base (30 min)

#### ¿Qué son los Tile Providers?

En QGIS puedes cambiar entre diferentes mapas base: OpenStreetMap, Google Satellite, Bing Maps. En flutter_map hacemos lo mismo cambiando la URL de los tiles.

```dart
// Definimos las URLs de diferentes proveedores de tiles
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
```

#### Implementar el selector de capas

Necesitamos una variable de estado para saber cuál capa está activa:

```dart
class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final LatLng _centroInicial = const LatLng(-16.5000, -68.1500);

  // Estado de la capa activa
  String _capaActual = TileProviders.openStreetMap;
  String _nombreCapaActual = 'Calles';

  // Mapa de capas disponibles
  final Map<String, String> _capasDisponibles = {
    'Calles': TileProviders.openStreetMap,
    'Satélite': TileProviders.esriSatelite,
    'Terreno': TileProviders.esriTerreno,
    'Oscuro': TileProviders.cartoDark,
    'Claro': TileProviders.cartoLight,
  };

  void _cambiarCapa(String nombre, String url) {
    setState(() {
      _nombreCapaActual = nombre;
      _capaActual = url;
    });
  }
```

#### Widget del selector — DropdownButton

```dart
// Dentro del AppBar como action
AppBar(
  title: const Text('GeoCollect'),
  actions: [
    DropdownButton<String>(
      value: _nombreCapaActual,
      dropdownColor: Colors.teal.shade800,
      style: const TextStyle(color: Colors.white),
      underline: const SizedBox(),
      icon: const Icon(Icons.layers, color: Colors.white),
      items: _capasDisponibles.keys.map((nombre) {
        return DropdownMenuItem(
          value: nombre,
          child: Text(nombre),
        );
      }).toList(),
      onChanged: (nombre) {
        if (nombre != null) {
          _cambiarCapa(nombre, _capasDisponibles[nombre]!);
        }
      },
    ),
    const SizedBox(width: 12),
  ],
)
```

#### Usar la capa dinámica en FlutterMap

```dart
TileLayer(
  urlTemplate: _capaActual,  // ← Ahora es dinámico
  userAgentPackageName: 'com.example.geo_collect',
)
```

⚠️ **Nota sobre ESRI tiles:** Los tiles de ESRI Satellite y Topo son gratuitos para uso educativo y personal pero tienen términos de uso. Para producción comercial, considera usar Mapbox o contratar una licencia.

### Parte 2 — Control de Cámara con Animaciones (25 min)

#### MapController — Mover el mapa programáticamente

Ya usamos `MapController` en el Módulo 1 para el reto extra. Ahora lo llevamos más lejos con animaciones suaves.

```dart
// Mover sin animación (instantáneo)
_mapController.move(nuevoLatLng, zoom);

// Mover con animación suave usando AnimationController
// Primero, el State debe implementar TickerProviderStateMixin
class _MapaScreenState extends State<MapaScreen>
    with TickerProviderStateMixin {

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

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}
```

#### Botones de zoom

```dart
// Botones de zoom + y -
Positioned(
  right: 16,
  bottom: 80,
  child: Column(
    children: [
      FloatingActionButton.small(
        heroTag: 'zoomIn',
        onPressed: () {
          final zoom = _mapController.camera.zoom + 1;
          _mapController.move(_mapController.camera.center, zoom);
        },
        child: const Icon(Icons.add),
      ),
      const SizedBox(height: 8),
      FloatingActionButton.small(
        heroTag: 'zoomOut',
        onPressed: () {
          final zoom = _mapController.camera.zoom - 1;
          _mapController.move(_mapController.camera.center, zoom);
        },
        child: const Icon(Icons.remove),
      ),
    ],
  ),
)
```

### Parte 3 — Marcadores con Popups (35 min)

#### Instalar flutter_map_marker_popup

Agregar en `pubspec.yaml`:

```yaml
dependencies:
  flutter_map_marker_popup: ^7.0.0
```

```bash
flutter pub get
```

#### Importar y usar

```dart
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

// Crear un controlador de popups
final PopupController _popupController = PopupController();

// Reemplazar MarkerLayer con PopupMarkerLayer
PopupMarkerLayer(
  options: PopupMarkerLayerOptions(
    popupController: _popupController,
    markers: _generarMarcadores(),
    popupDisplayOptions: PopupDisplayOptions(
      builder: (BuildContext context, Marker marker) {
        // Buscar el punto correspondiente al marcador
        final punto = _puntosInteres.firstWhere(
          (p) => p['posicion'] == marker.point,
        );
        return _construirPopup(punto);
      },
    ),
  ),
),
```

#### Widget del popup

```dart
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
        Text(
          punto['nombre'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lat: ${punto['posicion'].latitude.toStringAsFixed(4)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          'Lng: ${punto['posicion'].longitude.toStringAsFixed(4)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
```

---

### 💻 Práctica 03 — Capas Base y Marcadores Interactivos

**Objetivo:** Implementar el selector de capas base y popups en los marcadores.

1. Agrega al menos 3 proveedores de tiles diferentes (OSM, Satélite, Oscuro)
2. Implementa un DropdownButton en el AppBar para cambiar entre ellos
3. Convierte tus marcadores del Módulo 1 a marcadores con popups que muestren nombre y coordenadas
4. Agrega al popup un campo "Tipo" (parque, iglesia, etc.) con un ícono correspondiente

**Entrega:** Tu app mostrando diferentes capas base y popups al tocar marcadores.

---

## Clase 04 — Geometrías sobre el Mapa y Eventos de Interacción

### 🎯 Objetivo de la Clase

Dibujar polilíneas y polígonos sobre el mapa, capturar eventos de toque del usuario, y mostrar coordenadas en tiempo real del punto tocado.

### Parte 1 — Polilíneas (25 min)

Una polilínea es una secuencia de puntos conectados por líneas. En GIS representan rutas, ríos, carreteras.

```dart
// Definir los puntos de una ruta
final List<LatLng> _rutaEjemplo = [
  const LatLng(-16.4955, -68.1336),  // Plaza Murillo
  const LatLng(-16.4963, -68.1383),  // San Francisco
  const LatLng(-16.4978, -68.1369),  // Mercado Lanza
  const LatLng(-16.5020, -68.1350),  // Punto intermedio
];

// Agregar PolylineLayer a los children de FlutterMap
PolylineLayer(
  polylines: [
    Polyline(
      points: _rutaEjemplo,
      color: Colors.blue,
      strokeWidth: 4.0,
      isDotted: false,
    ),
  ],
),
```

#### Polilíneas con estilo

```dart
// Línea punteada
Polyline(
  points: _rutaAlternativa,
  color: Colors.orange,
  strokeWidth: 3.0,
  isDotted: true,
)

// Línea con gradiente (usando borderColor)
Polyline(
  points: _rutaPrincipal,
  color: Colors.blue.withOpacity(0.8),
  strokeWidth: 5.0,
  borderColor: Colors.blue.shade900,
  borderStrokeWidth: 1.0,
)
```

### Parte 2 — Polígonos (25 min)

Un polígono define un área cerrada. En GIS representan municipios, parcelas, zonas de estudio.

```dart
// Definir los vértices del polígono
final List<LatLng> _zonaEstudio = [
  const LatLng(-16.490, -68.140),
  const LatLng(-16.490, -68.125),
  const LatLng(-16.505, -68.125),
  const LatLng(-16.505, -68.140),
];

// Agregar PolygonLayer
PolygonLayer(
  polygons: [
    Polygon(
      points: _zonaEstudio,
      color: Colors.teal.withOpacity(0.2),
      borderColor: Colors.teal,
      borderStrokeWidth: 2.0,
      isFilled: true,
      label: 'Zona de Estudio',
      labelStyle: const TextStyle(
        color: Colors.teal,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  ],
),
```

### Parte 3 — Eventos de Interacción: tap y longPress (30 min)

#### Capturar dónde toca el usuario

```dart
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _centroInicial,
    initialZoom: 14.0,
    // Evento de toque simple
    onTap: (tapPosition, latLng) {
      _mostrarInfoCoordenada(latLng);
    },
    // Evento de toque largo
    onLongPress: (tapPosition, latLng) {
      _agregarMarcadorTemporal(latLng);
    },
    // Evento de cambio de posición (al mover o hacer zoom)
    onPositionChanged: (camera, hasGesture) {
      setState(() {
        _zoomActual = camera.zoom;
        _centroActual = camera.center;
      });
    },
  ),
  // ...
)
```

#### Agregar marcador donde el usuario toca

```dart
// Lista de marcadores creados por el usuario
List<LatLng> _marcadoresUsuario = [];

void _agregarMarcadorTemporal(LatLng posicion) {
  setState(() {
    _marcadoresUsuario.add(posicion);
  });

  // Mostrar snackbar con la coordenada
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Punto agregado: ${posicion.latitude.toStringAsFixed(4)}, '
        '${posicion.longitude.toStringAsFixed(4)}',
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

// MarkerLayer para marcadores del usuario
MarkerLayer(
  markers: _marcadoresUsuario.map((pos) {
    return Marker(
      point: pos,
      width: 30,
      height: 30,
      child: const Icon(Icons.push_pin, color: Colors.purple, size: 30),
    );
  }).toList(),
),
```

#### Barra de estado dinámica con zoom y coordenadas en tiempo real

```dart
double _zoomActual = 14.0;
LatLng _centroActual = const LatLng(-16.5, -68.15);

// Barra inferior actualizada
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  color: Colors.teal.shade800,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '📍 ${_centroActual.latitude.toStringAsFixed(4)}, '
        '${_centroActual.longitude.toStringAsFixed(4)}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      Text(
        'Zoom: ${_zoomActual.toStringAsFixed(1)} · '
        'Capa: $_nombreCapaActual',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    ],
  ),
)
```

---

### 💻 Práctica 04 — Geometrías y Eventos

1. Dibuja una **polilínea** que conecte al menos 4 puntos reales de tu ciudad (una ruta que conozcas)
2. Dibuja un **polígono** que represente una zona de estudio (un parque, un barrio, una plaza)
3. Implementa **onLongPress** para que al mantener presionado se agregue un marcador púrpura
4. Implementa **onPositionChanged** para que la barra inferior muestre las coordenadas del centro del mapa en tiempo real
5. Agrega un botón "Limpiar" que elimine todos los marcadores creados por el usuario

### 🚀 Reto Extra — Dibujo libre sobre el mapa

Implementa un modo "dibujo" donde al tocar puntos en el mapa se va creando una polilínea en tiempo real (como dibujar una ruta punto a punto). Un botón activa/desactiva el modo dibujo, y otro botón cierra la polilínea convirtiéndola en polígono.

Pistas:
- Variable `bool _mododibujo = false;`
- Lista `List<LatLng> _puntosDibujo = [];`
- En `onTap`: si `_mododibujo` es true, agrega el punto a `_puntosDibujo`
- Renderiza `_puntosDibujo` como `Polyline` mientras dibuja

---

### ✅ Checklist Clase 03

- [ ] Selector de capas base funcional (mínimo 3 capas)
- [ ] Cambio de capa se refleja inmediatamente en el mapa
- [ ] Marcadores con popups mostrando información al tocar
- [ ] Popups se cierran al tocar fuera

### ✅ Checklist Clase 04

- [ ] Polilínea dibujada sobre el mapa con puntos reales
- [ ] Polígono con relleno semi-transparente
- [ ] onLongPress agrega marcadores donde el usuario toca
- [ ] Barra inferior muestra coordenadas y zoom en tiempo real
- [ ] Botón para limpiar marcadores del usuario

---

## 📚 Recursos del Módulo 2

| Recurso | Enlace |
|---------|--------|
| flutter_map docs — Layers | https://docs.fleaflet.dev/layers/tile-layer |
| flutter_map_marker_popup | https://pub.dev/packages/flutter_map_marker_popup |
| Tiles ESRI gratuitos | https://server.arcgisonline.com/ArcGIS/rest/services |
| Tiles CartoDB | https://github.com/CartoDB/basemap-styles |
| EPSG:4326 explicado | https://epsg.io/4326 |

---

## 📝 Errores comunes en este módulo

1. **Popup no aparece** → Verificar que instalaste `flutter_map_marker_popup` y ejecutaste `flutter pub get`
2. **Tiles de satélite no cargan** → Algunos proveedores requieren API key. ESRI World Imagery es gratuito.
3. **Polígono no se ve** → Verificar que el color tiene `withOpacity()` para que sea semi-transparente
4. **onTap no funciona con PopupMarkerLayer** → El popup intercepta el tap. Usa `onLongPress` para agregar marcadores
5. **Animación no funciona** → Asegúrate de agregar `with TickerProviderStateMixin` al State