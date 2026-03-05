# 🎓 Guía del Instructor — Clase 12

## Generación de APK y Cierre del Curso

**Duración:** 2 horas (120 minutos)
**Módulo:** 6 de 6 — ÚLTIMA CLASE

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica 11 |
| 00:05 | 20 min | Parte 1 | Configurar identidad de la app |
| 00:25 | 25 min | Parte 2 | Generar APK firmado |
| 00:50 | 10 min | Descanso | |
| 01:00 | 10 min | Parte 3 | Instalar APK en otro teléfono |
| 01:10 | 30 min | Parte 4 | Repaso general + demo final |
| 01:40 | 20 min | Cierre | Feedback, certificados, próximos pasos |

---

## 🎬 Desarrollo

### Parte 1 — Configurar identidad (20 min)

> "Su app se llama GeoCollect, pero hasta ahora usa el nombre genérico y el ícono de Flutter. Vamos a personalizarla: nombre real, ícono propio, versión 1.0."

Guía paso a paso EN VIVO:
1. Cambiar `android:label` en AndroidManifest.xml
2. Cambiar `applicationId` en build.gradle
3. Si hay tiempo y tienen un ícono: flutter_launcher_icons

### Parte 2 — Generar APK (25 min)

**Este proceso es nuevo para todos. Ve despacio.**

> "Hasta ahora ejecutamos la app con `flutter run` que es modo desarrollo — incluye debugging, Hot Reload, herramientas de diagnóstico. El APK release es la versión limpia, optimizada, lista para que cualquier persona la instale."

```bash
flutter build apk --release
```

> "El comando tarda 2-3 minutos. Al terminar les dice dónde está el archivo APK."

**Si hay tiempo:** Explica el keystore y la firma. Si no, genera APK sin firma (debug) que también se puede instalar.

> "Para producción real necesitan firmar el APK. Hoy generamos la versión release sin firma para simplificar. El proceso de firma lo pueden hacer después siguiendo la documentación."

**Alternativa rápida sin keystore:**
```bash
flutter build apk --release --no-shrink
```

### Parte 3 — Instalar en otro teléfono (10 min)

> "¿Alguien tiene un compañero al lado? Envíenle el APK por WhatsApp."

Proceso:
1. Encontrar el APK en `build/app/outputs/flutter-apk/`
2. Compartir por WhatsApp/Drive
3. El receptor activa "fuentes desconocidas" y lo instala

> "Acaban de distribuir su primera app. La persona que la instale puede capturar puntos GPS con atributos y exportarlos a QGIS."

### Parte 4 — Repaso y Demo Final (30 min)

**Haz el ciclo completo EN VIVO:**
1. Abrir la app
2. Activar GPS
3. Capturar 2-3 puntos con formulario
4. Ver la lista de datos
5. Exportar GeoJSON
6. Abrir en QGIS

> "En 6 semanas, partiendo de cero, construyeron esto. Una app Android funcional que cualquier profesional GIS puede usar en campo."

**Repaso por módulo (pide participación):**

> "¿Qué aprendieron en el Módulo 1?" → Dart, widgets, primer mapa
> "¿Y en el 2?" → Capas, popups, geometrías
> "¿El 3?" → GPS real del teléfono
> "¿El 4?" → Conexión con GeoServer
> "¿El 5?" → Formularios y almacenamiento
> "¿Y hoy?" → Exportar y generar APK

### Cierre (20 min)

> "Quiero que sepan que lo que aprendieron aquí no es solo Flutter. Aprendieron a pensar como desarrolladores: resolver problemas, leer errores, buscar soluciones. Eso es lo que se llevan."

**Próximos pasos que pueden explorar:**
- WFS en vez de WMS para datos vectoriales del servidor
- Base de datos SQLite local (más robusta que SharedPreferences)
- Captura de fotos georeferenciadas
- Sincronización con servidor cuando hay internet
- Publicar en Google Play Store

**Feedback:**
- Pide feedback honesto sobre el curso
- Qué funcionó, qué mejorar

---

## 💡 Tips para el cierre

1. **Celebra el logro.** Empezaron sin saber programar y terminaron con una app funcional. Eso es grande.
2. **Toma capturas de pantalla** de las apps de los estudiantes para compartir en redes.
3. **Ofrece soporte post-curso** (grupo de WhatsApp, sesión de dudas) si es viable.
4. **Si das certificados:** este es el momento de entregarlos o anunciarlos.