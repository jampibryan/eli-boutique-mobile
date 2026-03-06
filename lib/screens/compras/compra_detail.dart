import 'package:flutter/material.dart';

import '../../models/compra.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';

/// Pantalla de detalle de una compra desde /api/compras/{id}.
class CompraDetailScreen extends StatefulWidget {
  final int compraId;

  const CompraDetailScreen({super.key, required this.compraId});

  @override
  State<CompraDetailScreen> createState() => _CompraDetailScreenState();
}

class _CompraDetailScreenState extends State<CompraDetailScreen> {
  final ApiService _api = ApiService();

  Compra? _compra;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCompra();
  }

  Future<void> _fetchCompra() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getData('/compras/${widget.compraId}');
      setState(() {
        _compra = Compra.fromJson(data);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
        _isLoading = false;
      });
    }
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Colors.green;
      case 'anulado':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      case 'aprobado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_compra?.codigoCompra ?? 'Detalle compra'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando compra...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchCompra);
    }

    final c = _compra!;
    final estadoColor = _estadoColor(c.estadoNombre);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Text(
                  c.codigoCompra,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.estadoNombre,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.fechaFormateada,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Información del proveedor
          if (c.proveedor != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proveedor',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.business,
                        label: 'Empresa',
                        value: c.proveedor!.nombreEmpresa,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.person_outlined,
                        label: 'Contacto',
                        value: c.proveedor!.contactoNombre,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.numbers,
                        label: 'RUC',
                        value: c.proveedor!.ruc,
                      ),
                      if (c.proveedor!.correoProveedor != null) ...[
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Correo',
                          value: c.proveedor!.correoProveedor!,
                        ),
                      ],
                      if (c.proveedor!.telefonoProveedor != null) ...[
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Teléfono',
                          value: c.proveedor!.telefonoProveedor!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Fechas relevantes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fechas',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (c.fechaCotizacion != null)
                      _FechaChip(
                          label: 'Cotización', fecha: c.fechaCotizacion!),
                    if (c.fechaAprobacion != null)
                      _FechaChip(
                          label: 'Aprobación', fecha: c.fechaAprobacion!),
                    if (c.fechaEnvio != null)
                      _FechaChip(label: 'Envío', fecha: c.fechaEnvio!),
                    if (c.fechaEntregaEstimada != null)
                      _FechaChip(
                          label: 'Entrega estimada',
                          fecha: c.fechaEntregaEstimada!),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Detalle de productos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos (${c.detalles.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...c.detalles.map((d) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${d.cantidad}x',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.productoNombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cotizado: S/ ${d.precioCotizado.toStringAsFixed(2)} → Final: S/ ${d.precioFinal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${d.subtotalLinea.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Resumen de montos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _MontoRow(label: 'Subtotal', monto: c.subtotal),
                    const Divider(height: 16),
                    _MontoRow(label: 'Descuento', monto: c.descuento),
                    const Divider(height: 16),
                    _MontoRow(label: 'IGV', monto: c.igv),
                    const Divider(height: 16),
                    _MontoRow(
                      label: 'Total',
                      monto: c.total,
                      destacado: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Condiciones de pago
          if (c.condicionesPago != null || c.diasCredito != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Condiciones',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (c.condicionesPago != null)
                        _InfoRow(
                          icon: Icons.handshake_outlined,
                          label: 'Condiciones de pago',
                          value: c.condicionesPago!,
                        ),
                      if (c.condicionesPago != null && c.diasCredito != null)
                        const Divider(height: 20),
                      if (c.diasCredito != null)
                        _InfoRow(
                          icon: Icons.access_time_outlined,
                          label: 'Días de crédito',
                          value: '${c.diasCredito} días',
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Pago
          if (c.pago != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pago',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Comprobante',
                        value: c.comprobanteNombre,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Importe',
                        value: 'S/ ${c.pago!.importe.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.money_off_outlined,
                        label: 'Vuelto',
                        value: 'S/ ${c.pago!.vuelto.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Fila de información con ícono.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.deepPurple),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de monto.
class _MontoRow extends StatelessWidget {
  final String label;
  final double monto;
  final bool destacado;

  const _MontoRow({
    required this.label,
    required this.monto,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: destacado ? 17 : 15,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
            color: destacado ? Colors.deepPurple : null,
          ),
        ),
        Text(
          'S/ ${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: destacado ? 20 : 15,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
            color: destacado ? Colors.deepPurple : null,
          ),
        ),
      ],
    );
  }
}

/// Chip de fecha con etiqueta.
class _FechaChip extends StatelessWidget {
  final String label;
  final String fecha;

  const _FechaChip({required this.label, required this.fecha});

  String _formatFecha(String fecha) {
    final parts = fecha.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.event, size: 18, color: Colors.deepPurple[300]),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            _formatFecha(fecha),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
