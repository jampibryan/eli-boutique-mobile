/// Configuración centralizada de la API.
/// Cambia [_host] según tu entorno (LAN, producción, etc).
class ApiConfig {
  // ============================================================
  // IP de tu laptop en la red WiFi local.
  // Ajústala si cambia tu IP (ipconfig en terminal).
  // ============================================================
  static const String _host = '127.0.0.1';
  static const int _port = 8000;

  /// URL base del servidor Laravel (para imágenes y assets)
  static const String serverUrl = 'http://$_host:$_port';

  /// URL base de la API Laravel
  static const String baseUrl = '$serverUrl/api';

  /// Timeout de conexión en segundos
  static const int connectionTimeout = 15;

  /// Headers por defecto para todas las peticiones
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
      };

  /// Construye la URL completa de una imagen del servidor.
  /// Ejemplo: '/img/productos/foto.webp' → 'http://192.168.0.102:8000/img/productos/foto.webp'
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$serverUrl$path';
  }
}
