# 🎓 Guía del Instructor — Clase 07

## ¿Qué es GeoServer? Tu primera capa WMS

**Duración:** 2 horas (120 minutos)
**Módulo:** 4 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Repaso | Verificar práctica Módulo 3, preguntas GPS |
| 00:10 | 20 min | Parte 1 | Concepto: GeoServer, WMS, arquitectura |
| 00:30 | 30 min | Parte 2 | Conectar primera capa WMS EN VIVO |
| 01:00 | 10 min | Descanso | |
| 01:10 | 25 min | Parte 3 | Múltiples capas + Drawer toggle |
| 01:35 | 15 min | Práctica | Práctica 07 guiada |
| 01:50 | 10 min | Cierre | Preview clase 08 |

---

## 🎬 Desarrollo

### Apertura (10 min)

> "Hasta ahora su app tiene mapa base de OSM, GPS, marcadores, polilíneas. Todo eso son datos que ustedes pusieron a mano en el código. Hoy su app va a consumir datos de un SERVIDOR — un GeoServer real. Es el mismo tipo de servidor que usan las empresas de cartografía, el gobierno, las instituciones ambientales."

> "¿Han usado QGIS para conectarse a un servicio WMS? Hoy hacen lo mismo pero desde su app móvil."

### Parte 1 — GeoServer y WMS (20 min)

**Pregunta al grupo:**
> "¿Alguien sabe qué hace un servidor GIS? ¿Cómo llevan datos de QGIS a una aplicación web?"

**Usa la analogía del restaurante.** Dibuja en pizarra:

```
[Base de datos / Shapefiles] → [GeoServer (cocina)] → [WMS (menú)] → [Tu App (cliente)]
```

> "Ustedes como profesionales GIS trabajan con los ingredientes — los shapefiles, las bases PostGIS. GeoServer los cocina y los sirve. Tu app solo pide el plato."

**Momento clave:** Abre el navegador y muestra una URL WMS real. Pegala en el navegador y muestra que devuelve una IMAGEN. Eso es WMS — imágenes.

> "¿Ven? Es solo una imagen PNG. Pero generada dinámicamente por el servidor según la zona y zoom que pides."

### Parte 2 — Primera capa WMS (30 min)

**Construye EN VIVO:**

1. Muestra la URL del GeoServer de práctica
2. Construye el WMSTileLayerOptions paso a paso
3. **Momento wow:** Cuando la capa WMS aparece sobre OSM

> "¿Ven departamentos de Bolivia con colores sobre el mapa? Esos datos están en el servidor. Su app solo los pidió y los mostró. No descargaron ningún shapefile."

**Error que van a cometer:** Olvidar el `?` al final de baseUrl.

### Parte 3 — Múltiples capas + Drawer (25 min)

> "En QGIS tienen un panel de capas donde activan y desactivan capas con un checkbox. Vamos a hacer exactamente eso."

Implementa el Drawer con SwitchListTile EN VIVO.

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Capa en blanco / no aparece | Verificar URL exacta, nombre workspace:capa |
| Falta `?` en baseUrl | Agregar `?` al final de la URL base |
| Capa desalineada | Verificar que SRS sea EPSG:4326 |
| Error de red | Verificar que el teléfono tiene internet y el servidor está online |
| Tiles gris/error | Nombre de capa incorrecto o servidor no accesible |

## 💡 Tips

1. **Prepara el GeoServer ANTES de la clase.** Verifica que todas las capas estén publicadas y accesibles.
2. **Muestra primero en QGIS, luego en Flutter.** Conecta QGIS al mismo WMS para que vean que es el mismo resultado.
3. **Si alguien administra GeoServer:** aprovecha para explicar cómo se publica una capa (extra, no obligatorio).