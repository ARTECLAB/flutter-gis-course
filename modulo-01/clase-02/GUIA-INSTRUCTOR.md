# 🎓 Guía del Instructor — Clase 02

## Widgets Flutter y Tu Primer Mapa Interactivo

**Duración:** 2 horas (120 minutos)
**Fecha:** Miércoles 18 de marzo de 2026
**Módulo:** 1 de 6

---

## 📋 Antes de la Clase

### Preparación (30 min antes)

- [ ] Proyecto `geo_collect` con mapa funcionando en tu teléfono
- [ ] Versión final de la Clase 02 lista como respaldo
- [ ] Coordenadas de 4-5 lugares conocidos de La Paz (o la ciudad del grupo) listas
- [ ] Captura de pantalla de una tabla de atributos de QGIS para la analogía de widgets
- [ ] Google Maps abierto para buscar coordenadas en vivo

---

## ⏱️ Cronograma Detallado

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min | Repaso | Verificar que todos tienen el proyecto corriendo |
| 00:05 | 25 min | Parte 1 | Cómo Flutter construye interfaces — widgets |
| 00:30 | 25 min | Parte 2 | Widgets esenciales para nuestra app |
| 00:55 | 10 min | Descanso | Pausa |
| 01:05 | 35 min | Parte 3 | Integrar flutter_map — mapa real |
| 01:40 | 10 min | Parte 4 | Enriquecer: marcador + barra de info |
| 01:50 | 10 min | Cierre | Práctica 02, checklist, preview Módulo 2 |

---

## 🎬 Desarrollo de la Clase

### Repaso Rápido (5 min)

> "Antes de arrancar — ¿quién completó la Práctica 01? ¿Alguien quiere compartir su pantalla y mostrar sus puntos geográficos?"

Si alguien levanta la mano, dale 2 minutos para mostrar. Si nadie, muestra tu solución rápidamente.

> "Hoy es el día que muchos estaban esperando. Al final de esta clase van a tener un mapa REAL de OpenStreetMap en su teléfono, no un contador ni un texto — un mapa de verdad."

---

### Parte 1 — Widgets (25 min)

**Momento clave — La analogía con QGIS:**

Muestra esta comparación en pantalla (puedes dibujarla o tenerla en una slide):

```
QGIS                          Flutter
─────────────────             ─────────────────
Proyecto (.qgz)         →     MaterialApp
Vista de mapa           →     Scaffold
Panel de capas          →     Column de widgets
Capa de OpenStreetMap   →     TileLayer
Capa de puntos          →     MarkerLayer
Tabla de atributos      →     ListView
Barra de herramientas   →     AppBar + FloatingActionButton
```

> "¿Ven? Ya saben construir interfaces — lo han hecho en QGIS toda su vida. Ahora vamos a hacerlo en Flutter."

**StatelessWidget vs StatefulWidget:**
> "Piensen en una capa estática vs una capa que se actualiza con GPS. El título de la app no cambia — es StatelessWidget. El mapa cambia de zoom, posición, recibe datos — es StatefulWidget."

**setState — Código en vivo:**

Escribe un ejemplo simple en main.dart temporal:
```dart
int _contadorPuntos = 0;

void _agregarPunto() {
  setState(() {
    _contadorPuntos++;
  });
}
```

> "setState es como darle F5 a la pantalla — le dice a Flutter 'oye, algo cambió, actualízate'."

---

### Parte 2 — Widgets Esenciales (25 min)

**Estrategia:** Construye una interfaz simple EN VIVO que tenga Column, Row, Container, Expanded. No uses el mapa todavía — solo widgets de texto y colores.

> "Antes de meter el mapa, necesitamos entender cómo organizar las cosas en la pantalla."

Construye paso a paso:
1. Un Scaffold con AppBar → "Esta es la estructura base"
2. Un Column con dos textos → "Column apila cosas verticalmente"
3. Un Row dentro del Column → "Row las pone lado a lado"
4. Un Container con color → "Container es como una caja que puedes decorar"
5. Un Expanded → "Expanded dice: ocupa todo el espacio que queda"

**Haz que los estudiantes predigan antes de ejecutar:**
> "Si pongo este Text dentro de un Row con otro Text... ¿cómo creen que se va a ver? ¿Uno al lado del otro o uno debajo del otro?"

---

### Descanso (10 min)

> "Pausa. Cuando volvamos, instalamos el mapa."

---

### Parte 3 — Integrar flutter_map (35 min)

**Este es el momento estrella de la clase.** Haz todo EN VIVO y con calma.

**Paso 1 — Agregar dependencias (5 min):**

> "Vamos a instalar un paquete que nos da el widget de mapa. Es como instalar un plugin en QGIS."

Abre `pubspec.yaml` EN VIVO. Muestra la estructura del archivo.

⚠️ **ERROR COMÚN:** La indentación. Muestra:
> "YAML es estricto con los espacios. Tienen que ser espacios, NO tabs. Y la indentación tiene que ser exacta. Si les sale error rojo, lo primero que revisan es esto."

Ejecuta `flutter pub get`. Espera a que termine.

**Paso 2 — Permiso de Internet (3 min):**

> "Android por defecto NO deja que tu app acceda a internet. Necesitamos darle permiso explícitamente. Si no hacen esto, el mapa se ve en blanco."

Abre `AndroidManifest.xml` y agrega la línea.

**Paso 3 — Escribir el código del mapa (20 min):**

> "Ahora sí. Vamos a reemplazar todo el contenido de main.dart."

**NO copies y pegues todo de una vez.** Escríbelo sección por sección:

1. Primero los imports → explica cada uno
2. Luego `main()` y `GeoCollectApp` → "Este es el punto de entrada"
3. Luego `MapaScreen` como StatefulWidget → "¿Por qué StatefulWidget? Porque el mapa cambia"
4. Luego el Scaffold con FlutterMap → "Aquí viene la magia"
5. Luego el TileLayer → "Esta es nuestra capa base, como OpenStreetMap en QGIS"

**El momento de flutter run:**

> "Momento de la verdad. Guarden todo... flutter run..."

Espera a que compile. Cuando aparezca el mapa:

> "¡Ahí está! Un mapa de OpenStreetMap en su teléfono, hecho por ustedes. Tóquenlo — pueden hacer zoom, moverse. Eso es flutter_map."

⚠️ **Si a alguien le sale el mapa en blanco:**
1. Verificar permiso de INTERNET en AndroidManifest.xml
2. Verificar que tienen internet activo
3. Hacer un full restart: detener la app y volver a ejecutar `flutter run`

**Paso 4 — Explicar la URL de tiles (7 min):**

> "¿Ven este URL: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`? Esto es algo que ustedes como gente GIS van a entender mejor que cualquier programador."
> 
> "El mapa está dividido en tiles — cuadrículas. `{z}` es el nivel de zoom, `{x}` e `{y}` son las coordenadas del tile. Flutter descarga solo los tiles que necesita según dónde estés mirando. Es exactamente como funciona un WMS o un servicio de tiles en QGIS."

---

### Parte 4 — Enriquecer el Mapa (10 min)

Agrega EN VIVO:
1. Un marcador rojo en el centro del mapa
2. La barra de información inferior

> "Miren — ya tenemos una app que parece una herramienta profesional. Mapa, marcador, barra de coordenadas. Y la hicimos nosotros."

---

### Cierre (10 min)

**Asignación de Práctica 02:**

> "Su práctica es personalizar este mapa. Cambien el centro a su ciudad, agreguen 4 marcadores en lugares reales, y modifiquen la barra de información. Las instrucciones están en el README del módulo."

**Preview Módulo 2:**

> "En las próximas dos clases vamos a: cambiar entre mapas de calles, satélite y terreno; agregar popups que aparecen al tocar un marcador; dibujar polilíneas y polígonos sobre el mapa; y detectar dónde toca el usuario en el mapa. La app va a empezar a verse como una herramienta GIS profesional."

**Recordatorio:**

> "La sesión de soporte es el [DÍA]. Si tuvieron problemas de instalación o con la práctica, tráiganlos ahí. Semana 1 es la más difícil — después todo fluye."

---

## ⚠️ Errores Comunes Clase 02

| Problema | Solución |
|----------|----------|
| Mapa en blanco | Verificar permiso INTERNET en AndroidManifest.xml |
| Error en pubspec.yaml | Revisar indentación (espacios, no tabs) |
| "Cannot find package flutter_map" | Ejecutar `flutter pub get` |
| Marcador no visible | Coordenadas fuera del área visible — verificar lat/lng |
| App crashea al agregar FlutterMap | Verificar imports correctos |
| TileLayer no carga | Verificar URL del tile server y conexión a internet |

---

## 💡 Tips para el Instructor

1. **El momento del mapa es emocional** — Cuando vean el mapa en su teléfono, van a sonreír. Aprovecha ese momento: "Esto lo hicieron ustedes. Desde cero."
2. **Google Maps en vivo** — Ten Google Maps abierto para buscar coordenadas que los estudiantes sugieran. "¿Alguien de Cochabamba? ¿Cuáles coordenadas ponemos?"
3. **Compara con QGIS constantemente** — "En QGIS agregarían una capa, aquí agregan un widget. En QGIS cambiarían el estilo, aquí cambian propiedades del widget."
4. **Si la compilación es lenta** — Usa ese tiempo para explicar algo o responder preguntas. No dejes silencio incómodo.
5. **No te saltes el Hot Reload** — Cada cambio, guarda y muestra el resultado. Los estudiantes necesitan ver la causa-efecto inmediata.