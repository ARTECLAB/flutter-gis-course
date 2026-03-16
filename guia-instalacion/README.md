# ⚙️ Guía de Instalación — Preparación antes del Curso

> **Importante:** Completa esta guía ANTES de la primera clase. Si tienes problemas, trae tus dudas a la primera sesión de soporte.

## 📋 Lo que necesitas

| Requisito | Detalle |
|-----------|---------|
| Computadora | Windows 10/11 o Linux Ubuntu 20.04+ |
| RAM | Mínimo 8 GB (recomendado 16 GB) |
| Disco | Al menos 15 GB libres |
| Teléfono | Android 6.0 o superior con cable USB |
| Internet | Conexión estable para descargar paquetes |

---

## 🪟 Instalación en Windows

### Paso 1 — Instalar Git

1. Descarga Git desde: https://git-scm.com/download/win
2. Ejecuta el instalador — acepta todas las opciones por defecto
3. Abre una terminal (PowerShell o CMD) y verifica:

```bash
git --version
```

Debes ver algo como: `git version 2.43.0`

### Paso 2 — Instalar Flutter SDK

1. Ve a https://docs.flutter.dev/install/quick
2. Descarga el archivo ZIP del Flutter SDK
3. Extrae el ZIP en una carpeta **sin espacios** en la ruta. Recomendado:

```
C:\flutter
```

⚠️ **NO** lo pongas en `C:\Archivos de Programa` ni `C:\Users\Mi Usuario` — los espacios causan errores.

4. Agrega Flutter al PATH del sistema:
   - Busca "Variables de entorno" en el menú de inicio
   - En "Variables del sistema" → busca `Path` → clic en "Editar"
   - Agrega: `C:\flutter\bin`
   - Acepta todo y cierra

5. Abre una **nueva** terminal y verifica:

```bash
flutter --version
```

Debes ver la versión de Flutter instalada.

### Paso 3 — Instalar Android Studio (solo para el SDK de Android)

Aunque usaremos VS Code como editor, necesitamos Android Studio para obtener el SDK de Android.

1. Descarga Android Studio desde: https://developer.android.com/studio
2. Instálalo con las opciones por defecto
3. Ábrelo por primera vez — dejará que descargue el Android SDK automáticamente
4. Ve a **Settings → Languages & Frameworks → Android SDK**
5. Anota la ruta del SDK (algo como `C:\Users\TuUsuario\AppData\Local\Android\Sdk`)
6. En la pestaña **SDK Tools**, asegúrate de tener instalado:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools

7. Configura la variable de entorno `ANDROID_HOME`:
   - Variables de entorno → Nueva variable del sistema
   - Nombre: `ANDROID_HOME`
   - Valor: la ruta del SDK que anotaste

### Paso 4 — Instalar VS Code y Extensiones

1. Descarga VS Code desde: https://code.visualstudio.com/
2. Instálalo y ábrelo
3. Instala estas extensiones (busca en el panel de extensiones):
   - **Flutter** (de Dart Code) — incluye Dart automáticamente
   - **Error Lens** — muestra errores directamente en el código (muy útil)
   - **Material Icon Theme** — iconos para los archivos (opcional pero recomendado)

### Paso 5 — Aceptar Licencias de Android

Abre una terminal y ejecuta:

```bash
flutter doctor --android-licenses
```

Acepta todas las licencias escribiendo `y` cuando pregunte.

### Paso 6 — Verificación Final

Ejecuta:

```bash
flutter doctor
```

Debes ver ✅ en al menos:
- Flutter
- Android toolchain
- VS Code
- Connected device (cuando conectes tu teléfono)

💡 Si ves ❌ en Chrome o Linux toolchain, no te preocupes — no los necesitamos para este curso.

---

## 🐧 Instalación en Linux (Ubuntu/Debian)

### Paso 1 — Instalar dependencias

```bash
sudo apt update
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
```

### Paso 2 — Instalar Flutter SDK

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

Agrega Flutter al PATH editando `~/.bashrc`:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verifica:

```bash
flutter --version
```

### Paso 3 — Instalar Android Studio y SDK

1. Descarga Android Studio desde: https://developer.android.com/studio
2. Extrae y ejecuta `studio.sh`
3. Completa el setup inicial (descargará el Android SDK)
4. Configura las variables de entorno:

```bash
echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> ~/.bashrc
echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

5. Acepta licencias:

```bash
flutter doctor --android-licenses
```

### Paso 4 — Instalar VS Code y Extensiones

```bash
sudo snap install code --classic
```

Abre VS Code e instala las mismas extensiones que en Windows:
- Flutter (de Dart Code)
- Error Lens
- Material Icon Theme

### Paso 5 — Verificación Final

```bash
flutter doctor
```

---

## 📱 Configurar tu Teléfono Android para Desarrollo

Este paso es **esencial** — vamos a ejecutar la app directamente en tu teléfono.

### Activar Opciones de Desarrollador

1. Ve a **Configuración → Acerca del teléfono**
2. Busca **"Número de compilación"** (puede estar en "Información del software")
3. Toca **7 veces** sobre "Número de compilación"
4. Verás el mensaje: "Ahora eres desarrollador"

### Activar Depuración USB

1. Ve a **Configuración → Opciones de desarrollador** (ahora visible)
2. Activa **"Depuración USB"**
3. Conecta tu teléfono a la computadora con cable USB
4. En tu teléfono aparecerá un diálogo: **"¿Permitir depuración USB?"** → Acepta y marca "Siempre"

### Verificar Conexión

En la terminal ejecuta:

```bash
flutter devices
```

Debes ver tu teléfono listado. Ejemplo:

```
SM A135M (mobile) • R58RA1XXXXX • android-arm64 • Android 13
```

⚠️ **Si no aparece:**
- Prueba otro cable USB (algunos solo cargan, no transmiten datos)
- En tu teléfono, cambia el modo USB de "Solo carga" a "Transferencia de archivos"
- En Windows, puede que necesites instalar el driver USB de tu marca de teléfono

---

## ✅ Checklist de Verificación Pre-Curso

Marca cada punto cuando lo tengas listo:

- [ ] `flutter --version` muestra la versión instalada
- [ ] `flutter doctor` muestra ✅ en Flutter, Android toolchain y VS Code
- [ ] VS Code tiene la extensión Flutter instalada
- [ ] Mi teléfono Android tiene Depuración USB activada
- [ ] `flutter devices` muestra mi teléfono conectado
- [ ] Tengo cuenta de GitHub creada

---

## 🆘 Problemas Comunes

### "flutter: command not found"
→ No agregaste Flutter al PATH correctamente. Revisa el paso correspondiente.

### "No connected devices"
→ Revisa que tu teléfono tenga Depuración USB activa y que el cable sea de datos.

### Flutter doctor muestra errores de Android SDK
→ Abre Android Studio, ve a SDK Manager y asegúrate de tener el SDK y tools instalados.

### "ANDROID_HOME not set"
→ Configura la variable de entorno como se indica en los pasos.

### Muy lento al descargar
→ Flutter descarga componentes la primera vez. Sé paciente con buena conexión a internet.

---

## 🎓 ¿Listo?

Si completaste todo el checklist, estás preparado para la Clase 1. Si tuviste algún problema que no pudiste resolver, trae tus dudas a la primera sesión — el instructor te ayudará a resolverlo.

*No te frustres si algo falla en la instalación — es la parte más tediosa de todo el curso. Una vez que funcione, todo fluye.*
