# 🎓 Guía del Instructor — Clase 06

## Seguimiento GPS, Almacenamiento y Distancias

**Duración:** 2 horas (120 minutos)
**Fecha:** Miércoles 1 de abril de 2026
**Módulo:** 3 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica 05 |
| 00:05 | 25 min | Parte 1 | Seguimiento GPS en tiempo real |
| 00:30 | 25 min | Parte 2 | Capturar y almacenar puntos |
| 00:55 | 10 min | Descanso | |
| 01:05 | 20 min | Parte 3 | Cálculo de distancias |
| 01:25 | 20 min | Parte 4 | Panel de puntos capturados |
| 01:45 | 15 min | Cierre | Práctica, preview Módulo 4 |

---

## 🎬 Desarrollo

### Parte 1 — Seguimiento en tiempo real (25 min)

> "En la clase pasada obtuvimos la posición UNA vez al presionar un botón. Pero en campo necesitas que se actualice solo mientras caminas. Eso es el seguimiento en tiempo real."

**Concepto clave — Stream:**
> "Un Stream es como una manguera de datos. En vez de pedir agua una vez, la abres y fluye continuamente. Aquí abrimos el 'stream de posición' y las coordenadas llegan cada vez que te mueves."

Construye EN VIVO el botón toggle Iniciar/Detener.

> "Cuando activan el seguimiento, caminen por el salón con el teléfono. ¿Ven cómo el punto azul se mueve? Eso es captura GPS en tiempo real."

### Parte 2 — Capturar puntos (25 min)

> "Seguimiento es ver dónde estás. Captura es REGISTRAR un punto específico. Como cuando en campo dices 'aquí hay un poste de luz' y marcas el punto en el GPS."

### Parte 3 — Distancias (20 min)

> "¿Alguno ha calculado distancia entre dos puntos en QGIS? Seleccionas la herramienta de medir y haces clic. Aquí usamos la fórmula de Haversine que ya viene incluida en geolocator."

**Muestra ejemplo práctico:**
1. Captura 2 puntos separados por unos metros
2. Calcula la distancia
3. Compara con lo que dice Google Maps

### Preview Módulo 4

> "Ahora que su app sabe dónde están y puede capturar puntos, en el Módulo 4 vamos a conectarla con un servidor GeoServer real. Van a ver capas WMS profesionales sobre su mapa — datos reales servidos desde un servidor como hacen las empresas."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Stream no se actualiza | distanceFilter muy alto, bajar a 5 metros |
| Memory leak (app lenta) | Verificar que cancel() está en dispose() |
| Puntos duplicados | Verificar que no se agreguen puntos con misma coordenada |
| Distancia da 0 | Los dos puntos son iguales — mover y recapturar |

## 💡 Tips

1. **Haz que caminen:** Pide a los estudiantes que salgan del salón 2 minutos con el teléfono y capturen puntos. Es la práctica más memorable del curso.
2. **Muestra la polilínea:** Cuando tienen 4+ puntos, muestra la traza del recorrido como polilínea. Es impactante.
3. **Conecta con su profesión:** "Esto es lo que hacen las apps de catastro, monitoreo ambiental, inventario forestal — capturar puntos GPS con atributos."