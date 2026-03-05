# Módulo 5 · Captura de Datos GPS & Visualización 📍🗂️

> **Clases 9 y 10 · 4 horas totales**
> Tu app se convierte en herramienta de campo real: formularios de captura, almacenamiento local persistente, lista de registros y vista combinada mapa + datos.

---

## 🎯 Objetivos del Módulo

- Crear formularios de captura con validación
- Almacenar datos localmente con SharedPreferences y JSON
- Listar registros capturados con búsqueda y filtro
- Editar y eliminar registros existentes
- Vista combinada: mapa con puntos + lista de datos
- Exportar datos como texto legible (preparación para GeoJSON en Módulo 6)

---

## Clase 09 — Formularios de Captura y Almacenamiento Local

### 🎯 Objetivo

Crear un formulario profesional para registrar puntos de campo con atributos, validar los datos, y guardarlos de forma persistente en el teléfono.

### Parte 1 — ¿Qué es un formulario de captura en campo? (10 min)

#### Contexto GIS

En trabajo de campo, no basta con capturar una coordenada GPS. Necesitas registrar atributos:
- ¿Qué tipo de punto es? (poste, árbol, edificio, muestra)
- ¿En qué estado está? (bueno, regular, malo)
- ¿Quién lo registró?
- ¿Alguna observación?

En QGIS, cuando digitalizas un punto, se abre una ventana de atributos. En tu app, se abre un formulario.

### Parte 2 — Widgets de Formulario en Flutter (30 min)

#### TextFormField — Campo de texto con validación

```dart
final _formKey = GlobalKey<FormState>();
final _nombreCtrl = TextEditingController();
final _observacionCtrl = TextEditingController();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _nombreCtrl,
        decoration: const InputDecoration(
          labelText: 'Nombre del punto',
          hintText: 'Ej: Poste eléctrico #42',
          prefixIcon: Icon(Icons.label),
          border: OutlineInputBorder(),
        ),
        validator: (valor) {
          if (valor == null || valor.isEmpty) {
            return 'El nombre es obligatorio';
          }
          return null; // null = válido
        },
      ),
    ],
  ),
)
```

#### DropdownButtonFormField — Selector de opciones

```dart
String? _tipoSeleccionado;

DropdownButtonFormField<String>(
  value: _tipoSeleccionado,
  decoration: const InputDecoration(
    labelText: 'Tipo de punto',
    prefixIcon: Icon(Icons.category),
    border: OutlineInputBorder(),
  ),
  items: ['Poste', 'Árbol', 'Edificio', 'Muestra', 'Otro']
      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
      .toList(),
  onChanged: (val) => setState(() => _tipoSeleccionado = val),
  validator: (val) => val == null ? 'Selecciona un tipo' : null,
)
```

#### Validación y envío

```dart
ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      // Todos los campos son válidos — guardar
      _guardarPunto();
    }
  },
  child: const Text('Guardar Punto'),
)
```

### Parte 3 — Almacenamiento Local con SharedPreferences (25 min)

#### ¿Por qué almacenamiento local?

Cuando capturas datos en campo, muchas veces NO tienes internet. Los datos deben guardarse en el teléfono y persistir aunque cierres la app. SharedPreferences guarda datos como texto (JSON) en el almacenamiento del teléfono.

#### Instalar

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

#### Guardar y leer datos

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Guardar lista de puntos
Future<void> _guardarPuntos() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = json.encode(_puntosCapturados);
  await prefs.setString('puntos_campo', jsonString);
}

// Leer lista de puntos al iniciar
Future<void> _cargarPuntos() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('puntos_campo');
  if (jsonString != null) {
    final List<dynamic> lista = json.decode(jsonString);
    setState(() {
      _puntosCapturados = lista.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    });
  }
}
```

### Parte 4 — Pantalla de Formulario Completa (25 min)

```dart
class FormularioPunto extends StatefulWidget {
  final LatLng posicion;
  final Function(Map<String, dynamic>) onGuardar;

  const FormularioPunto({
    required this.posicion,
    required this.onGuardar,
    super.key,
  });

  @override
  State<FormularioPunto> createState() => _FormularioPuntoState();
}

class _FormularioPuntoState extends State<FormularioPunto> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();
  String? _tipo;
  String _estado = 'Bueno';

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final punto = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreCtrl.text,
        'tipo': _tipo,
        'estado': _estado,
        'observacion': _observacionCtrl.text,
        'latitud': widget.posicion.latitude,
        'longitud': widget.posicion.longitude,
        'fecha': DateTime.now().toIso8601String(),
      };
      widget.onGuardar(punto);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Punto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coordenadas (solo lectura)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '📍 ${widget.posicion.latitude.toStringAsFixed(6)}, '
                    '${widget.posicion.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: ['Poste', 'Árbol', 'Edificio', 'Muestra', 'Otro']
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v),
                validator: (v) => v == null ? 'Selecciona tipo' : null,
              ),
              const SizedBox(height: 12),
              // Estado con radio buttons
              const Text('Estado:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...['Bueno', 'Regular', 'Malo'].map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _estado,
                    onChanged: (v) => setState(() => _estado = v!),
                  )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Punto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 💻 Práctica 09

1. Crea la pantalla FormularioPunto con campos: nombre, tipo (dropdown), estado (radio), observación
2. Implementa validación: nombre y tipo obligatorios
3. Al guardar, agrega el punto a la lista y cierra el formulario
4. Guarda la lista en SharedPreferences al agregar cada punto
5. Al iniciar la app, carga los puntos guardados

### ✅ Checklist Clase 09

- [ ] Formulario con TextFormField, Dropdown, Radio
- [ ] Validación funcional
- [ ] Datos se guardan en SharedPreferences
- [ ] Datos persisten al cerrar y abrir la app
- [ ] Punto aparece como marcador en el mapa

---

## Clase 10 — Lista de Registros y Vista Combinada

### 🎯 Objetivo

Crear una pantalla de lista de registros capturados, implementar edición y eliminación, y combinar la vista de mapa con la lista de datos.

### Parte 1 — Lista de Registros con ListView (25 min)

```dart
class ListaPuntos extends StatelessWidget {
  final List<Map<String, dynamic>> puntos;
  final Function(int) onEliminar;
  final Function(Map<String, dynamic>) onEditar;
  final Function(LatLng) onVerEnMapa;

  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puntos (${puntos.length})'),
      ),
      body: puntos.isEmpty
          ? const Center(child: Text('No hay puntos capturados'))
          : ListView.builder(
              itemCount: puntos.length,
              itemBuilder: (ctx, i) {
                final p = puntos[i];
                return Dismissible(
                  key: Key(p['id'].toString()),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => onEliminar(i),
                  child: ListTile(
                    leading: Icon(_iconoPorTipo(p['tipo'])),
                    title: Text(p['nombre']),
                    subtitle: Text(
                      '${p['tipo']} · ${p['estado']} · '
                      '${p['latitud'].toStringAsFixed(4)}, '
                      '${p['longitud'].toStringAsFixed(4)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () => onVerEnMapa(
                        LatLng(p['latitud'], p['longitud']),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
```

### Parte 2 — Edición de Registros (20 min)

Reutilizar FormularioPunto en modo edición, prellenando los campos con los datos existentes.

### Parte 3 — Navegación entre pantallas (20 min)

```dart
// Desde MapaScreen, navegar al formulario
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FormularioPunto(
      posicion: _posicionGPS!,
      onGuardar: (punto) {
        setState(() => _puntosCapturados.add(punto));
        _guardarPuntos();
      },
    ),
  ),
);

// Navegar a la lista
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ListaPuntos(
      puntos: _puntosCapturados,
      onEliminar: (i) {
        setState(() => _puntosCapturados.removeAt(i));
        _guardarPuntos();
      },
      onEditar: (punto) { /* ... */ },
      onVerEnMapa: (latLng) {
        Navigator.pop(context);
        _mapController.move(latLng, 17.0);
      },
    ),
  ),
);
```

### Parte 4 — Vista combinada con BottomNavigationBar (25 min)

```dart
int _pantallaActual = 0;

Scaffold(
  body: IndexedStack(
    index: _pantallaActual,
    children: [
      _buildMapa(),
      _buildLista(),
    ],
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _pantallaActual,
    onTap: (i) => setState(() => _pantallaActual = i),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Datos'),
    ],
  ),
)
```

---

### 💻 Práctica 10

1. Crea ListaPuntos con ListView.builder
2. Implementa Dismissible para eliminar deslizando
3. Botón "Ver en mapa" que centra el mapa en ese punto
4. BottomNavigationBar para alternar entre Mapa y Lista
5. Contador de puntos en la barra de la lista

### 🚀 Reto Extra — Búsqueda

Agrega un TextField de búsqueda arriba de la lista que filtre puntos por nombre o tipo.

### ✅ Checklist Clase 10

- [ ] Lista de puntos capturados funcional
- [ ] Eliminar deslizando (Dismissible)
- [ ] Botón "Ver en mapa" centra el mapa
- [ ] BottomNavigationBar: Mapa ↔ Lista
- [ ] Datos persisten entre sesiones

---

## 📝 Errores comunes

1. **Datos no persisten** → Verificar que llamas `_guardarPuntos()` después de cada cambio
2. **Error JSON al cargar** → Datos corruptos. Limpiar con `prefs.remove('puntos_campo')`
3. **Navigator.pop error** → Verificar que la pantalla actual puede hacer pop (tiene ruta anterior)
4. **LatLng no se serializa a JSON** → Guardar lat/lng como doubles separados, no como objeto LatLng
5. **Lista no se actualiza** → Falta setState() al modificar la lista