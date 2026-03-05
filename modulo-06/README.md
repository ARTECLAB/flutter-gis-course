# Módulo 6 · Exportación & APK Final 📤🚀

> **Clases 11 y 12 · 4 horas totales**
> Cierre del curso: exportar datos capturados como GeoJSON compatible con QGIS, compartir archivos, y generar el APK instalable de la app final.

---

## 🎯 Objetivos del Módulo

- Generar archivos GeoJSON desde los datos capturados
- Compartir archivos GeoJSON vía WhatsApp, email, etc.
- Abrir los GeoJSON exportados en QGIS (demostración en vivo)
- Configurar nombre, ícono y versión de la app
- Generar APK firmado listo para instalar
- Repaso general y cierre del curso

---

## Clase 11 — Exportación GeoJSON y Compatibilidad QGIS

### 🎯 Objetivo

Convertir los puntos capturados al formato GeoJSON estándar, guardarlo como archivo, compartirlo y verificar que se abre correctamente en QGIS.

### Parte 1 — ¿Qué es GeoJSON? (15 min)

#### Concepto

GeoJSON es un formato estándar para representar datos geográficos en texto JSON. Es el formato más universal de intercambio de datos GIS — lo leen QGIS, ArcGIS, PostGIS, MapBox, Google Maps, Leaflet, y cualquier herramienta moderna.

#### Estructura de un GeoJSON

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-68.1336, -16.4955]
      },
      "properties": {
        "nombre": "Plaza Murillo",
        "tipo": "Plaza",
        "estado": "Bueno",
        "fecha": "2026-04-07T10:30:00"
      }
    }
  ]
}
```

**Puntos clave:**
- `FeatureCollection` = una colección de features (como una capa en QGIS)
- Cada `Feature` tiene `geometry` (dónde) y `properties` (atributos)
- Las coordenadas van en orden `[longitud, latitud]` — ¡OJO! Es al revés de como las mostramos habitualmente

⚠️ **Error #1 del módulo:** Poner `[latitud, longitud]` en vez de `[longitud, latitud]`. En GeoJSON la longitud va primero.

### Parte 2 — Generar GeoJSON en Dart (25 min)

```dart
import 'dart:convert';

/// Convierte la lista de puntos capturados a GeoJSON
String generarGeoJSON(List<Map<String, dynamic>> puntos) {
  final features = puntos.map((p) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [p['longitud'], p['latitud']], // ¡lng, lat!
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
```

### Parte 3 — Guardar archivo y compartir (25 min)

#### Dependencias necesarias

```yaml
dependencies:
  path_provider: ^2.1.0
  share_plus: ^9.0.0
```

#### Guardar archivo

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> _guardarGeoJSON() async {
  final geojsonStr = generarGeoJSON(_puntos);
  final dir = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${dir.path}/geocollect_$timestamp.geojson');
  await file.writeAsString(geojsonStr);
  return file;
}
```

#### Compartir archivo

```dart
import 'package:share_plus/share_plus.dart';

Future<void> _exportarGeoJSON() async {
  if (_puntos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay puntos para exportar')),
    );
    return;
  }

  final file = await _guardarGeoJSON();
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Datos GeoCollect — ${_puntos.length} puntos',
    subject: 'Exportación GeoCollect',
  );
}
```

### Parte 4 — Demostración en QGIS (15 min)

1. Exportar GeoJSON desde la app
2. Enviarlo por email o WhatsApp al computador
3. Abrir en QGIS: Capa → Agregar capa → Agregar capa vectorial
4. Verificar que los puntos, atributos y coordenadas son correctos

> "Datos capturados con su app móvil, abiertos en QGIS. El ciclo completo: campo → app → escritorio."

---

### 💻 Práctica 11

1. Implementa `generarGeoJSON()` que convierta los puntos a formato GeoJSON
2. Agrega un botón "Exportar" en el AppBar que genere y comparta el archivo
3. Verifica que el archivo se abra correctamente en un visor GeoJSON online (geojson.io)
4. Si tienes QGIS disponible, abre el archivo y verifica los atributos

### ✅ Checklist Clase 11

- [ ] Función generarGeoJSON() implementada
- [ ] Coordenadas en orden correcto: [longitud, latitud]
- [ ] Archivo .geojson se guarda en el teléfono
- [ ] Compartir vía WhatsApp/email funciona
- [ ] Archivo se abre correctamente en geojson.io o QGIS

---

## Clase 12 — Generación de APK y Cierre del Curso

### 🎯 Objetivo

Configurar la identidad de la app, generar el APK firmado, instalar en otros teléfonos, y cerrar el curso con repaso general.

### Parte 1 — Configuración de la app (20 min)

#### Cambiar nombre de la app

En `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="GeoCollect"
    ...>
```

#### Cambiar el ID del paquete

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

#### Agregar ícono personalizado

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icon.png"
```

```bash
dart run flutter_launcher_icons
```

### Parte 2 — Generar APK firmado (25 min)

#### Crear keystore (una sola vez)

```bash
keytool -genkey -v -keystore ~/geocollect-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias geocollect
```

#### Configurar firma

Crear `android/key.properties`:
```properties
storePassword=tupassword
keyPassword=tupassword
keyAlias=geocollect
storeFile=/ruta/a/geocollect-key.jks
```

#### En `android/app/build.gradle`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Generar APK

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`

### Parte 3 — Instalación en otros teléfonos (10 min)

1. Enviar APK por WhatsApp, Google Drive, o cable USB
2. El teléfono receptor necesita activar "Instalar de fuentes desconocidas"
3. Abrir el APK e instalar

### Parte 4 — Repaso y Cierre del Curso (30 min)

#### Lo que construyeron en 6 semanas

| Módulo | Lo que aprendieron | Lo que construyeron |
|--------|-------------------|-------------------|
| 1 | Dart, Flutter, Widgets | Mapa con marcadores |
| 2 | Capas, Popups, Geometrías | Selector de capas, polilíneas, polígonos |
| 3 | GPS, Permisos, Streams | Seguimiento GPS en tiempo real |
| 4 | WMS, CQL, GetFeatureInfo | Conexión con GeoServer |
| 5 | Formularios, Persistencia | Captura de datos en campo |
| 6 | GeoJSON, APK | App completa exportable |

> "Empezaron sin saber programar. Ahora tienen una app Android funcional que captura puntos GPS con atributos, se conecta a servidores GIS, y exporta datos compatibles con QGIS. Eso es real."

---

### 💻 Práctica 12

1. Configura el nombre y applicationId de tu app
2. Genera el APK con `flutter build apk --release`
3. Instala el APK en otro teléfono Android
4. Captura al menos 3 puntos, exporta el GeoJSON, y verifica en QGIS o geojson.io

### ✅ Checklist Clase 12

- [ ] Nombre de app personalizado
- [ ] APK generado exitosamente
- [ ] APK instalado en otro teléfono
- [ ] Flujo completo: captura → exporta → abre en QGIS

---

## 📝 Errores comunes

1. **Coordenadas invertidas en GeoJSON** → GeoJSON usa [longitud, latitud], NO [latitud, longitud]
2. **Share no funciona** → Verificar permisos de escritura y que el archivo se creó
3. **APK no instala** → Activar "fuentes desconocidas" en el teléfono receptor
4. **Build falla** → Verificar que no haya errores de compilación con `flutter analyze`
5. **Keystore perdido** → Sin el keystore no puedes actualizar la app. ¡Guárdalo en lugar seguro!
6. **Ícono no cambia** → Ejecutar `dart run flutter_launcher_icons` y rebuild