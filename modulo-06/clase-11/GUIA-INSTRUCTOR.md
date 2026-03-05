# 🎓 Guía del Instructor — Clase 11

## Exportación GeoJSON y Compatibilidad QGIS

**Duración:** 2 horas (120 minutos)
**Módulo:** 6 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Repaso | Verificar práctica Módulo 5 |
| 00:10 | 15 min | Parte 1 | Concepto: ¿Qué es GeoJSON? |
| 00:25 | 25 min | Parte 2 | Generar GeoJSON en Dart |
| 00:50 | 10 min | Descanso | |
| 01:00 | 25 min | Parte 3 | Guardar archivo y compartir |
| 01:25 | 20 min | Parte 4 | Demo en QGIS en vivo |
| 01:45 | 15 min | Cierre | Práctica, preview clase 12 |

---

## 🎬 Desarrollo

### Apertura (10 min)

> "Llevan 5 módulos construyendo una app de campo. Capturan puntos con GPS, formularios, atributos. Pero los datos están atrapados en el teléfono. Hoy los liberamos: van a exportarlos como GeoJSON — el formato universal de datos geográficos — y abrirlos en QGIS."

> "Este es el momento donde todo conecta: campo → app → escritorio."

### Parte 1 — ¿Qué es GeoJSON? (15 min)

**Muestra el JSON crudo primero.** Abre un archivo GeoJSON en un editor de texto.

> "¿Ven? Es texto plano. Cualquiera lo puede leer. Tiene coordenadas y atributos organizados de forma estándar. QGIS lo lee, ArcGIS lo lee, Google Maps lo lee, Leaflet lo lee. Es universal."

**Error que VAN a cometer:** Poner latitud antes de longitud.

> "ATENCIÓN: En GeoJSON las coordenadas van `[longitud, latitud]`. Es al revés de como estamos acostumbrados. Si ven sus puntos en el océano en vez de en La Paz, es por esto."

Escribe en la pizarra:
```
GeoJSON: [lng, lat] = [-68.13, -16.49]
Flutter:  LatLng(lat, lng) = LatLng(-16.49, -68.13)
```

### Parte 2 — Generar GeoJSON (25 min)

**Construye EN VIVO la función `generarGeoJSON()`.**

> "Vamos a recorrer cada punto capturado y convertirlo a un Feature de GeoJSON. Es como exportar una capa de QGIS."

Muestra el resultado en la consola con `print()` primero, antes de guardarlo como archivo.

### Parte 3 — Compartir (25 min)

> "El archivo se guarda en el teléfono y luego se comparte por WhatsApp, email, Google Drive — lo que quieran. Es como compartir una foto pero es un archivo de datos."

### Parte 4 — Demo QGIS (20 min)

**Este es el momento culminante del curso.** Prepáralo bien.

1. Pide a un estudiante que exporte su GeoJSON
2. Recíbelo por WhatsApp en tu computador
3. Abre QGIS
4. Carga el archivo: Capa → Agregar capa vectorial
5. Muestra los puntos en el mapa
6. Abre la tabla de atributos

> "Estos datos los capturó [nombre del estudiante] con su teléfono, con la app que construyó con sus propias manos, y ahora están en QGIS con todos sus atributos. Eso es lo que aprendieron en este curso."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Puntos en el océano | Coordenadas invertidas — [lng, lat] no [lat, lng] |
| Archivo vacío | Lista de puntos vacía — capturar puntos primero |
| Share no aparece | Verificar que share_plus está instalado |
| QGIS no abre el archivo | Verificar que la extensión sea .geojson, no .json |
| Caracteres raros en atributos | Encoding UTF-8 — debería funcionar por defecto |

## 💡 Tips

1. **Pide que capturen puntos REALES antes de clase** — mínimo 5, así tienen datos interesantes para exportar
2. **Ten geojson.io abierto** como alternativa si no tienen QGIS
3. **El demo en QGIS es el cierre emocional del módulo** — tómate el tiempo, hazlo bien