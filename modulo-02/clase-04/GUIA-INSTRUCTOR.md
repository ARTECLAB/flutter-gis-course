# 🎓 Guía del Instructor — Clase 04

## Geometrías sobre el Mapa y Eventos de Interacción

**Duración:** 2 horas (120 minutos)
**Fecha:** Miércoles 25 de marzo de 2026
**Módulo:** 2 de 6

---

## ⏱️ Cronograma Detallado

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min | Repaso | Verificar práctica 03 |
| 00:05 | 25 min | Parte 1 | Polilíneas sobre el mapa |
| 00:30 | 25 min | Parte 2 | Polígonos sobre el mapa |
| 00:55 | 10 min | Descanso | Pausa |
| 01:05 | 30 min | Parte 3 | Eventos: tap, longPress, onPositionChanged |
| 01:35 | 15 min | Práctica | Práctica 04 guiada |
| 01:50 | 10 min | Cierre | Checklist, preview Módulo 3 |

---

## 🎬 Desarrollo

### Parte 1 — Polilíneas (25 min)

**Lo que dices:**
> "En GIS, una polilínea representa rutas, ríos, carreteras — cualquier línea que conecta puntos. En Flutter es exactamente igual: una lista de coordenadas unidas por segmentos."

**Construye EN VIVO:**

1. Crea una ruta real de La Paz (del Prado a San Francisco, por ejemplo)
2. Busca las coordenadas EN VIVO en Google Maps
3. Agrégalas como `List<LatLng>`
4. Muestra la PolylineLayer

> "¿Quién de ustedes ha digitalizado una línea en QGIS? Esto es lo mismo — puntos conectados formando una geometría."

Muestra variaciones: color, grosor, punteada.

### Parte 2 — Polígonos (25 min)

> "Si la polilínea es una ruta, el polígono es un área. Municipios, parcelas, zonas de estudio — todos son polígonos."

**Truco visual:** Primero muestra el polígono SIN relleno (solo borde). Luego agrega `withOpacity(0.2)` y muestra cómo se ve el área semi-transparente.

> "¿Ven? Es como en QGIS cuando ponen transparencia a una capa de polígonos para ver el mapa base debajo."

### Parte 3 — Eventos (30 min)

**Este es el momento más interactivo de la clase.**

> "Hasta ahora el usuario solo puede mirar el mapa. Ahora vamos a hacer que pueda interactuar: tocar para ver coordenadas, y mantener presionado para agregar un punto."

1. Implementa `onTap` → muestra coordenadas en SnackBar
2. Implementa `onLongPress` → agrega un marcador
3. Implementa `onPositionChanged` → actualiza barra inferior en tiempo real

> "Muevan el mapa con el dedo... ¿ven cómo las coordenadas se actualizan en tiempo real abajo? Esto es la base de la captura GPS que haremos en el Módulo 3."

**Preview Módulo 3:**
> "Ahora que saben capturar dónde toca el usuario, en las próximas dos clases vamos a conectar el GPS real del teléfono. Van a ver su posición REAL moviéndose sobre el mapa. Es donde la app se vuelve realmente una herramienta de campo."

---

## ⚠️ Errores Comunes Clase 04

| Problema | Solución |
|----------|----------|
| Polígono invisible | Agregar color con withOpacity() |
| onTap no se ejecuta | El popup intercepta el tap — usar onLongPress |
| Coordenadas no se actualizan | Falta setState() en onPositionChanged |
| Marcadores no se borran | Verificar que _marcadoresUsuario.clear() está dentro de setState |
| Polilínea no conecta bien | Verificar orden de los puntos LatLng |

## 💡 Tips

1. **Pide coordenadas a los estudiantes** — "¿Alguien de Cochabamba? Dame la coordenada de la Plaza 14 de Septiembre" → búscala en vivo
2. **Demuestra el poder del tap** — Toca varios puntos rápido en el mapa y muestra cómo aparecen los marcadores. "Esto es captura de puntos en campo"
3. **El reto del dibujo libre es muy motivante** — Si algún estudiante lo intenta, dedícale atención en la sesión de soporte