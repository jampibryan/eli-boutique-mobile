/// Modelo del Dashboard que corresponde a /api/dashboard.
///
/// JSON de ejemplo:
/// {"fecha":"2026-03-04","caja":null,"ventas_hoy":0,
///  "total_clientes":60,"total_productos":19,"total_proveedores":5}
class Dashboard {
  final String fecha;
  final dynamic caja; // null cuando no hay caja abierta
  final int ventasHoy;
  final int totalClientes;
  final int totalProductos;
  final int totalProveedores;

  Dashboard({
    required this.fecha,
    this.caja,
    required this.ventasHoy,
    required this.totalClientes,
    required this.totalProductos,
    required this.totalProveedores,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      fecha: json['fecha'] ?? '',
      caja: json['caja'],
      ventasHoy: json['ventas_hoy'] ?? 0,
      totalClientes: json['total_clientes'] ?? 0,
      totalProductos: json['total_productos'] ?? 0,
      totalProveedores: json['total_proveedores'] ?? 0,
    );
  }

  /// Si hay caja abierta hoy.
  bool get cajaAbierta => caja != null;
}
