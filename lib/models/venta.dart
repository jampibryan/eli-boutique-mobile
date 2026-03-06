/// Modelo de Venta que corresponde a /api/ventas.
class Venta {
  final int id;
  final int cajaId;
  final String codigoVenta;
  final int clienteId;
  final double subTotal;
  final double igv;
  final double montoTotal;
  final DateTime? createdAt;
  final ClienteVenta? cliente;
  final EstadoTransaccion? estadoTransaccion;
  final List<DetalleVenta> detalles;
  final PagoVenta? pago;

  Venta({
    required this.id,
    required this.cajaId,
    required this.codigoVenta,
    required this.clienteId,
    required this.subTotal,
    required this.igv,
    required this.montoTotal,
    this.createdAt,
    this.cliente,
    this.estadoTransaccion,
    required this.detalles,
    this.pago,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      cajaId: json['caja_id'] ?? 0,
      codigoVenta: json['codigoVenta'] ?? '',
      clienteId: json['cliente_id'] ?? 0,
      subTotal: double.tryParse(json['subTotal']?.toString() ?? '0') ?? 0,
      igv: double.tryParse(json['IGV']?.toString() ?? '0') ?? 0,
      montoTotal: double.tryParse(json['montoTotal']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      cliente: json['cliente'] != null
          ? ClienteVenta.fromJson(json['cliente'])
          : null,
      estadoTransaccion: json['estado_transaccion'] != null
          ? EstadoTransaccion.fromJson(json['estado_transaccion'])
          : null,
      detalles: json['detalles'] != null
          ? (json['detalles'] as List)
              .map((d) => DetalleVenta.fromJson(d))
              .toList()
          : [],
      pago: json['pago'] != null ? PagoVenta.fromJson(json['pago']) : null,
    );
  }

  /// Nombre del cliente o 'Sin cliente'.
  String get clienteNombre =>
      cliente != null
          ? '${cliente!.nombreCliente} ${cliente!.apellidoCliente}'
          : 'Sin cliente';

  /// Estado de la transacción o 'Sin estado'.
  String get estadoNombre =>
      estadoTransaccion?.descripcionET ?? 'Sin estado';

  /// Tipo de comprobante o 'Sin comprobante'.
  String get comprobanteNombre =>
      pago?.comprobante?.descripcionCOM ?? 'Sin comprobante';

  /// Fecha formateada dd/MM/yyyy HH:mm.
  String get fechaFormateada {
    if (createdAt == null) return 'Sin fecha';
    final d = createdAt!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

/// Cliente resumido dentro de una venta.
class ClienteVenta {
  final int id;
  final String nombreCliente;
  final String apellidoCliente;
  final String dniCliente;

  ClienteVenta({
    required this.id,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.dniCliente,
  });

  factory ClienteVenta.fromJson(Map<String, dynamic> json) {
    return ClienteVenta(
      id: json['id'],
      nombreCliente: json['nombreCliente'] ?? '',
      apellidoCliente: json['apellidoCliente'] ?? '',
      dniCliente: json['dniCliente'] ?? '',
    );
  }
}

/// Estado de transacción (ej: "Pagado", "Anulado").
class EstadoTransaccion {
  final int id;
  final String descripcionET;

  EstadoTransaccion({
    required this.id,
    required this.descripcionET,
  });

  factory EstadoTransaccion.fromJson(Map<String, dynamic> json) {
    return EstadoTransaccion(
      id: json['id'],
      descripcionET: json['descripcionET'] ?? '',
    );
  }
}

/// Detalle de una venta (producto vendido).
class DetalleVenta {
  final int id;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double baseImponible;
  final double igv;
  final double subtotal;
  final ProductoResumen? producto;

  DetalleVenta({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.baseImponible,
    required this.igv,
    required this.subtotal,
    this.producto,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'],
      productoId: json['producto_id'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario:
          double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0,
      baseImponible:
          double.tryParse(json['base_imponible']?.toString() ?? '0') ?? 0,
      igv: double.tryParse(json['igv']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      producto: json['producto'] != null
          ? ProductoResumen.fromJson(json['producto'])
          : null,
    );
  }

  /// Nombre del producto o 'Producto #id'.
  String get productoNombre =>
      producto?.descripcionP ?? 'Producto #$productoId';
}

/// Pago asociado a una venta.
class PagoVenta {
  final int id;
  final double importe;
  final double vuelto;
  final Comprobante? comprobante;

  PagoVenta({
    required this.id,
    required this.importe,
    required this.vuelto,
    this.comprobante,
  });

  factory PagoVenta.fromJson(Map<String, dynamic> json) {
    return PagoVenta(
      id: json['id'],
      importe: double.tryParse(json['importe']?.toString() ?? '0') ?? 0,
      vuelto: double.tryParse(json['vuelto']?.toString() ?? '0') ?? 0,
      comprobante: json['comprobante'] != null
          ? Comprobante.fromJson(json['comprobante'])
          : null,
    );
  }
}

/// Tipo de comprobante (ej: "Boleta", "Factura").
class Comprobante {
  final int id;
  final String descripcionCOM;

  Comprobante({
    required this.id,
    required this.descripcionCOM,
  });

  factory Comprobante.fromJson(Map<String, dynamic> json) {
    return Comprobante(
      id: json['id'],
      descripcionCOM: json['descripcionCOM'] ?? '',
    );
  }
}

/// Producto resumido dentro de un detalle.
class ProductoResumen {
  final int id;
  final String codigoP;
  final String descripcionP;
  final double precioP;

  ProductoResumen({
    required this.id,
    required this.codigoP,
    required this.descripcionP,
    required this.precioP,
  });

  factory ProductoResumen.fromJson(Map<String, dynamic> json) {
    return ProductoResumen(
      id: json['id'],
      codigoP: json['codigoP'] ?? '',
      descripcionP: json['descripcionP'] ?? '',
      precioP: double.tryParse(json['precioP']?.toString() ?? '0') ?? 0,
    );
  }
}
