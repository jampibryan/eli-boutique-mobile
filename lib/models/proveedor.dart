/// Modelo de Proveedor que corresponde a /api/proveedores.
class Proveedor {
  final int id;
  final String nombreEmpresa;
  final String nombreProveedor;
  final String apellidoProveedor;
  final String ruc;
  final String? direccionProveedor;
  final String? correoProveedor;
  final String? telefonoProveedor;

  Proveedor({
    required this.id,
    required this.nombreEmpresa,
    required this.nombreProveedor,
    required this.apellidoProveedor,
    required this.ruc,
    this.direccionProveedor,
    this.correoProveedor,
    this.telefonoProveedor,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombreEmpresa: json['nombreEmpresa'] ?? '',
      nombreProveedor: json['nombreProveedor'] ?? '',
      apellidoProveedor: json['apellidoProveedor'] ?? '',
      ruc: json['RUC'] ?? '',
      direccionProveedor: json['direccionProveedor'],
      correoProveedor: json['correoProveedor'],
      telefonoProveedor: json['telefonoProveedor'],
    );
  }

  /// Nombre completo del contacto.
  String get contactoNombre => '$nombreProveedor $apellidoProveedor';

  /// Iniciales de la empresa (primeras 2 letras).
  String get iniciales {
    final palabras = nombreEmpresa.split(' ');
    if (palabras.length >= 2) {
      return '${palabras[0][0]}${palabras[1][0]}'.toUpperCase();
    }
    return nombreEmpresa.substring(0, nombreEmpresa.length >= 2 ? 2 : 1).toUpperCase();
  }
}
