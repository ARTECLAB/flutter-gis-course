# 🎓 Guía del Instructor — Clase 09

## Formularios de Captura y Almacenamiento Local

**Duración:** 2 horas (120 minutos)
**Módulo:** 5 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 10 min | Repaso | Verificar práctica Módulo 4, preguntas WMS |
| 00:10 | 10 min | Parte 1 | Contexto: captura en campo |
| 00:20 | 30 min | Parte 2 | Widgets de formulario + validación |
| 00:50 | 10 min | Descanso | |
| 01:00 | 25 min | Parte 3 | SharedPreferences + persistencia |
| 01:25 | 25 min | Parte 4 | Formulario completo + integración mapa |
| 01:50 | 10 min | Cierre | Práctica, preview clase 10 |

---

## 🎬 Desarrollo

### Apertura (10 min)

> "Su app ya tiene mapa, GPS, capas WMS. Pero capturar un punto GPS sin atributos es como tomar una foto sin descripción — no sirve de mucho. Hoy le agregamos el FORMULARIO: cuando capturen un punto, se abre una pantalla donde llenan nombre, tipo, estado y observaciones."

> "¿Han hecho levantamiento de datos en campo? ¿Con GPS y planilla? Hoy reemplazan la planilla por un formulario en la app."

### Parte 2 — Widgets de formulario (30 min)

**Concepto clave: Form + GlobalKey**

> "Form es un widget contenedor que agrupa todos los campos. El GlobalKey es como un control remoto: te permite validar todos los campos a la vez con un solo comando."

**Construye EN VIVO paso a paso:**
1. Primero un TextFormField simple
2. Agrega validación: muestra el error rojo
3. Agrega DropdownButtonFormField
4. Muestra cómo `_formKey.currentState!.validate()` valida todo

**Momento impactante:** Cuando presionan "Guardar" sin llenar campos y aparecen los mensajes de error rojos debajo de cada campo.

### Parte 3 — SharedPreferences (25 min)

> "¿Qué pasa si cierran la app? ¿Los datos se pierden? SÍ — porque hasta ahora los guardamos en variables de Dart que viven solo en memoria. SharedPreferences guarda datos en el almacenamiento del teléfono. Como guardar un archivo."

**Demuestra EN VIVO:**
1. Captura un punto
2. Cierra la app completamente
3. Abre la app — los datos siguen ahí

### Parte 4 — Formulario completo (25 min)

> "Ahora todo junto: presionan 'Capturar', se abre el formulario con las coordenadas GPS ya llenas, llenan los atributos, presionan Guardar, y el punto aparece en el mapa con toda su información."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Formulario no valida | Verificar que Form tiene key y que cada campo tiene validator |
| Controller no actualiza | Usar controller.text para leer el valor |
| SharedPreferences error | Verificar `await` y que el import sea correcto |
| LatLng no se guarda en JSON | Guardar lat y lng como doubles separados |
| Teclado tapa el formulario | Envolver en SingleChildScrollView |

## 💡 Tips

1. **Usa SingleChildScrollView** para que el formulario sea scrolleable cuando el teclado aparece
2. **Muestra las coordenadas como solo lectura** — el usuario no debe poder editarlas
3. **Conecta con su realidad:** "Esto es lo que hace la app de catastro municipal, la app de inventario forestal, la app de monitoreo ambiental"