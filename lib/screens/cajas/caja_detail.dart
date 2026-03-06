import 'package:flutter/material.dart';

import '../../models/caja.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';

/// Pantalla de detalle de una caja desde /api/cajas/{id}.
class CajaDetailScreen extends StatefulWidget {
  final int cajaId;

  const CajaDetailScreen({super.key, required this.cajaId});

  @override
  State<CajaDetailScreen> createState() => _CajaDetailScreenState();
}

class _CajaDetailScreenState extends State<CajaDetailScreen> {
  final ApiService _api = ApiService();

  Caja? _caja;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCaja();
  }

  Future<void> _fetchCaja() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getData('/cajas/${widget.cajaId}');
      setState(() {
        _caja = Caja.fromJson(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _caja != null ? 'Caja #${_caja!.codigoCaja}' : 'Detalle caja'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando caja...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchCaja);
    }

    final c = _caja!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .inversePrimary
                  .withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Text(
                  'Caja #${c.codigoCaja}',
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
                    color: c.estaAbierta
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.estaAbierta ? 'Abierta' : 'Cerrada',
                    style: TextStyle(
                      color:
                          c.estaAbierta ? Colors.green : Colors.grey[600],
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

          // Métricas
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _MetricCard(
                  icon: Icons.people,
                  label: 'Clientes',
                  valor: '${c.clientesHoy}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  icon: Icons.shopping_bag,
                  label: 'Productos',
                  valor: '${c.productosVendidos}',
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // Resumen financiero
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
                      'Resumen financiero',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _MontoRow(
                      label: 'Ingreso diario',
                      monto: c.ingresoDiario,
                      color: Colors.green,
                    ),
                    const Divider(height: 16),
                    _MontoRow(
                      label: 'Egreso diario',
                      monto: c.egresoDiario,
                      color: Colors.red,
                    ),
                    const Divider(height: 16),
                    _MontoRow(
                      label: 'Balance',
                      monto: c.balance,
                      color: c.balance >= 0
                          ? Colors.deepPurple
                          : Colors.red,
                      destacado: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Ventas del día
          if (c.ventas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ventas del día (${c.ventas.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...c.ventas.map((v) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Hora
                              Container(
                                width: 50,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    v.horaFormateada,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.codigoVenta,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      v.clienteNombre,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Monto
                              Text(
                                'S/ ${v.montoTotal.toStringAsFixed(2)}',
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

          if (c.ventas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Sin ventas registradas para esta caja.',
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey[500]),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Tarjeta de métrica (clientes, productos).
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de monto con color.
class _MontoRow extends StatelessWidget {
  final String label;
  final double monto;
  final Color color;
  final bool destacado;

  const _MontoRow({
    required this.label,
    required this.monto,
    required this.color,
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
          ),
        ),
        Text(
          'S/ ${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: destacado ? 20 : 15,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
