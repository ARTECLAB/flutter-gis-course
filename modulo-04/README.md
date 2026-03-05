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

#### ¿Qué es GetFeatureInfo?

Es una petición WMS que dice: "en este punto del mapa, ¿qué feature hay y cuáles son sus atributos?". Es el equivalente exacto de la herramienta **Identificar** de QGIS — haces clic en un polígono y ves sus campos.

A diferencia de GetMap (que devuelve una imagen), GetFeatureInfo devuelve **datos** — generalmente en formato JSON.

#### El flujo completo

```
1. Usuario toca el mapa
   ↓
2. flutter_map te da las coordenadas geográficas (LatLng)
   ↓
3. Tu código convierte LatLng → píxel X,Y dentro de una imagen virtual
   ↓
4. Construyes una URL GetFeatureInfo con BBOX, WIDTH, HEIGHT, X, Y
   ↓
5. Envías la URL al GeoServer con http.get()
   ↓
6. GeoServer responde con JSON que contiene los atributos
   ↓
7. Tu app muestra los atributos en un diálogo
```

#### Ejemplo de respuesta JSON de GeoServer

Cuando haces la petición GetFeatureInfo, el servidor responde algo así:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": "municipios.153",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [[[[-68.12, -16.48], [-68.13, -16.49], ...]]]
      },
      "properties": {
        "nombre": "La Paz",
        "departamento": "La Paz",
        "poblacion": 877363,
        "superficie_km2": 2012,
        "codigo_ine": "020101"
      }
    }
  ]
}
```

Lo que nos interesa es `features[0]['properties']` — ahí están los atributos del feature.

Si `features` está vacío `[]`, significa que el usuario tocó donde no hay ningún feature de esa capa (ejemplo: tocó fuera de los límites municipales).

#### El cálculo de X, Y — por qué es el punto crítico

GetFeatureInfo no recibe coordenadas geográficas directamente. Recibe la posición en **píxeles** dentro de una imagen virtual. Necesitas decirle al servidor:

- "Imagina una imagen de **WIDTH x HEIGHT** píxeles"
- "Que representa esta zona geográfica (**BBOX**)"
- "Dime qué feature está en el píxel **X, Y** de esa imagen"

La fórmula de conversión:

```
X = (longitud_tocada - bbox_west) / (bbox_east - bbox_west) × WIDTH
Y = (bbox_north - latitud_tocada) / (bbox_north - bbox_south) × HEIGHT
```

⚠️ **Y está invertido** porque en una imagen el píxel 0 está en la esquina SUPERIOR izquierda, pero en coordenadas geográficas el norte (arriba) tiene valores mayores.

⚠️ **NO uses `MediaQuery.of(context).size`** — eso da el tamaño de toda la pantalla (incluyendo AppBar y barra inferior). Usa un `GlobalKey` en el FlutterMap para obtener el tamaño real del widget del mapa solamente.

#### Dependencia necesaria

```yaml
dependencies:
  http: ^1.2.0
```

```bash
flutter pub get
```

#### Código completo — Paso a paso

**Paso 1: Declarar el GlobalKey en el State**

```dart
final GlobalKey _mapKey = GlobalKey();
```

**Paso 2: Asignar el key al FlutterMap**

```dart
FlutterMap(
  key: _mapKey,  // ← Esto permite obtener el tamaño real del widget
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _centroInicial,
    initialZoom: 14.0,
    onTap: _consultarFeature,  // ← Conectar con GetFeatureInfo
  ),
  children: [ /* capas... */ ],
)
```

**Paso 3: La función GetFeatureInfo completa**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> _consultarFeature(TapPosition tapPos, LatLng punto) async {
  // 1. Obtener el tamaño REAL del widget del mapa
  final RenderBox? mapBox =
      _mapKey.currentContext?.findRenderObject() as RenderBox?;
  if (mapBox == null) return;
  final Size mapSize = mapBox.size;

  // 2. Obtener el BBOX visible del mapa
  final bounds = _mapController.camera.visibleBounds;

  // 3. Definir WIDTH y HEIGHT de la imagen virtual
  final int width = mapSize.width.round();
  final int height = mapSize.height.round();

  // 4. Convertir coordenada geográfica a píxel X, Y
  final int x = ((punto.longitude - bounds.west) /
      (bounds.east - bounds.west) * width).round();
  final int y = ((bounds.north - punto.latitude) /
      (bounds.north - bounds.south) * height).round();

  // 5. Validar que X,Y están dentro del rango válido
  if (x < 0 || x >= width || y < 0 || y >= height) return;

  // 6. Construir BBOX string para WMS 1.1.1: west,south,east,north
  final String bbox =
      '${bounds.west},${bounds.south},${bounds.east},${bounds.north}';

  // 7. Construir la URL completa de GetFeatureInfo
  final url = Uri.parse(
    'https://miservidor.com/geoserver/wms?'
    'SERVICE=WMS'
    '&VERSION=1.1.1'
    '&REQUEST=GetFeatureInfo'
    '&LAYERS=workspace:municipios'
    '&QUERY_LAYERS=workspace:municipios'
    '&STYLES='
    '&SRS=EPSG:4326'
    '&FORMAT=image/png'
    '&BBOX=$bbox'
    '&WIDTH=$width'
    '&HEIGHT=$height'
    '&INFO_FORMAT=application/json'
    '&FEATURE_COUNT=5'
    '&X=$x'
    '&Y=$y'
  );

  debugPrint('GetFeatureInfo URL: $url');

  // 8. Hacer la petición HTTP
  try {
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final features = data['features'] as List?;

      if (features != null && features.isNotEmpty) {
        // Hay un feature — mostrar sus atributos
        final props = features[0]['properties'] as Map<String, dynamic>;
        _mostrarAtributos(props, punto);
      } else {
        // No hay feature en ese punto
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron datos en este punto'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      debugPrint('Error HTTP: ${resp.statusCode}');
      debugPrint('Respuesta: ${resp.body}');
    }
  } catch (e) {
    debugPrint('Error GetFeatureInfo: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexión: $e')),
    );
  }
}
```

**Paso 4: Widget que muestra los atributos**

```dart
void _mostrarAtributos(Map<String, dynamic> props, LatLng coordenada) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.teal),
                const SizedBox(width: 8),
                const Text('Atributos del Feature',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            // Coordenada tocada
            Text(
              'Coordenada: ${coordenada.latitude.toStringAsFixed(5)}, '
              '${coordenada.longitude.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            // Lista de atributos
            ...props.entries
                .where((e) => e.key != 'bbox' && e.value != null)
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal,
                                    fontSize: 13)),
                          ),
                          Expanded(
                            child: Text('${e.value}',
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      );
    },
  );
}
```

#### Cómo probar antes de codear

Antes de implementar en Flutter, verifica que tu GeoServer responde correctamente.
Pega esta URL en el **navegador** (reemplazando con tu servidor y capa):

```
https://tu-servidor.com/geoserver/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&LAYERS=workspace:municipios&QUERY_LAYERS=workspace:municipios&SRS=EPSG:4326&FORMAT=image/png&BBOX=-69,-18,-67,-15&WIDTH=400&HEIGHT=600&INFO_FORMAT=application/json&FEATURE_COUNT=5&X=200&Y=300
```

Si el navegador devuelve un JSON con `features`, el servidor funciona.
Si da error o HTML, revisa la configuración del GeoServer.

También puedes probar con un GeoServer público de ejemplo:
```
https://ows.terrestris.de/geoserver/wms
```
Con capas como `osm:water-areas`.

#### Requisitos del servidor

- **CORS habilitado** en GeoServer — sin esto, la app Android no puede conectarse al servidor. Se configura en el archivo `web.xml` del GeoServer.
- **Capa marcada como Queryable** — En GeoServer: Capas → tu capa → pestaña Publishing → sección WMS Settings → checkbox "Queryable".
- **Formato `application/json` soportado** — La mayoría de GeoServer modernos lo soportan por defecto.

#### Alternativa más robusta: WFS GetFeature

GeoServer mismo recomienda usar WFS en vez de GetFeatureInfo cuando sea posible, porque WFS es más flexible y no depende del cálculo de píxeles. Con WFS envías coordenadas geográficas directamente:

```dart
Future<void> _consultarWFS(TapPosition tapPos, LatLng punto) async {
  // Buffer de ~100m alrededor del punto tocado
  final double buffer = 0.001;
  final String cql =
      'INTERSECTS(geometria, '
      'POLYGON(('
      '${punto.longitude - buffer} ${punto.latitude - buffer}, '
      '${punto.longitude + buffer} ${punto.latitude - buffer}, '
      '${punto.longitude + buffer} ${punto.latitude + buffer}, '
      '${punto.longitude - buffer} ${punto.latitude + buffer}, '
      '${punto.longitude - buffer} ${punto.latitude - buffer}'
      ')))';

  final url = Uri.parse(
    'https://miservidor.com/geoserver/wfs?'
    'SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature'
    '&TYPENAMES=workspace:municipios'
    '&OUTPUTFORMAT=application/json'
    '&CQL_FILTER=${Uri.encodeComponent(cql)}'
    '&COUNT=1'
  );

  final resp = await http.get(url);
  if (resp.statusCode == 200) {
    final data = json.decode(resp.body);
    if (data['features'] != null && data['features'].isNotEmpty) {
      _mostrarAtributos(data['features'][0]['properties'], punto);
    }
  }
}
```

**Ventajas de WFS:** No necesitas calcular X,Y ni WIDTH/HEIGHT. Usas coordenadas directamente. Más preciso y funciona igual en cualquier zoom o tamaño de pantalla.

**Desventaja:** Necesitas saber el nombre exacto del campo de geometría de la capa (en el ejemplo: `geometria`). Verifícalo en la previsualización de GeoServer.

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