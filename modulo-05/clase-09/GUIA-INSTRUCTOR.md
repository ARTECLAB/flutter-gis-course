# 🎓 Guía del Instructor — Clase 09

## Formularios, Almacenamiento Local y Lista de Registros

**Duración:** 2 horas (120 minutos)
**Módulo:** 5 de 5

> Esta clase fusiona lo que antes eran dos clases (formularios+storage, y lista+navegación). Es la clase más densa del curso — ve con ritmo firme y no te detengas demasiado en cada widget, todos son variaciones del mismo patrón (controller + validator + setState).

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica Módulo 4, preguntas WMS |
| 00:05 | 20 min | Parte 1 | Widgets de formulario + validación (Form, TextFormField, Dropdown, Radio) |
| 00:25 | 20 min | Parte 2 | SharedPreferences — guardar y cargar JSON |
| 00:45 | 10 min | Descanso | |
| 00:55 | 20 min | Parte 3 | ListView.builder + Dismissible |
| 01:15 | 15 min | Parte 4 | Navigator — conectar el formulario como pantalla |
| 01:30 | 20 min | Parte 5 | BottomNavigationBar + IndexedStack (mapa ↔ lista) |
| 01:50 | 10 min | Cierre | Práctica, reto extra, checklist, preview clase 10 |

---

## 🎬 Desarrollo

### Apertura (5 min)

> "Su app ya tiene mapa, GPS, capas WMS. Pero capturar un punto GPS sin atributos es como tomar una foto sin descripción — no sirve de mucho. Hoy le agregamos el FORMULARIO, el ALMACENAMIENTO y la LISTA. Al final de esta clase su app va a verse y comportarse como una herramienta de campo real."

### Parte 1 — Widgets de formulario (20 min)

**Concepto clave: Form + GlobalKey**

> "Form es un widget contenedor que agrupa todos los campos. El GlobalKey es como un control remoto: te permite validar todos los campos a la vez con un solo comando."

**Construye EN VIVO, rápido:**
1. Un `TextFormField` con su `validator`
2. Un `DropdownButtonFormField` con 4-5 opciones
3. Un `RadioListTile` para estado (bueno/regular/malo)
4. `_formKey.currentState!.validate()` validando todo de una

**Momento impactante:** presionar "Guardar" sin llenar campos y que aparezcan los mensajes de error rojos.

🤖 **Nota IA:** si alguien quiere acelerar escribiendo los 3-4 validators casi idénticos, es buen momento para mostrar cómo pedirle a la IA las variantes — pero solo después de que escribieron y entendieron el primero ellos mismos.

### Parte 2 — SharedPreferences (20 min)

> "¿Qué pasa si cierran la app? Hasta ahora los datos viven solo en memoria — se pierden. SharedPreferences los guarda en el almacenamiento del teléfono, como un archivo."

**Demuestra EN VIVO:** captura un punto → cierra la app completamente → ábrela → los datos siguen ahí.

### Descanso (10 min)

### Parte 3 — ListView.builder + Dismissible (20 min)

> "Tienen puntos guardados. Ahora necesitan verlos organizados — como una tabla de atributos en QGIS pero en formato lista móvil."

**Construye EN VIVO:** `ListView.builder` con datos reales → `ListTile` (leading/title/subtitle) → envolver en `Dismissible` para eliminar deslizando.

> "Deslicen un elemento hacia la izquierda... ¿ven? Se eliminó. Es el patrón estándar de Android para borrar."

### Parte 4 — Navigator (15 min)

> "Su app ahora tiene varias pantallas: Mapa, Formulario, Lista. Navigator es como un stack de cartas: push pone una pantalla nueva encima, pop la quita."

### Parte 5 — BottomNavigationBar + IndexedStack (20 min)

> "Google Maps tiene una barra abajo para cambiar entre Explorar, Ir, Guardados. Nosotros ponemos Mapa y Datos — con IndexedStack para que el mapa no se reinicie al cambiar de pestaña."

**Preview Clase 10:**

> "Su app está casi completa. Solo falta exportar. En la próxima y última clase van a generar GeoJSON para abrir sus datos en QGIS, y van a generar el APK final — el archivo que instalan en cualquier teléfono."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Formulario no valida | Verificar que Form tiene key y que cada campo tiene validator |
| Controller no actualiza | Usar controller.text para leer el valor |
| SharedPreferences error | Verificar `await` y que el import sea correcto |
| LatLng no se guarda en JSON | Guardar lat y lng como doubles separados |
| Teclado tapa el formulario | Envolver en SingleChildScrollView |
| Lista no se actualiza | setState() después de agregar/eliminar |
| Dismissible sin Key | Cada Dismissible necesita un Key único |
| BottomNav no cambia | Verificar setState en onTap |

## 💡 Tips

1. **Usa SingleChildScrollView** para que el formulario sea scrolleable cuando el teclado aparece.
2. **Muestra las coordenadas como solo lectura** — el usuario no debe poder editarlas.
3. **Haz que capturen 5+ puntos** antes de construir la lista, así tienen datos reales.
4. **El reto extra de edición y búsqueda** (en el material del alumno) queda para quienes terminan rápido o como tarea — no hay tiempo de cubrirlo en las 2 horas de clase.
