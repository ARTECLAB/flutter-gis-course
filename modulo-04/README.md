# Módulo 4 · Consumo de Capas GeoServer WMS 🌐

> **Clases 7 y 8 · 4 horas totales**
> Tu app se conecta a un servidor GeoServer real. Capas WMS profesionales sobre tu mapa, filtros CQL y leyenda dinámica.

---

## 🎯 Objetivos del Módulo

- Entender qué es GeoServer y el estándar WMS
- Conectar flutter_map con capas WMS de un servidor real
- Superponer múltiples capas WMS sobre el mapa base
- Aplicar filtros CQL para consultar datos del servidor
- Mostrar leyenda dinámica de las capas WMS
- Implementar WMS GetFeatureInfo para consultar atributos

---

## Clase 07 — ¿Qué es GeoServer? Tu primera capa WMS

### 🎯 Objetivo

Entender la arquitectura cliente-servidor en GIS, conectar tu app con un GeoServer real y mostrar la primera capa WMS.

### Parte 1 — Conceptos: GeoServer y WMS (20 min)

#### ¿Qué es GeoServer?

GeoServer es un servidor que almacena datos geográficos (shapefiles, PostGIS, GeoTIFFs) y los sirve a través de internet usando estándares OGC como WMS, WFS y WCS.

**Analogía:**
- GeoServer = restaurante con cocina
- Los datos (shapefiles, PostGIS) = ingredientes en la cocina
- WMS = el menú: pides una imagen del mapa y el servidor la prepara
- Tu app Flutter = el cliente en la mesa

Tu app NO descarga los datos originales. Solo pide imágenes renderizadas.

#### ¿Qué es WMS?

WMS = Web Map Service. Estándar OGC que define cómo un servidor envía imágenes de mapas.

Tu app dice: "Dame la capa 'ríos', en esta zona, en formato PNG, con fondo transparente."
El servidor responde con una imagen.

#### Anatomía de una URL WMS

```
https://miservidor.com/geoserver/wms?
  service=WMS&version=1.1.1&request=GetMap
  &layers=workspace:nombre_capa
  &bbox=-68.5,-17.0,-67.5,-16.0
  &width=800&height=600
  &srs=EPSG:4326
  &format=image/png
  &transparent=true
```

| Parámetro | Propósito |
|-----------|-----------|
| `service` | Tipo: WMS |
| `request` | GetMap = dame una imagen |
| `layers` | workspace:nombre_capa |
| `bbox` | Zona geográfica |
| `srs` | Sistema de coordenadas |
| `format` | Formato de imagen |
| `transparent` | Fondo transparente |

### Parte 2 — Conectar con GeoServer desde Flutter (30 min)

flutter_map soporta WMS nativamente:

```dart
TileLayer(
  wmsOptions: WMSTileLayerOptions(
    baseUrl: 'https://miservidor.com/geoserver/wms?',
    layers: ['workspace:departamentos'],
    transparent: true,
    format: 'image/png',
    version: '1.1.1',
    otherParameters: {
      'SRS': 'EPSG:4326',
    },
  ),
),
```

⚠️ El `?` al final de baseUrl es OBLIGATORIO.

### Parte 3 — Múltiples Capas WMS con Toggle (25 min)

```dart
Map<String, bool> _capasWMS = {
  'departamentos': true,
  'rios': false,
  'carreteras': false,
};

// Generar capas dinámicamente
..._capasWMS.entries.where((e) => e.value).map((e) {
  return TileLayer(
    wmsOptions: WMSTileLayerOptions(
      baseUrl: 'https://miservidor.com/geoserver/wms?',
      layers: ['workspace:${e.key}'],
      transparent: true,
      format: 'image/png',
    ),
  );
}).toList(),
```

#### Panel de control con Drawer

```dart
Drawer(
  child: ListView(
    children: [
      const DrawerHeader(child: Text('Capas WMS')),
      ..._capasWMS.entries.map((e) => SwitchListTile(
        title: Text(e.key),
        value: e.value,
        onChanged: (v) => setState(() => _capasWMS[e.key] = v),
      )).toList(),
    ],
  ),
)
```

---

### 💻 Práctica 07

1. Conecta tu app a GeoServer con WMSTileLayerOptions
2. Muestra una capa WMS sobre el mapa base OSM
3. Verifica transparencia (`transparent: true`)
4. Agrega 2+ capas WMS
5. Drawer con SwitchListTile para toggle

---

## Clase 08 — Filtros CQL, GetFeatureInfo y Leyenda

### 🎯 Objetivo

Filtrar datos del servidor con CQL, consultar atributos con GetFeatureInfo, mostrar leyenda.

### Parte 1 — Filtros CQL (30 min)

CQL = Common Query Language. Como un WHERE de SQL pero para capas geográficas.

```dart
TileLayer(
  wmsOptions: WMSTileLayerOptions(
    baseUrl: 'https://miservidor.com/geoserver/wms?',
    layers: ['workspace:municipios'],
    transparent: true,
    format: 'image/png',
    otherParameters: {
      'CQL_FILTER': "departamento='La Paz'",
    },
  ),
),
```

#### Ejemplos CQL

```
departamento='La Paz'
poblacion>100000
departamento='La Paz' AND poblacion>50000
DWITHIN(geometria, POINT(-68.15 -16.50), 10000, meters)
```

### Parte 2 — GetFeatureInfo (25 min)

Consulta atributos del feature donde el usuario tocó el mapa.

⚠️ **Punto crítico:** GetFeatureInfo necesita WIDTH/HEIGHT del mapa y X,Y del píxel tocado.
NO uses `MediaQuery.of(context).size` — eso da el tamaño de toda la pantalla, no del mapa.
Usa un `GlobalKey` en el FlutterMap para obtener el tamaño real del widget del mapa.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Declarar en el State:
final GlobalKey _mapKey = GlobalKey();

// En el build, asignar el key al FlutterMap:
// FlutterMap(key: _mapKey, mapController: _mapController, ...)

Future<void> _consultarFeature(TapPosition tapPos, LatLng punto) async {
  // 1. Tamaño REAL del widget del mapa (no de la pantalla)
  final RenderBox? mapBox =
      _mapKey.currentContext?.findRenderObject() as RenderBox?;
  if (mapBox == null) return;
  final Size mapSize = mapBox.size;

  // 2. BBOX visible del mapa
  final bounds = _mapController.camera.visibleBounds;

  final int width = mapSize.width.round();
  final int height = mapSize.height.round();

  // 3. Convertir coordenada geográfica a píxel X,Y
  //    Y va invertido: en imagen el 0 está arriba, en geo el norte es mayor
  final int x = ((punto.longitude - bounds.west) /
      (bounds.east - bounds.west) * width).round();
  final int y = ((bounds.north - punto.latitude) /
      (bounds.north - bounds.south) * height).round();

  // 4. Validar rango
  if (x < 0 || x >= width || y < 0 || y >= height) return;

  // 5. Construir URL — BBOX para WMS 1.1.1: west,south,east,north
  final String bbox =
      '${bounds.west},${bounds.south},${bounds.east},${bounds.north}';

  final url = Uri.parse(
    'https://miservidor.com/geoserver/wms?'
    'SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo'
    '&LAYERS=workspace:municipios'
    '&QUERY_LAYERS=workspace:municipios'
    '&SRS=EPSG:4326&FORMAT=image/png'
    '&BBOX=$bbox'
    '&WIDTH=$width&HEIGHT=$height'
    '&INFO_FORMAT=application/json'
    '&FEATURE_COUNT=5'
    '&X=$x&Y=$y'
  );

  try {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final features = data['features'] as List?;
      if (features != null && features.isNotEmpty) {
        _mostrarAtributos(features[0]['properties']);
      }
    }
  } catch (e) {
    debugPrint('Error GetFeatureInfo: $e');
  }
}
```

**Dependencia:**
```yaml
  http: ^1.2.0
```

**Verificación previa:** Antes de codear, prueba la URL de GetFeatureInfo directamente en el navegador con valores fijos de BBOX, WIDTH, HEIGHT, X, Y. Si el navegador devuelve JSON con features, el servidor está bien configurado.

**Requisitos del servidor:**
- GeoServer con **CORS habilitado** (sin CORS la app no puede conectarse)
- Capa marcada como **Queryable** en la configuración WMS de GeoServer

### Parte 3 — Leyenda WMS (15 min)

```dart
String _urlLeyenda(String capa) {
  return 'https://miservidor.com/geoserver/wms?'
    'service=WMS&version=1.1.1&request=GetLegendGraphic'
    '&layer=workspace:$capa&format=image/png&width=20&height=20';
}

Image.network(_urlLeyenda('departamentos'))
```

---

### 💻 Práctica 08

1. Filtro CQL en una capa (solo un departamento)
2. TextField para que el usuario escriba el filtro
3. GetFeatureInfo al tocar: diálogo con atributos
4. Leyenda WMS visible en pantalla

### 🚀 Reto Extra — Selector dinámico

DropdownButton para elegir departamento que actualice el CQL_FILTER en tiempo real.

### ✅ Checklist Clase 07

- [ ] App conectada a GeoServer
- [ ] Capa WMS visible sobre mapa base
- [ ] Fondo transparente funcional
- [ ] Drawer con toggles de capas

### ✅ Checklist Clase 08

- [ ] Filtro CQL aplicado
- [ ] GetFeatureInfo muestra atributos
- [ ] Leyenda WMS visible
- [ ] Múltiples capas simultáneas

---

## 📝 Errores comunes

1. **Capa en blanco** → Verificar URL, nombre workspace:capa, servidor online
2. **Capa desalineada** → SRS debe ser EPSG:4326 o EPSG:3857 según config
3. **Falta `?` en baseUrl** → flutter_map necesita el `?` para construir params
4. **CQL no filtra** → Verificar nombre exacto del campo, strings entre comillas simples
5. **GetFeatureInfo vacío** → query_layers debe coincidir con layers
6. **CORS bloqueado** → GeoServer necesita CORS habilitado