# Módulo 5 · Captura de Datos, Exportación & APK Final 📍📤🚀

> **Clases 09 y 10 · 4 horas totales · Módulo final**
> Tu app se convierte en herramienta de campo real: formularios de captura, almacenamiento local persistente, lista de registros, vista combinada mapa + datos, exportación a GeoJSON compatible con QGIS, y generación del APK instalable.

---

## 🎯 Objetivos del Módulo

- Crear formularios de captura con validación
- Almacenar datos localmente con SharedPreferences y JSON
- Listar, eliminar y (como reto extra) editar registros capturados
- Vista combinada: mapa con puntos + lista de datos, con BottomNavigationBar
- Exportar datos como GeoJSON válido y compatible con QGIS
- Configurar la identidad de la app y generar el APK instalable

---

## Clase 09 — Formularios, Almacenamiento Local y Lista de Registros

### 🎯 Objetivo

Crear un formulario profesional para registrar puntos de campo con atributos, guardarlos de forma persistente, mostrarlos en una lista editable, y combinar mapa + lista con navegación inferior.

### Parte 1 — ¿Qué es un formulario de captura en campo?

En trabajo de campo, no basta con capturar una coordenada GPS. Necesitas registrar atributos: ¿qué tipo de punto es?, ¿en qué estado está?, ¿alguna observación? En QGIS, cuando digitalizas un punto, se abre una ventana de atributos. En tu app, se abre un formulario.

### Parte 2 — Widgets de Formulario en Flutter

```dart
final _formKey = GlobalKey<FormState>();
final _nombreCtrl = TextEditingController();
final _observacionCtrl = TextEditingController();
String? _tipo;
String _estado = 'Bueno';

Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: _nombreCtrl,
        decoration: const InputDecoration(
          labelText: 'Nombre *',
          prefixIcon: Icon(Icons.label),
          border: OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
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
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => setState(() => _tipo = v),
        validator: (v) => v == null ? 'Selecciona tipo' : null,
      ),
      const SizedBox(height: 12),
      const Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
      ...['Bueno', 'Regular', 'Malo'].map((e) => RadioListTile(
            title: Text(e),
            value: e,
            groupValue: _estado,
            onChanged: (v) => setState(() => _estado = v!),
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
    ],
  ),
)
```

Al guardar, valida con `_formKey.currentState!.validate()` y arma un `Map` con id, atributos, coordenadas (`widget.posicion.latitude/longitude`) y fecha (`DateTime.now().toIso8601String()`).

### Parte 3 — Almacenamiento Local con SharedPreferences

Cuando capturas datos en campo, muchas veces NO tienes internet. SharedPreferences guarda la lista como texto JSON en el almacenamiento del teléfono, y persiste aunque cierres la app.

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> _guardarPuntos() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('puntos_campo', json.encode(_puntosCapturados));
}

Future<void> _cargarPuntos() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('puntos_campo');
  if (jsonString != null) {
    final List<dynamic> lista = json.decode(jsonString);
    setState(() {
      _puntosCapturados = lista.map((item) => Map<String, dynamic>.from(item)).toList();
    });
  }
}
```

🤖 **Tip con IA:** la lógica de validación (qué es obligatorio, qué rango es válido) la decides tú; pedirle a la IA que genere variantes de `validator` ya escritos por ti es un buen uso de tiempo, pedirle que invente las reglas de negocio no lo es.

### Parte 4 — Lista de Registros y Vista Combinada

```dart
ListView.builder(
  itemCount: puntos.length,
  itemBuilder: (ctx, i) {
    final p = puntos[i];
    return Dismissible(
      key: Key(p['id'].toString()),
      background: Container(color: Colors.red),
      onDismissed: (_) {
        setState(() => puntos.removeAt(i));
        _guardarPuntos();
      },
      child: ListTile(
        leading: Icon(Icons.location_on),
        title: Text(p['nombre']),
        subtitle: Text('${p['tipo']} · ${p['estado']}'),
        trailing: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () => onVerEnMapa(LatLng(p['latitud'], p['longitud'])),
        ),
      ),
    );
  },
)
```

Combina mapa y lista con `IndexedStack` + `BottomNavigationBar` (mantiene el estado del mapa al cambiar de pestaña):

```dart
int _pantallaActual = 0;

Scaffold(
  body: IndexedStack(
    index: _pantallaActual,
    children: [_buildMapa(), _buildLista()],
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _pantallaActual,
    onTap: (i) => setState(() => _pantallaActual = i),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Datos'),
    ],
  ),
)
```

---

### 💻 Práctica 09

1. Crea `FormularioPunto` con campos: nombre, tipo (dropdown), estado (radio), observación. Valida nombre y tipo como obligatorios.
2. Al guardar, agrega el punto a la lista, guarda en SharedPreferences y cierra el formulario. Carga los puntos guardados al iniciar la app.
3. Crea la lista con `ListView.builder` + `Dismissible` para eliminar deslizando.
4. Botón "Ver en mapa" que centra el mapa en ese punto.
5. `BottomNavigationBar` con `IndexedStack` para alternar Mapa ↔ Datos, con contador de puntos.

### 🚀 Reto Extra — Edición y búsqueda

Reutiliza `FormularioPunto` en modo edición (prellenando los campos existentes) y agrega un `TextField` de búsqueda que filtre la lista por nombre o tipo.

### ✅ Checklist Clase 09

- [ ] Formulario con TextFormField, Dropdown, Radio — validación funcional
- [ ] Datos se guardan y persisten en SharedPreferences
- [ ] Punto capturado aparece como marcador en el mapa
- [ ] Lista con ListView.builder + Dismissible
- [ ] BottomNavigationBar Mapa ↔ Datos con IndexedStack

---

## Clase 10 — Exportación GeoJSON, APK y Cierre del Curso

### 🎯 Objetivo

Convertir los puntos capturados a GeoJSON, compartirlo, verificarlo en QGIS, configurar la identidad de la app, generar el APK instalable, y cerrar el curso.

### Parte 1 — ¿Qué es GeoJSON?

Formato estándar de texto JSON para datos geográficos. Lo leen QGIS, ArcGIS, PostGIS, MapBox, Google Maps, Leaflet y cualquier herramienta moderna.

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": { "type": "Point", "coordinates": [-68.1336, -16.4955] },
      "properties": { "nombre": "Plaza Murillo", "tipo": "Plaza", "estado": "Bueno" }
    }
  ]
}
```

⚠️ **Error #1:** las coordenadas van `[longitud, latitud]` — al revés de cómo las manejamos en Flutter (`LatLng(lat, lng)`). Si los puntos aparecen en el océano, es por esto.

### Parte 2 — Generar y exportar GeoJSON

```dart
import 'dart:convert';

String generarGeoJSON(List<Map<String, dynamic>> puntos) {
  final features = puntos.map((p) => {
    'type': 'Feature',
    'geometry': {
      'type': 'Point',
      'coordinates': [p['longitud'], p['latitud']], // ¡lng, lat!
    },
    'properties': {
      'nombre': p['nombre'], 'tipo': p['tipo'],
      'estado': p['estado'], 'fecha': p['fecha'],
    },
  }).toList();

  return const JsonEncoder.withIndent('  ')
      .convert({'type': 'FeatureCollection', 'features': features});
}
```

```yaml
dependencies:
  path_provider: ^2.1.0
  share_plus: ^9.0.0
```

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _exportar() async {
  final texto = generarGeoJSON(_puntos);
  final dir = await getApplicationDocumentsDirectory();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final archivo = File('${dir.path}/geocollect_$ts.geojson');
  await archivo.writeAsString(texto);
  await Share.shareXFiles([XFile(archivo.path)], text: 'GeoCollect — ${_puntos.length} puntos');
}
```

Verifica el resultado en [geojson.io](https://geojson.io) o abriéndolo en QGIS como capa vectorial.

### Parte 3 — Configurar la app y generar el APK

En `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="GeoCollect" ...>
```

En `android/app/build.gradle`:
```groovy
defaultConfig {
    applicationId "com.tuempresa.geocollect"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

Genera el APK release (suficiente para instalar directo en teléfonos):
```bash
flutter build apk --release
```
El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

#### Avanzado (opcional) — Firmar el APK para Google Play

Solo necesario si planeas publicar en la Play Store, no para instalar directo:

```bash
keytool -genkey -v -keystore ~/geocollect-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias geocollect
```

Crea `android/key.properties` con `storePassword`, `keyPassword`, `keyAlias` y `storeFile`, y configura `signingConfigs`/`buildTypes` en `android/app/build.gradle` para que `release` use esa firma. **Guarda el keystore en un lugar seguro** — sin él no puedes actualizar la app publicada.

Para un ícono personalizado:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
flutter_launcher_icons:
  android: true
  image_path: "assets/icon.png"
```
```bash
dart run flutter_launcher_icons
```

### Parte 4 — Repaso y Cierre del Curso

| Módulo | Lo que aprendiste | Lo que construiste |
|--------|-------------------|---------------------|
| 1 | Widgets, setState, flutter_map | Mapa con marcadores |
| 2 | Capas, popups, geometrías, eventos | Selector de capas, polilíneas/polígonos |
| 3 | GPS, permisos, streams, distancias | Seguimiento GPS en tiempo real |
| 4 | WMS, CQL, GetFeatureInfo | Conexión con GeoServer real |
| 5 | Formularios, persistencia, GeoJSON, APK | GeoCollect completo, exportable e instalable |

> "Empezaron ya sabiendo programar, pero sin Flutter ni GIS móvil. Ahora tienen una app Android funcional que captura puntos GPS con atributos, se conecta a un servidor GIS real, y exporta datos compatibles con QGIS. Eso es real."

**Hacia dónde seguir:** modo offline con tiles cacheados, sincronización WFS-T con GeoServer, fotos georeferenciadas por punto, más formatos de exportación (KML, CSV), publicación en Google Play. La misma disciplina de usar la IA como copiloto —entender antes de pegar, verificar antes de confiar— aplica a cualquiera de estas extensiones.

---

### 💻 Práctica 10 — Cierre del curso

1. Implementa `generarGeoJSON()` con coordenadas en orden `[longitud, latitud]`.
2. Botón "Exportar" en el AppBar que genere y comparta el archivo.
3. Verifica el archivo en geojson.io o QGIS.
4. Configura nombre y `applicationId`, genera el APK con `flutter build apk --release` e instálalo en un teléfono.
5. Ciclo completo: captura 3 puntos → exporta → verifica en QGIS/geojson.io.

### ✅ Checklist Final

- [ ] generarGeoJSON() implementada, coordenadas en orden [lng, lat]
- [ ] Archivo .geojson se guarda, comparte y verifica en geojson.io o QGIS
- [ ] Nombre y applicationId configurados
- [ ] APK generado e instalado en un teléfono
- [ ] Ciclo completo: captura → exporta → QGIS
- [ ] 🎉 ¡Curso completado!

---

## 📝 Errores comunes del módulo

1. **Datos no persisten** → Verificar que llamas `_guardarPuntos()` después de cada cambio.
2. **Error JSON al cargar** → Datos corruptos; limpiar con `prefs.remove('puntos_campo')`.
3. **Coordenadas invertidas en GeoJSON** → Usa `[longitud, latitud]`, no `[latitud, longitud]`.
4. **Share no funciona** → Verificar que el archivo se creó antes de compartir.
5. **APK no instala** → Activar "fuentes desconocidas" en el teléfono receptor.
6. **Build de APK falla** → Revisar el mensaje completo; suele ser versión de Gradle/SDK.
7. **Keystore perdido** → Sin él no puedes actualizar una app ya publicada. Guárdalo en un lugar seguro.
