/// Modelo de Cliente que corresponde a /api/clientes.
class Cliente {
  final int id;
  final String nombreCliente;
  final String apellidoCliente;
  final String dniCliente;
  final String? correoCliente;
  final String? telefonoCliente;
  final TipoGenero? tipoGenero;

  Cliente({
    required this.id,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.dniCliente,
    this.correoCliente,
    this.telefonoCliente,
    this.tipoGenero,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombreCliente: json['nombreCliente'] ?? '',
      apellidoCliente: json['apellidoCliente'] ?? '',
      dniCliente: json['dniCliente'] ?? '',
      correoCliente: json['correoCliente'],
      telefonoCliente: json['telefonoCliente'],
      tipoGenero: json['tipo_genero'] != null
          ? TipoGenero.fromJson(json['tipo_genero'])
          : null,
    );
  }

  /// Nombre completo del cliente.
  String get nombreCompleto => '$nombreCliente $apellidoCliente';

  /// Descripción del género o 'Sin especificar'.
  String get generoNombre => tipoGenero?.descripcionTG ?? 'Sin especificar';

  /// Iniciales del cliente para el avatar.
  String get iniciales {
    final n = nombreCliente.isNotEmpty ? nombreCliente[0] : '';
    final a = apellidoCliente.isNotEmpty ? apellidoCliente[0] : '';
    return '$n$a'.toUpperCase();
  }

  @override
  String toString() => 'Cliente($id: $nombreCompleto)';
}

/// Tipo de género del cliente (ej: "Hombre", "Mujer").
class TipoGenero {
  final int id;
  final String descripcionTG;

  TipoGenero({
    required this.id,
    required this.descripcionTG,
  });

  factory TipoGenero.fromJson(Map<String, dynamic> json) {
    return TipoGenero(
      id: json['id'],
      descripcionTG: json['descripcionTG'] ?? '',
    );
  }
}
