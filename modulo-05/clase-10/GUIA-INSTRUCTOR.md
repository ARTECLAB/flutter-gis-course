# 🎓 Guía del Instructor — Clase 10

## Exportación GeoJSON, Generación de APK y Cierre del Curso

**Duración:** 2 horas (120 minutos)
**Módulo:** 5 de 5 — ÚLTIMA CLASE

> Esta clase fusiona lo que antes eran dos clases (GeoJSON, y APK+cierre). Es la última clase del curso: el ritmo debe sentirse como un cierre, no como otra clase técnica más — deja tiempo real para el repaso y el feedback al final.

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica 09 |
| 00:05 | 15 min | Parte 1 | ¿Qué es GeoJSON? + el error de coordenadas invertidas |
| 00:20 | 20 min | Parte 2 | Generar GeoJSON en Dart (función en vivo) |
| 00:40 | 15 min | Parte 3 | Guardar archivo y compartir |
| 00:55 | 10 min | Descanso | |
| 01:05 | 15 min | Parte 4 | Configurar identidad de la app |
| 01:20 | 15 min | Parte 5 | Generar APK release + instalar en otro teléfono |
| 01:35 | 10 min | Parte 6 | Demo final: ciclo completo capturar → exportar → QGIS |
| 01:45 | 15 min | Cierre | Repaso por módulo, hacia dónde llevar GeoCollect, feedback |

---

## 🎬 Desarrollo

### Apertura (5 min)

> "Llevan 5 módulos construyendo una app de campo. Hoy cerramos el ciclo: van a exportar sus datos a GeoJSON, abrirlos en QGIS, y generar el APK — el archivo instalable que pueden compartir con cualquiera."

### Parte 1 — ¿Qué es GeoJSON? (15 min)

**Muestra el JSON crudo primero.** Abre un archivo GeoJSON en un editor de texto.

> "Es texto plano que QGIS, ArcGIS, Google Maps y Leaflet leen todos por igual. Es universal."

**Error que VAN a cometer:** poner latitud antes de longitud. Escribe en la pizarra:
```
GeoJSON: [lng, lat] = [-68.13, -16.49]
Flutter:  LatLng(lat, lng) = LatLng(-16.49, -68.13)
```

### Parte 2 — Generar GeoJSON (20 min)

**Construye EN VIVO la función `generarGeoJSON()`.** Muestra el resultado con `print()` antes de guardarlo como archivo.

### Parte 3 — Compartir (15 min)

> "El archivo se guarda en el teléfono y se comparte por WhatsApp, email o Drive — igual que compartir una foto, pero es un archivo de datos."

### Descanso (10 min)

### Parte 4 — Configurar identidad de la app (15 min)

> "Su app se llama GeoCollect pero todavía usa el nombre genérico de Flutter. Vamos a personalizarla: nombre real, applicationId, versión 1.0."

EN VIVO: cambiar `android:label` en AndroidManifest.xml → cambiar `applicationId` en build.gradle.

### Parte 5 — Generar APK (15 min)

> "Hasta ahora usamos `flutter run`, modo desarrollo. El APK release es la versión limpia y optimizada que cualquiera puede instalar."

```bash
flutter build apk --release
```

> "Para publicar en Google Play necesitarían firmar el APK con un keystore propio — para instalar directo en teléfonos, como hacemos hoy, no es obligatorio."

Comparte por WhatsApp/Drive con un compañero, que active "fuentes desconocidas" y lo instale.

### Parte 6 — Demo final (10 min, si alcanza el tiempo)

**Ciclo completo EN VIVO:** abrir la app → activar GPS → capturar 2-3 puntos con formulario → ver la lista → exportar GeoJSON → abrir en QGIS (o geojson.io si no hay QGIS a mano).

> "Estos datos los capturó [nombre del estudiante] con la app que construyó con sus propias manos, y ahora están en QGIS con todos sus atributos."

Si no alcanza el tiempo en vivo, queda como cierre de la Práctica 10 que cada estudiante hace por su cuenta.

### Cierre (15 min)

**Repaso por módulo (pide participación):**

> "¿Qué construyeron en el Módulo 1?" → mapa con marcadores
> "¿Y en el 2?" → capas, popups, geometrías
> "¿El 3?" → GPS real en tiempo real
> "¿El 4?" → conexión con GeoServer
> "¿Y hoy?" → GeoCollect completo, exportable e instalable

**Hacia dónde llevar GeoCollect:** repasa con el grupo las ideas del material (modo offline, sincronización WFS-T, fotos por punto, más formatos de exportación) y recuerda el hilo de IA usado en todo el curso — la misma disciplina de "entender antes de pegar" les sirve para explorar cualquiera de esas ideas por su cuenta.

**Feedback:** pide feedback honesto — qué funcionó, qué mejorar.

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Puntos en el océano | Coordenadas invertidas — [lng, lat] no [lat, lng] |
| Archivo vacío | Lista de puntos vacía — capturar puntos primero |
| Share no aparece | Verificar que share_plus está instalado |
| QGIS no abre el archivo | Verificar que la extensión sea .geojson, no .json |
| Build de APK falla | Revisar mensaje completo; suele ser versión de Gradle/SDK |

## 💡 Tips para el cierre

1. **Pide que capturen puntos REALES antes de clase** — mínimo 5, así tienen datos interesantes para exportar.
2. **Ten geojson.io abierto** como alternativa si no tienen QGIS a mano.
3. **Celebra el logro** — empezaron programando widgets básicos y terminan con una app de campo funcional conectada a un servidor GIS real.
4. **Ofrece soporte post-curso** (grupo de WhatsApp, sesión de dudas) si es viable.
