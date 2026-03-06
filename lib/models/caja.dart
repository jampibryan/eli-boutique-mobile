/// Modelo de Caja que corresponde a /api/cajas.
class Caja {
  final int id;
  final String codigoCaja;
  final String fecha;
  final String? horaCierre;
  final int clientesHoy;
  final int productosVendidos;
  final double ingresoDiario;
  final double egresoDiario;
  final DateTime? createdAt;
  // Solo en detalle:
  final double? balanceDiario;
  final List<VentaCaja> ventas;

  Caja({
    required this.id,
    required this.codigoCaja,
    required this.fecha,
    this.horaCierre,
    required this.clientesHoy,
    required this.productosVendidos,
    required this.ingresoDiario,
    required this.egresoDiario,
    this.createdAt,
    this.balanceDiario,
    required this.ventas,
  });

  factory Caja.fromJson(Map<String, dynamic> json) {
    return Caja(
      id: json['id'],
      codigoCaja: json['codigoCaja'] ?? '',
      fecha: json['fecha'] ?? '',
      horaCierre: json['hora_cierre'],
      clientesHoy: json['clientesHoy'] ?? 0,
      productosVendidos: json['productosVendidos'] ?? 0,
      ingresoDiario:
          double.tryParse(json['ingresoDiario']?.toString() ?? '0') ?? 0,
      egresoDiario:
          double.tryParse(json['egresoDiario']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      balanceDiario: json['balance_diario'] != null
          ? double.tryParse(json['balance_diario']?.toString() ?? '0')
          : null,
      ventas: json['ventas'] != null
          ? (json['ventas'] as List)
              .map((v) => VentaCaja.fromJson(v))
              .toList()
          : [],
    );
  }

  /// Fecha formateada dd/MM/yyyy.
  String get fechaFormateada {
    final parts = fecha.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return fecha;
  }

  /// Estado de la caja (abierta si no tiene hora_cierre).
  bool get estaAbierta => horaCierre == null;

  /// Balance calculado (ingreso - egreso).
  double get balance => balanceDiario ?? (ingresoDiario - egresoDiario);
}

/// Venta resumida dentro de una caja.
class VentaCaja {
  final int id;
  final String codigoVenta;
  final int clienteId;
  final double subTotal;
  final double igv;
  final double montoTotal;
  final DateTime? createdAt;
  final ClienteVentaCaja? cliente;

  VentaCaja({
    required this.id,
    required this.codigoVenta,
    required this.clienteId,
    required this.subTotal,
    required this.igv,
    required this.montoTotal,
    this.createdAt,
    this.cliente,
  });

  factory VentaCaja.fromJson(Map<String, dynamic> json) {
    return VentaCaja(
      id: json['id'],
      codigoVenta: json['codigoVenta'] ?? '',
      clienteId: json['cliente_id'] ?? 0,
      subTotal: double.tryParse(json['subTotal']?.toString() ?? '0') ?? 0,
      igv: double.tryParse(json['IGV']?.toString() ?? '0') ?? 0,
      montoTotal:
          double.tryParse(json['montoTotal']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      cliente: json['cliente'] != null
          ? ClienteVentaCaja.fromJson(json['cliente'])
          : null,
    );
  }

  /// Nombre del cliente o 'Sin cliente'.
  String get clienteNombre => cliente != null
      ? '${cliente!.nombreCliente} ${cliente!.apellidoCliente}'
      : 'Sin cliente';

  /// Hora formateada HH:mm.
  String get horaFormateada {
    if (createdAt == null) return '';
    final d = createdAt!;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

/// Cliente resumido dentro de una venta de caja.
class ClienteVentaCaja {
  final int id;
  final String nombreCliente;
  final String apellidoCliente;
  final String dniCliente;

  ClienteVentaCaja({
    required this.id,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.dniCliente,
  });

  factory ClienteVentaCaja.fromJson(Map<String, dynamic> json) {
    return ClienteVentaCaja(
      id: json['id'],
      nombreCliente: json['nombreCliente'] ?? '',
      apellidoCliente: json['apellidoCliente'] ?? '',
      dniCliente: json['dniCliente'] ?? '',
    );
  }
}
