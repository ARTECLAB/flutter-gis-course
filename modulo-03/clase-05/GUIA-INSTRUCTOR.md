# 🎓 Guía del Instructor — Clase 05

## Integración GPS y Permisos Android

**Duración:** 2 horas (120 minutos)
**Fecha:** Lunes 30 de marzo de 2026
**Módulo:** 3 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Repaso | Verificar práctica Módulo 2 |
| 00:10 | 15 min | Parte 1 | Concepto: ¿cómo funciona el GPS? |
| 00:25 | 20 min | Parte 2 | Configurar permisos Android |
| 00:45 | 25 min | Parte 3 | Obtener posición actual |
| 01:10 | 10 min | Descanso | |
| 01:20 | 25 min | Parte 4 | Marcador GPS en el mapa |
| 01:45 | 15 min | Cierre | Práctica, preview clase 06 |

---

## 🎬 Desarrollo

### Apertura (10 min)

> "Hasta ahora teníamos un mapa donde ustedes podían poner marcadores con coordenadas que buscaban en Google Maps. Hoy la app va a saber DÓNDE ESTÁN ustedes. El teléfono va a decirle a la app su posición real."

> "Esta es la clase donde su app deja de ser un mapa bonito y se convierte en una herramienta de campo."

### Parte 1 — ¿Cómo funciona el GPS? (15 min)

**Explica como si fuera QGIS con GPS portátil:**

> "¿Alguno de ustedes ha usado un GPS Garmin en campo? El proceso es: enciendes el GPS → esperas que conecte con satélites → te da coordenadas. En el teléfono es exactamente igual, pero el sensor GPS ya está adentro."

> "Para que la app acceda al GPS necesitamos tres cosas: declarar el permiso en el código, que el usuario acepte, y que el GPS esté encendido. Si falta UNA sola de las tres, no funciona."

Dibuja en la pizarra los 3 requisitos como un checklist.

### Parte 2 — Permisos (20 min)

**Este es un concepto nuevo y crucial. Tómate el tiempo.**

> "Imaginen que instalan una app de linterna. ¿Tiene sentido que les pida acceso a su ubicación? No. Android protege a los usuarios haciendo que cada app declare qué necesita y el usuario decide si acepta."

> "Nuestra app SÍ necesita ubicación porque es una app de mapas. Pero debemos pedirlo correctamente."

**Construye EN VIVO paso a paso:**
1. Modifica AndroidManifest.xml
2. Escribe la función `_verificarPermisos()` completa
3. Muestra los 3 escenarios: GPS apagado, permiso denegado, permiso OK

**Error que VAN a cometer:** Olvidar hacer full restart después de cambiar AndroidManifest.

> "Hot Reload NO sirve para cambios en AndroidManifest.xml. Necesitan parar la app y volver a ejecutar `flutter run`."

### Parte 3 — Posición actual (25 min)

> "Ahora sí — presionen el botón... ¿Ven su posición? Esas coordenadas son REALES, de su teléfono, justo ahora."

**Momento clave:** Cuando los estudiantes ven su posición real en el mapa por primera vez. Déjalos que lo disfruten. Pide que compartan pantalla.

### Parte 4 — Marcador en el mapa (25 min)

> "El punto azul que ven en Google Maps cuando activan la ubicación — vamos a hacer exactamente eso. Un círculo azul semi-transparente con un punto en el centro."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| MissingPluginException | Full restart, no Hot Reload |
| "Location services disabled" | Pedir al estudiante que encienda GPS del teléfono |
| Permiso denegado permanentemente | Ir a Configuración → Apps → Permisos |
| Coordenadas muy imprecisas | Usar LocationAccuracy.high, estar cerca de ventana |
| GPS tarda mucho | Normal la primera vez (5-15 seg), paciencia |

## 💡 Tips

1. **Pide que todos activen GPS ANTES de la clase** en el grupo de WhatsApp
2. **Si alguien usa emulador:** El emulador tiene GPS simulado en las opciones (three dots → Location)
3. **Compara con trabajo de campo real:** "En campo con GPS Garmin esperan fix. Aquí es igual pero más rápido"