# 📱 Eli Boutique Mobile

Aplicación móvil desarrollada con **Flutter** y **Dart** para la gestión y consulta del sistema de ventas **Eli Boutique**. La app consume una API REST construida con **Laravel** y permite visualizar en tiempo real la información del negocio desde cualquier dispositivo conectado a la red local.

> **Nota:** Esta aplicación es de **solo lectura** (consulta y visualización). No realiza operaciones de creación, edición ni eliminación de datos.

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Ejecución](#-ejecución)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Módulos](#-módulos)
- [Endpoints Consumidos](#-endpoints-consumidos)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Solución de Problemas](#-solución-de-problemas)
- [Autor](#-autor)

---

## 📖 Descripción

Eli Boutique Mobile es el cliente móvil del sistema de gestión de ventas para una boutique de ropa. La aplicación permite a los administradores y colaboradores consultar información clave del negocio desde su celular o navegador, incluyendo:

- **Dashboard** con estadísticas del día (ventas, clientes, productos, proveedores, estado de caja)
- **Catálogo de productos** con imágenes, precios, categorías y stock desglosado por talla
- **Directorio de clientes** con datos de contacto, DNI y género
- Búsqueda y filtrado en productos (nombre, código, categoría) y clientes (nombre, DNI, correo, teléfono)

---

## 🏗 Arquitectura

El sistema sigue una arquitectura cliente-servidor de tres capas:

```
┌─────────────────────┐
│  Flutter Mobile App  │  ← Aplicación de consulta (esta app)
│  (Dart + Flutter)    │
└──────────┬──────────┘
           │ HTTP GET (JSON)
           ▼
┌─────────────────────┐
│    Laravel API       │  ← Backend REST API
│  (PHP + Laravel)     │
└──────────┬──────────┘
           │ Eloquent ORM
           ▼
┌─────────────────────┐
│    Base de Datos     │  ← Almacenamiento
│      (MySQL)         │
└─────────────────────┘
```

### Patrón de la app Flutter

```
Config  →  Service  →  Model  →  Screen
  │            │          │          │
  │  URL base  │  HTTP    │  JSON    │  UI con
  │  y headers │  GET     │  parsing │  widgets
```

- **Config**: Configuración centralizada (IP, puerto, timeout)
- **Services**: Capa de comunicación HTTP con la API
- **Models**: Modelos de datos con parsing `fromJson()`
- **Screens**: Pantallas de UI con manejo de estados (loading, error, datos)
- **Widgets**: Componentes reutilizables

---

## 🛠 Tecnologías

| Tecnología | Versión | Uso |
|-----------|---------|-----|
| Flutter | 3.41.x | Framework de UI multiplataforma |
| Dart | 3.11.x | Lenguaje de programación |
| http | 1.3.x | Cliente HTTP para consumir APIs |
| Material 3 | — | Sistema de diseño de UI |
| Laravel | 10.x / 11.x | Backend API (proyecto separado) |
| MySQL | 8.x | Base de datos (proyecto separado) |

---

## ✅ Requisitos Previos

### Para la app Flutter

- **Flutter SDK** ≥ 3.41.0 instalado ([guía de instalación](https://docs.flutter.dev/get-started/install))
- **Google Chrome** (para pruebas web) o un dispositivo Android conectado
- **Git** para clonar el repositorio

### Para compilar APK (Android)

- **Android Studio** instalado ([descargar](https://developer.android.com/studio))
- **Android SDK** versión 36.x o superior
- **Android SDK Command-line Tools** (ver sección de configuración abajo)
- **Licencias del SDK** aceptadas
- **Java JDK 21** (incluido con Android Studio)

### Para el backend (proyecto separado)

- **PHP** ≥ 8.1 con Laravel
- **MySQL** con la base de datos del sistema Eli Boutique
- El servidor Laravel debe estar corriendo y accesible

### Verificar instalación

```bash
flutter doctor -v
```

Todos los ítems deben mostrar **[√]** (excepto Visual Studio si no desarrollas para Windows nativo).

---

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/eli_boutique_mobile.git
cd eli_boutique_mobile
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Verificar que no hay errores

```bash
flutter analyze
```

---

## 🤖 Configuración de Android (para compilar APK)

Si solo vas a probar en Chrome no necesitas esto, pero para **generar el APK** o probar en un celular Android, sigue estos pasos:

### Paso 1: Instalar Android Studio

1. Descarga e instala [Android Studio](https://developer.android.com/studio)
2. Durante la instalación, asegúrate de instalar el **Android SDK**
3. El SDK se instalará por defecto en:
   ```
   C:\Users\<tu_usuario>\AppData\Local\Android\sdk
   ```

### Paso 2: Instalar SDK Command-line Tools

Este componente es **obligatorio** y no viene instalado por defecto:

1. Abre **Android Studio**
2. Ve a **Settings** → **Languages & Frameworks** → **Android SDK**
3. Pestaña **SDK Tools**
4. Marca la casilla **☑ Android SDK Command-line Tools (latest)**
5. Click en **Apply** → **OK** y espera que se descargue

> Sin este componente, `flutter doctor` mostrará el error: _"cmdline-tools component is missing"_ y no podrás compilar el APK.

### Paso 3: Aceptar licencias del SDK

Ejecuta en la terminal:

```bash
flutter doctor --android-licenses
```

Presiona **`y`** + Enter para aceptar cada licencia (serán aproximadamente 6).

### Paso 4: Verificar que todo esté correcto

```bash
flutter doctor -v
```

Deberías ver:

```
[√] Flutter (Channel stable, 3.41.x)
[√] Android toolchain - develop for Android devices (Android SDK version 36.x.x)
[√] Chrome - develop for the web
```

> **Nota:** El ítem `[X] Visual Studio` es solo para apps nativas de Windows (`.exe`). No afecta la compilación de APK ni la ejecución en Chrome.

---

## ⚙ Configuración

### Configurar la URL de la API

Edita el archivo `lib/config/api_config.dart` con la IP y puerto de tu servidor Laravel:

```dart
class ApiConfig {
  static const String _host = '127.0.0.1';   // IP del servidor Laravel
  static const int _port = 8000;              // Puerto de Laravel
  // ...
}
```

#### Escenarios de configuración

| Escenario | `_host` | Notas |
|-----------|---------|-------|
| Chrome en la misma laptop | `127.0.0.1` o `localhost` | Ambos funcionan |
| Celular Android por WiFi | `192.168.x.x` | IP local de la laptop (ver con `ipconfig`) |
| Producción | `api.tudominio.com` | Dominio del servidor en producción |

### Iniciar el servidor Laravel

En el proyecto Laravel, ejecuta:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

> El flag `--host=0.0.0.0` permite conexiones desde otros dispositivos en la red.

---

## 🚀 Ejecución

### En navegador Chrome (desarrollo rápido)

```bash
flutter run -d chrome
```

Si hay problemas de CORS durante el desarrollo:

```bash
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

> ⚠️ El flag `--disable-web-security` es **solo para desarrollo local**. Nunca usar en producción.

### En dispositivo Android (USB)

1. Habilita **Opciones de desarrollador** en tu celular:
   - Ve a **Ajustes** → **Acerca del teléfono** → toca 7 veces "Número de compilación"
2. Activa **Depuración USB** en Opciones de desarrollador
3. Conecta el celular por USB y acepta la ventana de autorización
4. Verifica que Flutter detecte el dispositivo:
   ```bash
   flutter devices
   ```
5. Ejecuta la app:
   ```bash
   flutter run
   ```
   Flutter seleccionará automáticamente el dispositivo Android conectado.

> **Importante:** Si la app se conecta a la API en tu laptop, configura `_host` en `api_config.dart` con la IP local de tu laptop (ej: `192.168.0.102`), no `127.0.0.1`. Usa `ipconfig` para encontrarla.

### En emulador Android

1. Abre Android Studio → **Device Manager** → crea un emulador (ej: Pixel 7, API 34)
2. Inicia el emulador
3. Ejecuta:
   ```bash
   flutter run
   ```

> En el emulador, usa `10.0.2.2` como host en `api_config.dart` para acceder a `localhost` de tu laptop.

### Compilar APK de producción

Requisito: tener Android Studio + SDK + licencias configurados (ver sección anterior).

```bash
flutter build apk --release
```

El APK generado estará en:

```
build/app/outputs/flutter-apk/app-release.apk
```

Para instalar directamente en un dispositivo conectado:

```bash
flutter install
```

### Compilar App Bundle (para Google Play Store)

```bash
flutter build appbundle --release
```

El archivo `.aab` estará en `build/app/outputs/bundle/release/app-release.aab`.

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                              # Punto de entrada + navegación principal
├── config/
│   └── api_config.dart                    # URL base, puerto, timeout, headers
├── models/
│   ├── dashboard.dart                     # Modelo: estadísticas del negocio
│   ├── producto.dart                      # Modelos: Producto, Categoría, Género, Talla, Stock
│   └── cliente.dart                       # Modelos: Cliente, TipoGenero
├── services/
│   └── api_service.dart                   # Cliente HTTP centralizado (solo GET)
├── screens/
│   ├── dashboard_screen.dart              # Pantalla principal con tarjetas de estadísticas
│   ├── productos/
│   │   ├── productos_list.dart            # Lista de productos con búsqueda y filtros
│   │   └── producto_detail.dart           # Detalle de producto con stock por talla
│   └── clientes/
│       ├── clientes_list.dart             # Lista de clientes con búsqueda y filtro por género
│       └── cliente_detail.dart            # Detalle de cliente con info de contacto
└── widgets/
    ├── stat_card.dart                     # Tarjeta de estadística reutilizable
    ├── loading_indicator.dart             # Indicador de carga con mensaje
    └── error_display.dart                 # Pantalla de error con botón reintentar
```

---

## 📱 Módulos

### 1. Dashboard
- Fecha actual del sistema
- Estado de caja (abierta/cerrada)
- Tarjetas con: ventas del día, total de clientes, total de productos, total de proveedores

### 2. Productos
- **Lista**: cards con imagen, nombre, código, categoría, precio, stock por talla
- **Búsqueda**: filtro en tiempo real por nombre o código de producto
- **Filtro por categoría**: chips horizontales para filtrar por tipo de prenda
- **Detalle**: imagen ampliada, badges de código y género, precio, grid visual de stock por talla (S, M, L, XL)

### 3. Clientes
- **Lista**: cards con avatar de iniciales (coloreado por género), nombre completo, DNI y teléfono
- **Búsqueda**: filtro en tiempo real por nombre, DNI, correo electrónico o teléfono
- **Filtro por género**: chips horizontales (Hombre / Mujer)
- **Detalle**: avatar grande, badge de género, tarjeta de contacto (DNI, correo, teléfono) y tarjeta de datos del registro (nombre, apellido, género)

### Módulos pendientes de implementar

| Módulo | Endpoint | Estado |
|--------|----------|--------|
| Ventas | `/api/ventas` | 🔲 Pendiente |
| Compras | `/api/compras` | 🔲 Pendiente |
| Proveedores | `/api/proveedores` | 🔲 Pendiente |
| Cajas | `/api/cajas` | 🔲 Pendiente |

---

## 🔌 Endpoints Consumidos

Todos los endpoints devuelven la estructura estándar:

```json
{
  "success": true,
  "data": { ... }
}
```

| Método | Endpoint | Descripción | Módulo |
|--------|----------|-------------|--------|
| GET | `/api/dashboard` | Estadísticas generales del día | Dashboard |
| GET | `/api/productos` | Lista de todos los productos con stock | Productos |
| GET | `/api/productos/{id}` | Detalle de un producto específico | Productos |
| GET | `/api/clientes` | Lista de todos los clientes | Clientes |

---

## 🖼 Capturas de Pantalla

> _Pendiente: agregar capturas de las pantallas de Dashboard, Productos y Clientes._

---

## 🔧 Solución de Problemas

### Error: "Failed to fetch" o "ClientException"

- Verifica que Laravel esté corriendo: `php artisan serve --host=0.0.0.0 --port=8000`
- Verifica la IP en `lib/config/api_config.dart`
- Si usas Chrome, prueba con `--disable-web-security`

### Error: "Bottom overflowed"

- Puede ocurrir en pantallas pequeñas. Los widgets están diseñados para ser responsivos, pero ajusta el `childAspectRatio` en el grid si es necesario.

### Error de CORS en navegador

- Asegúrate de que Laravel tenga configurado `config/cors.php` con `allowed_origins => ['*']`
- Alternativa: ejecuta Chrome sin seguridad web (solo para desarrollo)

### Las imágenes no se muestran

- Verifica que Laravel sirva los archivos estáticos correctamente
- La app construye las URLs de imagen con `ApiConfig.serverUrl` + la ruta relativa del producto

### ¿Cómo verificar mi IP local?

```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
```

Busca la dirección IPv4 en el adaptador WiFi.

---

## 👤 Autor

Desarrollado por JampiBryan.

---

## 📄 Licencia

Este proyecto es de uso académico y privado. No está publicado en pub.dev.
