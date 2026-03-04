# 🎓 Guía del Instructor — Clase 03

## Capas Base, Cámara y Marcadores Interactivos

**Duración:** 2 horas (120 minutos)
**Fecha:** Lunes 23 de marzo de 2026
**Módulo:** 2 de 6

---

## ⏱️ Cronograma Detallado

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Repaso | Verificar práctica Módulo 1, preguntas |
| 00:10 | 30 min | Parte 1 | Múltiples capas base + selector |
| 00:40 | 25 min | Parte 2 | Control de cámara + animaciones |
| 01:05 | 10 min | Descanso | Pausa |
| 01:15 | 35 min | Parte 3 | Marcadores con popups |
| 01:50 | 10 min | Cierre | Práctica, preview clase 04 |

---

## 🎬 Desarrollo de la Clase

### Repaso (10 min)

> "¿Quién personalizó su mapa con los 4 marcadores? ¿Alguien intentó el reto del FloatingActionButton?"

Pide que 1-2 estudiantes compartan pantalla. Celebra el esfuerzo.

> "Hoy vamos a transformar ese mapa en algo que parece Google Maps: van a poder cambiar entre mapa de calles, satélite y terreno. Y al tocar un marcador, va a aparecer la información del punto."

### Parte 1 — Capas Base (30 min)

**Momento clave:** Muestra primero en Google Maps el cambio entre capas. Luego muestra en QGIS el cambio de mapa base. Finalmente hazlo en Flutter.

> "¿Ven? Es exactamente lo mismo. En QGIS cambian la capa base en el panel de capas. En Flutter cambiamos la URL del TileLayer. Mismo concepto, diferente herramienta."

**Construye EN VIVO:**
1. Primero crea la clase `TileProviders` con las URLs
2. Agrega la variable `_capaActual`
3. Implementa el `DropdownButton` paso a paso
4. Muestra el resultado: cambiar entre OSM → Satélite → Oscuro

**Error que VAN a cometer:** Olvidar el `setState()` al cambiar la capa.

> "¿Por qué no cambia? Porque no le dijimos a Flutter que algo cambió. ¿Recuerdan setState de la clase pasada? Aquí lo necesitamos."

### Parte 2 — Control de Cámara (25 min)

**Muestra movimiento instantáneo primero:**
```dart
_mapController.move(nuevoPunto, 16.0);
```

> "Funciona, pero se siente brusco. Cuando usas Google Maps, el mapa se mueve suavemente. Vamos a hacer lo mismo."

**Muestra la animación.** El código es más largo, pero el resultado vale la pena.

⚠️ **No te pierdas explicando AnimationController a fondo.** Solo di:
> "Este código hace que el movimiento sea suave en vez de instantáneo. No necesitan memorizar cómo funciona por dentro — solo saber que existe y cómo usarlo. Es un patrón que van a copiar y reutilizar."

### Parte 3 — Marcadores con Popups (35 min)

**Este es el momento favorito de los estudiantes** — ver información al tocar un marcador.

1. Instala el paquete EN VIVO: modifica pubspec.yaml, ejecuta flutter pub get
2. Construye el popup widget paso a paso
3. Reemplaza MarkerLayer con PopupMarkerLayer

> "Toquen un marcador en su teléfono... ¡ahí está! Información del punto justo como en QGIS cuando haces clic en un feature. Pero en tu teléfono, hecho por ustedes."

---

## ⚠️ Errores Comunes Clase 03

| Problema | Solución |
|----------|----------|
| Capa no cambia al seleccionar | Falta setState() en _cambiarCapa() |
| Tiles en blanco al cambiar | URL mal escrita — verificar caracteres |
| Popup no aparece | Verificar import y flutter pub get |
| Error "TickerProviderStateMixin" | Agregar `with TickerProviderStateMixin` al State |
| DropdownButton error de tipo | Verificar que value coincida con uno de los items |

---

## 💡 Tips

1. **Usa ciudades que los estudiantes conozcan** para los ejemplos de polilíneas (ej: una ruta del Prado en La Paz)
2. **El satélite impresiona** — cuando cambien a vista satélite y vean su barrio desde el espacio, hay un momento wow. Aprovéchalo.
3. **Compara siempre con QGIS** — "En QGIS hacen clic derecho en la capa y ven los atributos. Aquí tocan el marcador y ven el popup. Mismo flujo."