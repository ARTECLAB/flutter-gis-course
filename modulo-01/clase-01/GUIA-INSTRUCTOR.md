# 🎓 Guía del Instructor — Clase 01

## Tu Primer Proyecto Flutter y Fundamentos de Dart para GIS

**Duración:** 2 horas (120 minutos)
**Fecha:** Lunes 16 de marzo de 2026
**Módulo:** 1 de 6

---

## 📋 Antes de la Clase

### Preparación (30 min antes)

- [ ] Verifica que tu proyecto `geo_collect` funciona en tu teléfono
- [ ] Ten abierto VS Code con el proyecto listo
- [ ] Ten abierta una terminal lista para comandos
- [ ] Prepara la pantalla compartida: VS Code a la izquierda, teléfono/emulador a la derecha
- [ ] Ten abierto Google Maps para buscar coordenadas en vivo
- [ ] Haz un repaso rápido de la guía de instalación por si hay preguntas

### Materiales necesarios

- Proyecto `geo_collect` limpio (recién creado)
- Archivo `practica_01.dart` con la solución lista (por si necesitas mostrarla)
- Lista de coordenadas de ciudades latinoamericanas para ejemplos

---

## ⏱️ Cronograma Detallado

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Bienvenida | Presentación, verificar setups, romper el hielo |
| 00:10 | 20 min | Parte 1 | Crear proyecto y ejecutar en teléfono |
| 00:30 | 50 min | Parte 2 | Fundamentos de Dart con enfoque GIS |
| 01:20 | 10 min | Descanso | Pausa — pedir que estiren las piernas |
| 01:30 | 20 min | Práctica | Práctica 01 — Simulador de datos GIS |
| 01:50 | 10 min | Cierre | Checklist, preview de la próxima clase, dudas |

---

## 🎬 Desarrollo de la Clase

### Bienvenida (10 min)

**Lo que dices:**

> "Bienvenidos al curso de Flutter GIS. Antes que nada — levanten la mano los que nunca han programado."
> *(espera respuestas)*
> "Perfecto, este curso está diseñado exactamente para ustedes. No necesitan saber programar. Lo que sí saben — y es su mayor ventaja — es trabajar con mapas, coordenadas y datos geográficos. Ese conocimiento GIS es el que vamos a usar desde hoy."
> 
> "Al final de HOY — en 2 horas — van a tener un mapa real corriendo en su teléfono. No un dibujo, no una captura de pantalla — una app real que pueden tocar, hacer zoom, y mover."

**Verificación rápida de setups:**
- "¿Quién tiene `flutter doctor` sin errores?" — Pide que levanten la mano
- Si alguien tiene problemas, dile que tome nota y que lo resuelvan en la sesión de soporte esta semana
- No pierdas más de 5 min en troubleshooting aquí — la clase debe avanzar

---

### Parte 1 — Crear y Ejecutar (20 min)

**Lo que muestras en pantalla:** Tu terminal + VS Code

**Acción en vivo:**
1. Ejecuta `flutter create geo_collect` — **hazlo en vivo**, no lo tengas pre-creado
2. Mientras se crea, explica qué es cada carpeta (solo `lib/` y `pubspec.yaml`)
3. Abre el proyecto en VS Code con `code .`
4. Ejecuta `flutter run` — **conecta tu teléfono en vivo**

**Mientras flutter run compila (3-5 min), aprovecha para:**
- Explicar qué es Flutter (SDK de Google para apps multiplataforma)
- Explicar que Dart es el lenguaje (como Python es para QGIS)
- Preguntar: "¿Quiénes de ustedes han usado expresiones en QGIS? Dart es similar a eso, pero más poderoso"

**Momento clave — Hot Reload:**
> "Miren su teléfono. ¿Ven la app del contador? Ahora voy a cambiar este texto..."
> *(cambia el texto en main.dart)*
> "Guardo... y BOOM. Se actualizó instantáneamente. Esto se llama Hot Reload y es como si en QGIS pudieran cambiar el estilo de una capa y verlo reflejado al instante."

⚠️ **Error común aquí:** Algunos estudiantes no verán su teléfono en la lista de dispositivos. Diles: "Si tu teléfono no aparece, revisa que el cable sea de datos, no solo de carga. Lo resolveremos en la sesión de soporte."

---

### Parte 2 — Fundamentos de Dart (50 min)

**Estrategia pedagógica:** NO abras un archivo nuevo de Dart teórico. Usa el mismo `lib/main.dart` o la consola Dart para mostrar los ejemplos. Siempre conecta cada concepto con GIS.

**Variables (10 min):**

Lo que dices:
> "En GIS trabajan con coordenadas, nombres de capas, escalas. En Dart, todo eso se guarda en variables."

Escribe EN VIVO:
```dart
double latitud = -16.5000;
double longitud = -68.1500;
String nombreCapa = 'Ríos principales';
```

Pregunta al grupo: "¿Quién sabe las coordenadas de su ciudad? Díganme una y la escribimos."

**Listas (10 min):**

Lo que dices:
> "¿Cuántos de ustedes han trabajado con una tabla de coordenadas en Excel? Una Lista en Dart es exactamente eso — una columna de datos."

Ejemplo en vivo: Crea una lista de coordenadas de 3 ciudades que los estudiantes sugieran.

**Maps (10 min):**

Lo que dices:
> "Ahora viene mi favorito. ¿Conocen la tabla de atributos en QGIS? Cada fila tiene nombre, tipo, coordenadas... Un Map en Dart es EXACTAMENTE una fila de esa tabla."

Muestra lado a lado: tabla de atributos de QGIS (imagen/captura) vs un Map en Dart.

**Funciones (10 min):**

Lo que dices:
> "Una función es como una herramienta de geoprocesamiento. Le das inputs, hace algo, y te da un resultado. Buffer toma una geometría y una distancia — y te devuelve el buffer. Nuestra función va a tomar coordenadas y nos va a dar un texto formateado."

**Condicionales e Interpolación (10 min):**

Muestra el ejemplo de zoom con niveles de detalle — esto les hace mucho sentido porque trabajan con escalas.

---

### Descanso (10 min)

> "Tómense 10 minutos. Estiren las piernas. Si quieren, prueben cambiar algún valor en su código y vean qué pasa con Hot Reload."

---

### Práctica 01 (20 min)

**Lo que dices:**
> "Ahora es su turno. Van a crear un programa que simula capturar puntos en campo. Abran las instrucciones de la Práctica 01 en el README del módulo."

**Tu rol durante la práctica:**
- Comparte tu pantalla con las instrucciones visibles
- Camina por el código (figurativamente) — resuelve dudas en vivo
- Si ves que muchos están atascados en lo mismo, haz una pausa y explica en pantalla
- **No des la solución completa** — guía con pistas

**Si alguien termina rápido:**
> "¿Ya terminaste? Perfecto — agrega una función que calcule cuántos puntos de cada tipo hay."

**Últimos 5 min:** Muestra la solución en pantalla, comparando con lo que ellos hicieron.

---

### Cierre (10 min)

**Checklist en vivo:**
> "Vamos a repasar juntos. Levanten la mano si..."
> - "...tienen su proyecto `geo_collect` creado" ✋
> - "...pudieron ejecutar la app en su teléfono" ✋
> - "...el Hot Reload les funcionó" ✋
> - "...completaron la práctica" ✋

**Preview de la Clase 02:**
> "La próxima clase nos olvidamos del contador de Flutter y ponemos un mapa REAL de OpenStreetMap en nuestro teléfono. Van a poder hacer zoom, moverse por el mapa, y agregar marcadores. Es donde la app empieza a verse como una herramienta GIS de verdad."

**Tarea antes de la Clase 02:**
- Completar la Práctica 01 si no la terminaron
- Buscar las coordenadas de 4 lugares de su ciudad en Google Maps y anotarlas (las van a necesitar)
- Verificar que flutter run sigue funcionando

---

## ⚠️ Errores Comunes y Cómo Resolverlos en Clase

| Problema | Causa | Solución rápida |
|----------|-------|-----------------|
| "flutter: command not found" | PATH no configurado | Derivar a sesión de soporte |
| App no aparece en teléfono | Depuración USB desactivada | Guiar paso a paso en clase |
| Hot Reload no funciona | Error de sintaxis en el código | Revisar el error en la terminal |
| "Dart analysis" errores rojos | Falta punto y coma o paréntesis | Señalar la línea con error |
| pubspec.yaml no funciona | Indentación incorrecta (tabs vs espacios) | Mostrar la indentación correcta |

---

## 💡 Tips para el Instructor

1. **Escribe código EN VIVO** — no copies y pegues. Los errores que cometas en vivo son oportunidades de enseñanza ("Miren, me faltó un punto y coma — Flutter me dice exactamente dónde")
2. **Usa nombres de variables en español** — `nombreCapa`, no `layerName`. Es más accesible para no programadores.
3. **Siempre conecta con GIS** — Cada concepto nuevo debería ir acompañado de "en QGIS esto sería como..."
4. **No te apures** — Si ves caras de confusión en las variables, dedica 5 min extra ahí. Es mejor que entiendan bien lo básico.
5. **Celebra los logros** — "¡Lo lograron! Tienen una app corriendo en su teléfono. Eso es más de lo que la mayoría de programadores logra en su primer día."