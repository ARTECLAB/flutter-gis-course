# 🎓 Guía del Instructor — Clase 10

## Lista de Registros y Vista Combinada

**Duración:** 2 horas (120 minutos)
**Módulo:** 5 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica 09 |
| 00:05 | 25 min | Parte 1 | ListView.builder + Dismissible |
| 00:30 | 20 min | Parte 2 | Edición de registros |
| 00:50 | 10 min | Descanso | |
| 01:00 | 20 min | Parte 3 | Navegación entre pantallas |
| 01:20 | 25 min | Parte 4 | BottomNavigationBar Mapa ↔ Lista |
| 01:45 | 15 min | Cierre | Resumen, preview Módulo 6 |

---

## 🎬 Desarrollo

### Parte 1 — ListView (25 min)

> "Tienen puntos guardados. Ahora necesitan verlos organizados — como una tabla de atributos en QGIS pero en formato lista móvil."

**Construye EN VIVO:**
1. ListView.builder con datos reales
2. ListTile con leading (ícono), title, subtitle
3. Dismissible para eliminar deslizando

> "Deslicen un elemento hacia la izquierda... ¿ven? Se eliminó. Es el patrón estándar de Android para borrar."

### Parte 2 — Edición (20 min)

> "El mismo formulario, pero ahora prellenado con los datos existentes. Modifican lo que necesiten y guardan."

### Parte 3 — Navegación (20 min)

**Concepto clave: Navigator**

> "Su app ahora tiene varias pantallas: Mapa, Formulario, Lista. Navigator es el sistema de Flutter para moverse entre pantallas. Es como un stack de cartas: push pone una nueva pantalla encima, pop la quita."

### Parte 4 — BottomNavigationBar (25 min)

> "Google Maps tiene una barra abajo para cambiar entre Explorar, Ir, Guardados. Nosotros ponemos Mapa y Datos."

**Preview Módulo 6:**

> "Su app está casi completa. Tiene mapa, GPS, capas WMS, formulario, lista de datos. Solo falta UNA cosa: exportar. En el Módulo 6 vamos a generar GeoJSON, que es el formato estándar para datos geográficos. Van a poder exportar sus puntos, abrirlos en QGIS, y generar el APK final."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Lista no se actualiza | setState() después de agregar/eliminar |
| Dismissible sin Key | Cada Dismissible necesita un Key único |
| Navigator.pop sin ruta | Verificar que hay ruta anterior en el stack |
| BottomNav no cambia | Verificar setState en onTap |
| IndexedStack lento | Normal con muchos widgets — considerar PageView |

## 💡 Tips

1. **Haz que capturen 5+ puntos** antes de construir la lista — así tienen datos reales para ver
2. **El momento "tabla de atributos"** es poderoso: cuando ven sus datos de campo organizados en una lista
3. **Pide que prueben cerrar y abrir la app** para confirmar que los datos persisten