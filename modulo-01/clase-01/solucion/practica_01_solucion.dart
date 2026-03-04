// =============================================================
// ✅ SOLUCIÓN — Práctica 01: Simulador de Datos GIS en Dart
// =============================================================
// Módulo 1 · Clase 01
// Curso Flutter GIS — Daniel Quisbert
//
// PARA EJECUTAR:
// dart run lib/practica_01_solucion.dart
// =============================================================

/// Función que muestra la información de un punto geográfico
void mostrarPunto(Map<String, dynamic> punto) {
  String estado = punto['activo'] ? 'Activo' : 'Inactivo';
  print('📍 ${punto['nombre']}');
  print('   Coordenadas: ${punto['latitud']}, ${punto['longitud']}');
  print('   Tipo: ${punto['tipo']}');
  print('   Estado: $estado');
  print(''); // Línea en blanco para separar
}

/// Función que cuenta cuántos puntos hay de un tipo dado
int contarPorTipo(List<Map<String, dynamic>> puntos, String tipo) {
  int contador = 0;
  for (Map<String, dynamic> punto in puntos) {
    if (punto['tipo'] == tipo) {
      contador++;
    }
  }
  return contador;
}

void main() {
  // --- PASO 1 y 2: Lista de puntos geográficos de La Paz ---
  List<Map<String, dynamic>> puntos = [
    {
      'nombre': 'Plaza Murillo',
      'latitud': -16.4955,
      'longitud': -68.1336,
      'tipo': 'parque',
      'activo': true,
    },
    {
      'nombre': 'Iglesia de San Francisco',
      'latitud': -16.4963,
      'longitud': -68.1383,
      'tipo': 'iglesia',
      'activo': true,
    },
    {
      'nombre': 'Mercado Lanza',
      'latitud': -16.4978,
      'longitud': -68.1369,
      'tipo': 'mercado',
      'activo': false,
    },
  ];

  // --- PASO 4: Recorrer la lista y mostrar todos los puntos ---
  print('========================================');
  print('  REGISTRO DE PUNTOS GEOGRÁFICOS');
  print('  Total de puntos: ${puntos.length}');
  print('========================================');
  print('');

  for (Map<String, dynamic> punto in puntos) {
    mostrarPunto(punto);
  }

  // --- PASO 5: Contar puntos por tipo ---
  print('--- Resumen por tipo ---');
  print('Parques: ${contarPorTipo(puntos, 'parque')}');
  print('Iglesias: ${contarPorTipo(puntos, 'iglesia')}');
  print('Mercados: ${contarPorTipo(puntos, 'mercado')}');
}