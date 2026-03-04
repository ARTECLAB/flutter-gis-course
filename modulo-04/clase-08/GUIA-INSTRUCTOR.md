# 🎓 Guía del Instructor — Clase 08

## Filtros CQL, GetFeatureInfo y Leyenda

**Duración:** 2 horas (120 minutos)
**Módulo:** 4 de 6

---

## ⏱️ Cronograma

| Tiempo | Duración | Sección | Actividad |
|--------|----------|---------|-----------|
| 00:00 | 5 min  | Repaso | Verificar práctica 07 |
| 00:05 | 30 min | Parte 1 | Filtros CQL |
| 00:35 | 25 min | Parte 2 | GetFeatureInfo |
| 01:00 | 10 min | Descanso | |
| 01:10 | 15 min | Parte 3 | Leyenda WMS |
| 01:25 | 20 min | Práctica | Práctica 08 guiada |
| 01:45 | 15 min | Cierre | Resumen módulo, preview Módulo 5 |

---

## 🎬 Desarrollo

### Parte 1 — CQL (30 min)

> "En QGIS filtran datos con expresiones: 'mostrar solo municipios con población > 100000'. CQL hace exactamente lo mismo pero desde la URL del servidor."

**Construye EN VIVO:**
1. Muestra la capa completa de municipios
2. Agrega un filtro CQL: `departamento='La Paz'`
3. Muestra cómo solo aparecen los municipios de La Paz

> "¿Ven? No descargamos todos los municipios y filtramos en la app. Le dijimos al SERVIDOR que solo nos mande La Paz. El servidor hizo el trabajo pesado."

### Parte 2 — GetFeatureInfo (25 min)

> "Esto es lo más parecido a 'Identificar features' de QGIS. Tocan el mapa y ven los atributos del polígono debajo."

**Este concepto es nuevo y potente.** Explica paso a paso:
1. El tap te da coordenadas en pantalla (píxeles)
2. Se construye una URL GetFeatureInfo con esas coordenadas
3. El servidor responde con los atributos en JSON
4. Mostramos los atributos en un diálogo

### Parte 3 — Leyenda (15 min)

> "GeoServer genera la leyenda automáticamente. Solo tienes que pedir la URL correcta."

### Preview Módulo 5

> "Ahora su app tiene mapas, GPS, capas WMS del servidor. En el Módulo 5 vamos a cerrar el círculo: formularios de captura de datos + almacenamiento local. Van a poder ir a campo, capturar puntos con atributos, y tenerlos guardados en el teléfono."

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| CQL no filtra | Nombre de campo exacto, strings entre comillas simples |
| GetFeatureInfo vacío | query_layers debe coincidir con layers |
| Coordenadas x,y incorrectas | Verificar cálculo del pixel relativo al bbox |
| Leyenda no carga | Verificar nombre de capa y que GeoServer tenga estilo asignado |
| Error HTTP/CORS | GeoServer necesita CORS habilitado |

## 💡 Tips

1. **Prueba las URLs en el navegador primero.** Si no funcionan en el navegador, no funcionarán en la app.
2. **Muestra el JSON crudo de GetFeatureInfo.** Para que entiendan qué devuelve el servidor antes de parsearlo.
3. **Compara con QGIS en vivo:** Haz el mismo filtro en QGIS y en la app para mostrar que es equivalente.