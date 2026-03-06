import 'venta.dart';

/// Modelo de Compra que corresponde a /api/compras.
class Compra {
  final int id;
  final String codigoCompra;
  final int proveedorId;
  final String? fechaEnvio;
  final String? fechaCotizacion;
  final String? fechaAprobacion;
  final String? fechaEntregaEstimada;
  final double subtotal;
  final double descuento;
  final double igv;
  final double total;
  final String? notasProveedor;
  final String? condicionesPago;
  final int? diasCredito;
  final DateTime? createdAt;
  final ProveedorCompra? proveedor;
  final EstadoTransaccion? estadoTransaccion;
  final Comprobante? comprobante;
  final List<DetalleCompra> detalles;
  final PagoCompra? pago;

  Compra({
    required this.id,
    required this.codigoCompra,
    required this.proveedorId,
    this.fechaEnvio,
    this.fechaCotizacion,
    this.fechaAprobacion,
    this.fechaEntregaEstimada,
    required this.subtotal,
    required this.descuento,
    required this.igv,
    required this.total,
    this.notasProveedor,
    this.condicionesPago,
    this.diasCredito,
    this.createdAt,
    this.proveedor,
    this.estadoTransaccion,
    this.comprobante,
    required this.detalles,
    this.pago,
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      id: json['id'],
      codigoCompra: json['codigoCompra'] ?? '',
      proveedorId: json['proveedor_id'] ?? 0,
      fechaEnvio: json['fecha_envio'],
      fechaCotizacion: json['fecha_cotizacion'],
      fechaAprobacion: json['fecha_aprobacion'],
      fechaEntregaEstimada: json['fecha_entrega_estimada'],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      descuento: double.tryParse(json['descuento']?.toString() ?? '0') ?? 0,
      igv: double.tryParse(json['igv']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      notasProveedor: json['notas_proveedor'],
      condicionesPago: json['condiciones_pago'],
      diasCredito: json['dias_credito'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      proveedor: json['proveedor'] != null
          ? ProveedorCompra.fromJson(json['proveedor'])
          : null,
      estadoTransaccion: json['estado_transaccion'] != null
          ? EstadoTransaccion.fromJson(json['estado_transaccion'])
          : null,
      comprobante: json['comprobante'] != null
          ? Comprobante.fromJson(json['comprobante'])
          : null,
      detalles: json['detalles'] != null
          ? (json['detalles'] as List)
              .map((d) => DetalleCompra.fromJson(d))
              .toList()
          : [],
      pago: json['pago'] != null ? PagoCompra.fromJson(json['pago']) : null,
    );
  }

  /// Nombre de la empresa proveedora o 'Sin proveedor'.
  String get proveedorNombre =>
      proveedor?.nombreEmpresa ?? 'Sin proveedor';

  /// Estado de la transacción o 'Sin estado'.
  String get estadoNombre =>
      estadoTransaccion?.descripcionET ?? 'Sin estado';

  /// Tipo de comprobante o 'Sin comprobante'.
  String get comprobanteNombre =>
      comprobante?.descripcionCOM ?? 'Sin comprobante';

  /// Fecha de creación formateada dd/MM/yyyy.
  String get fechaFormateada {
    if (createdAt == null) return 'Sin fecha';
    final d = createdAt!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  /// Fecha de entrega estimada formateada.
  String get entregaFormateada {
    if (fechaEntregaEstimada == null) return 'Sin fecha';
    final parts = fechaEntregaEstimada!.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return fechaEntregaEstimada!;
  }
}

/// Proveedor resumido dentro de una compra.
class ProveedorCompra {
  final int id;
  final String nombreEmpresa;
  final String nombreProveedor;
  final String apellidoProveedor;
  final String ruc;
  final String? direccionProveedor;
  final String? correoProveedor;
  final String? telefonoProveedor;

  ProveedorCompra({
    required this.id,
    required this.nombreEmpresa,
    required this.nombreProveedor,
    required this.apellidoProveedor,
    required this.ruc,
    this.direccionProveedor,
    this.correoProveedor,
    this.telefonoProveedor,
  });

  factory ProveedorCompra.fromJson(Map<String, dynamic> json) {
    return ProveedorCompra(
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

  /// Nombre completo del contacto del proveedor.
  String get contactoNombre => '$nombreProveedor $apellidoProveedor';
}

/// Detalle de una compra (producto comprado).
class DetalleCompra {
  final int id;
  final int productoId;
  final int cantidad;
  final double precioCotizado;
  final double precioFinal;
  final double descuentoUnitario;
  final double subtotalLinea;
  final ProductoResumen? producto;

  DetalleCompra({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.precioCotizado,
    required this.precioFinal,
    required this.descuentoUnitario,
    required this.subtotalLinea,
    this.producto,
  });

  factory DetalleCompra.fromJson(Map<String, dynamic> json) {
    return DetalleCompra(
      id: json['id'],
      productoId: json['producto_id'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      precioCotizado:
          double.tryParse(json['precio_cotizado']?.toString() ?? '0') ?? 0,
      precioFinal:
          double.tryParse(json['precio_final']?.toString() ?? '0') ?? 0,
      descuentoUnitario:
          double.tryParse(json['descuento_unitario']?.toString() ?? '0') ?? 0,
      subtotalLinea:
          double.tryParse(json['subtotal_linea']?.toString() ?? '0') ?? 0,
      producto: json['producto'] != null
          ? ProductoResumen.fromJson(json['producto'])
          : null,
    );
  }

  /// Nombre del producto o 'Producto #id'.
  String get productoNombre =>
      producto?.descripcionP ?? 'Producto #$productoId';
}

/// Pago asociado a una compra.
class PagoCompra {
  final int id;
  final double importe;
  final double vuelto;

  PagoCompra({
    required this.id,
    required this.importe,
    required this.vuelto,
  });

  factory PagoCompra.fromJson(Map<String, dynamic> json) {
    return PagoCompra(
      id: json['id'],
      importe: double.tryParse(json['importe']?.toString() ?? '0') ?? 0,
      vuelto: double.tryParse(json['vuelto']?.toString() ?? '0') ?? 0,
    );
  }
}
