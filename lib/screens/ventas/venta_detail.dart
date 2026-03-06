import 'package:flutter/material.dart';

import '../../models/venta.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';

/// Pantalla de detalle de una venta desde /api/ventas/{id}.
class VentaDetailScreen extends StatefulWidget {
  final int ventaId;

  const VentaDetailScreen({super.key, required this.ventaId});

  @override
  State<VentaDetailScreen> createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  final ApiService _api = ApiService();

  Venta? _venta;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchVenta();
  }

  Future<void> _fetchVenta() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getData('/ventas/${widget.ventaId}');
      setState(() {
        _venta = Venta.fromJson(data);
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_venta?.codigoVenta ?? 'Detalle venta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando venta...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchVenta);
    }

    final v = _venta!;
    final estadoColor = _estadoColor(v.estadoNombre);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: código, estado, fecha
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Text(
                  v.codigoVenta,
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
                    v.estadoNombre,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  v.fechaFormateada,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Información del cliente
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
                      'Cliente',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.person_outlined,
                      label: 'Nombre',
                      value: v.clienteNombre,
                    ),
                    if (v.cliente != null) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'DNI',
                        value: v.cliente!.dniCliente,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Detalle de productos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos (${v.detalles.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...v.detalles.map((d) => Card(
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
                                    'P.U.: S/ ${d.precioUnitario.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${d.subtotal.toStringAsFixed(2)}',
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
                    _MontoRow(label: 'Subtotal', monto: v.subTotal),
                    const Divider(height: 16),
                    _MontoRow(label: 'IGV', monto: v.igv),
                    const Divider(height: 16),
                    _MontoRow(
                      label: 'Total',
                      monto: v.montoTotal,
                      destacado: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Información de pago
          if (v.pago != null)
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
                        'Pago',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Comprobante',
                        value: v.comprobanteNombre,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Importe',
                        value: 'S/ ${v.pago!.importe.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.money_off_outlined,
                        label: 'Vuelto',
                        value: 'S/ ${v.pago!.vuelto.toStringAsFixed(2)}',
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

/// Fila de información con ícono, etiqueta y valor.
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

/// Fila de monto (subtotal, IGV, total).
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
