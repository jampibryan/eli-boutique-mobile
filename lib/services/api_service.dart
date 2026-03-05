import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Excepción personalizada para errores de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Servicio HTTP de solo lectura que centraliza las consultas a la API Laravel.
///
/// Todos los endpoints devuelven: {"success": true, "data": ...}
///
/// Uso:
/// ```dart
/// final api = ApiService();
/// final data = await api.getData('/dashboard');
/// final list = await api.getList('/productos');
/// ```
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Construye la URI completa a partir de un endpoint relativo.
  Uri _buildUri(String endpoint, {Map<String, String>? queryParams}) {
    final url = '${ApiConfig.baseUrl}$endpoint';
    final uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// Realiza un GET y devuelve el JSON completo parseado.
  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final response = await _client
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(Duration(seconds: ApiConfig.connectionTimeout));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          return body;
        }
        throw ApiException(
          body['message'] ?? 'La API respondió con success=false',
          statusCode: response.statusCode,
        );
      }

      // Manejar errores HTTP
      switch (response.statusCode) {
        case 401:
          throw ApiException('No autorizado', statusCode: 401);
        case 403:
          throw ApiException('Acceso prohibido', statusCode: 403);
        case 404:
          throw ApiException('Recurso no encontrado', statusCode: 404);
        case 500:
          throw ApiException('Error interno del servidor', statusCode: 500);
        default:
          throw ApiException(
            'Error del servidor: ${response.statusCode}',
            statusCode: response.statusCode,
          );
      }
    } on SocketException {
      throw ApiException(
        'Sin conexión al servidor. Verifica que Laravel esté corriendo '
        'y que estés en la misma red WiFi.',
      );
    } on TimeoutException {
      throw ApiException(
        'Tiempo de espera agotado. El servidor no respondió.',
      );
    } on FormatException {
      throw ApiException('Respuesta con formato inválido del servidor.');
    }
  }

  /// Consulta un endpoint y devuelve "data" como Map (para objetos individuales).
  /// Ejemplo: getData('/dashboard') → {"fecha": ..., "ventas_hoy": ...}
  Future<Map<String, dynamic>> getData(String endpoint) async {
    final body = await _get(endpoint);
    return body['data'] as Map<String, dynamic>;
  }

  /// Consulta un endpoint y devuelve "data" como List (para listas).
  /// Ejemplo: getList('/productos') → [{...}, {...}]
  Future<List<dynamic>> getList(String endpoint) async {
    final body = await _get(endpoint);
    return body['data'] as List<dynamic>;
  }

  /// Liberar recursos del cliente HTTP.
  void dispose() {
    _client.close();
  }
}
