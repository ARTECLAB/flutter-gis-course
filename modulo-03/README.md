# Módulo 3 · GPS & Geolocalización Real 📍

> **Clases 5 y 6 · 4 horas totales**
> Tu app empieza a usar el hardware real del teléfono. GPS, permisos, coordenadas en tiempo real y cálculo de distancias.

---

## 🎯 Objetivos del Módulo

- Integrar el GPS del teléfono con el paquete geolocator
- Gestionar permisos de Android correctamente
- Mostrar la ubicación del usuario en tiempo real sobre el mapa
- Capturar y almacenar coordenadas GPS
- Calcular distancias entre puntos geográficos
- Manejar errores: sin GPS, permisos denegados

---

## Clase 05 — Integración GPS y Permisos Android

### 🎯 Objetivo

Conectar el GPS real del teléfono a tu app, gestionar los permisos de Android de forma correcta y mostrar la posición actual del usuario sobre el mapa.

### Parte 1 — ¿Cómo funciona el GPS en una app? (15 min)

#### Concepto: El GPS es un sensor del teléfono

El GPS del teléfono es un sensor de hardware que recibe señales de satélites para calcular tu posición. Para que tu app lo use necesitas:

1. **Permiso en el código** — Decirle a Android "esta app necesita acceder al GPS"
2. **Permiso del usuario** — El usuario debe aceptar "¿Permitir que GeoCollect acceda a tu ubicación?"
3. **GPS activado** — El GPS del teléfono debe estar encendido

Si falta cualquiera de estos tres, la app no puede obtener coordenadas.

#### Instalar geolocator

En `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^12.0.0
```

```bash
flutter pub get
```

### Parte 2 — Configurar Permisos en Android (20 min)

#### AndroidManifest.xml

Abrir `android/app/src/main/AndroidManifest.xml` y agregar ANTES de `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

⚠️ `ACCESS_FINE_LOCATION` = GPS preciso (satélites, ~3 metros).
⚠️ `ACCESS_COARSE_LOCATION` = ubicación aproximada (WiFi/antenas, ~100 metros).
Para GIS necesitamos ambos, pero usaremos FINE para mayor precisión.

#### Solicitar permisos en Dart

```dart
import 'package:geolocator/geolocator.dart';

/// Verifica y solicita permisos de ubicación
/// Retorna true si todo está listo para usar GPS
Future<bool> _verificarPermisos() async {
  bool servicioActivo;
  LocationPermission permiso;

  // 1. ¿El GPS del teléfono está encendido?
  servicioActivo = await Geolocator.isLocationServiceEnabled();
  if (!servicioActivo) {
    // GPS apagado — pedir al usuario que lo encienda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ Activa el GPS de tu teléfono')),
    );
    return false;
  }

  // 2. ¿La app tiene permiso de ubicación?
  permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    // No tiene permiso — solicitarlo
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Permiso de ubicación denegado')),
      );
      return false;
    }
  }

  // 3. ¿El permiso fue denegado permanentemente?
  if (permiso == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Ve a Configuración → Permisos para activar ubicación'),
      ),
    );
    return false;
  }

  // Todo listo
  return true;
}
```

### Parte 3 — Obtener la Posición Actual (25 min)

```dart
LatLng? _posicionActual;
bool _cargandoGPS = false;

Future<void> _obtenerUbicacion() async {
  // Verificar permisos primero
  bool listo = await _verificarPermisos();
  if (!listo) return;

  setState(() => _cargandoGPS = true);

  try {
    Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _posicionActual = LatLng(posicion.latitude, posicion.longitude);
      _cargandoGPS = false;
    });

    // Centrar el mapa en la posición
    _mapController.move(_posicionActual!, 16.0);

  } catch (e) {
    setState(() => _cargandoGPS = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error GPS: $e')),
    );
  }
}
```

#### Marcador de ubicación del usuario

```dart
// Agregar a los children de FlutterMap (solo si hay posición)
if (_posicionActual != null)
  MarkerLayer(
    markers: [
      Marker(
        point: _posicionActual!,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.my_location, color: Colors.blue, size: 16),
          ),
        ),
      ),
    ],
  ),
```

### Parte 4 — Ubicación en Tiempo Real con Stream (20 min)

```dart
StreamSubscription<Position>? _posicionStream;

void _iniciarSeguimiento() async {
  bool listo = await _verificarPermisos();
  if (!listo) return;

  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Actualizar cada 5 metros de movimiento
  );

  _posicionStream = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((Position posicion) {
    setState(() {
      _posicionActual = LatLng(posicion.latitude, posicion.longitude);
    });
  });
}

void _detenerSeguimiento() {
  _posicionStream?.cancel();
  _posicionStream = null;
}

@override
void dispose() {
  _detenerSeguimiento();
  super.dispose();
}
```

---

### 💻 Práctica 05 — Mi Ubicación en el Mapa

1. Agrega el paquete `geolocator` y configura los permisos de Android
2. Implementa `_verificarPermisos()` con manejo de los 3 casos (GPS apagado, sin permiso, denegado permanentemente)
3. Agrega un FloatingActionButton con ícono de "mi ubicación" que al presionar obtenga tu posición GPS y centre el mapa
4. Muestra tu posición como un marcador azul circular sobre el mapa
5. Muestra las coordenadas GPS exactas en la barra inferior

### ✅ Checklist Clase 05

- [ ] geolocator instalado y configurado
- [ ] Permisos en AndroidManifest.xml
- [ ] La app solicita permiso de ubicación al usuario
- [ ] Botón "Mi ubicación" funciona y centra el mapa
- [ ] Marcador azul visible en mi posición real
- [ ] Manejo de errores: GPS apagado, permiso denegado

---

## Clase 06 — Seguimiento, Almacenamiento y Distancias

### 🎯 Objetivo

Implementar seguimiento GPS en tiempo real, almacenar coordenadas capturadas y calcular distancias entre puntos.

### Parte 1 — Seguimiento en Tiempo Real (25 min)

Usar el Stream de posición para actualizar el marcador del usuario en el mapa continuamente.

Implementar botón toggle "Iniciar/Detener seguimiento".

### Parte 2 — Almacenar Coordenadas Capturadas (25 min)

```dart
// Lista de puntos GPS capturados
List<Map<String, dynamic>> _puntosCapturados = [];

void _capturarPuntoGPS() {
  if (_posicionActual == null) return;

  final punto = {
    'id': DateTime.now().millisecondsSinceEpoch,
    'latitud': _posicionActual!.latitude,
    'longitud': _posicionActual!.longitude,
    'fecha': DateTime.now().toIso8601String(),
    'nota': '',
  };

  setState(() {
    _puntosCapturados.add(punto);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '✅ Punto #${_puntosCapturados.length} capturado: '
        '${punto['latitud'].toStringAsFixed(4)}, '
        '${punto['longitud'].toStringAsFixed(4)}',
      ),
    ),
  );
}
```

### Parte 3 — Cálculo de Distancias (20 min)

```dart
import 'package:geolocator/geolocator.dart';

/// Calcula la distancia entre dos puntos en metros
double calcularDistancia(LatLng punto1, LatLng punto2) {
  return Geolocator.distanceBetween(
    punto1.latitude, punto1.longitude,
    punto2.latitude, punto2.longitude,
  );
}

/// Formatea la distancia de forma legible
String formatearDistancia(double metros) {
  if (metros < 1000) {
    return '${metros.toStringAsFixed(0)} m';
  } else {
    return '${(metros / 1000).toStringAsFixed(2)} km';
  }
}
```

### Parte 4 — Panel de Puntos Capturados (20 min)

Implementar un Drawer (panel lateral) o BottomSheet que muestre la lista de puntos capturados con sus coordenadas, fecha y distancia al punto anterior.

---

### 💻 Práctica 06 — Captura y Distancias

1. Implementa seguimiento GPS en tiempo real con botón toggle
2. Agrega un botón "Capturar Punto" que registre la posición actual con timestamp
3. Muestra los puntos capturados como marcadores verdes en el mapa
4. Conecta los puntos capturados con una polilínea (traza del recorrido)
5. Muestra la distancia total del recorrido en la barra inferior
6. Implementa un panel que liste los puntos con sus coordenadas

### 🚀 Reto Extra — Geofence simple

Implementa una zona circular de 100 metros alrededor de un punto. Cuando el usuario entre a la zona (su GPS está dentro del radio), muestra una notificación con SnackBar "Has entrado a la zona de estudio". Usa `calcularDistancia()` para verificar.

### ✅ Checklist Clase 06

- [ ] Seguimiento GPS en tiempo real funcionando
- [ ] Botón para capturar punto GPS actual
- [ ] Puntos capturados visibles como marcadores en el mapa
- [ ] Polilínea conectando los puntos del recorrido
- [ ] Cálculo de distancia entre puntos funcional
- [ ] Panel con lista de puntos capturados

---

## 📝 Errores comunes en este módulo

1. **"MissingPluginException"** → Necesitas hacer full restart (`flutter run`), no solo Hot Reload
2. **Permiso denegado permanentemente** → El usuario debe ir a Configuración → Apps → GeoCollect → Permisos
3. **Posición imprecisa** → Necesitas `LocationAccuracy.high` y estar al aire libre o cerca de ventana
4. **Stream no se detiene** → Siempre cancelar en `dispose()` para evitar memory leaks
5. **GPS lento la primera vez** → Es normal, el primer fix GPS tarda 5-15 segundos