import 'package:flutter/material.dart';

import '../../models/caja.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'caja_detail.dart';

/// Pantalla que lista todas las cajas desde /api/cajas.
class CajasListScreen extends StatefulWidget {
  const CajasListScreen({super.key});

  @override
  State<CajasListScreen> createState() => _CajasListScreenState();
}

class _CajasListScreenState extends State<CajasListScreen> {
  final ApiService _api = ApiService();

  List<Caja> _cajas = [];
  List<Caja> _cajasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _fetchCajas();
  }

  Future<void> _fetchCajas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/cajas');
      setState(() {
        _cajas = data.map((json) => Caja.fromJson(json)).toList();
        _aplicarFiltros();
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

  void _aplicarFiltros() {
    _cajasFiltradas = _cajas.where((c) {
      return _busqueda.isEmpty ||
          c.codigoCaja.contains(_busqueda) ||
          c.fecha.contains(_busqueda) ||
          c.fechaFormateada.contains(_busqueda);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Cajas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCajas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando cajas...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchCajas);
    }

    return Column(
      children: [
        // Búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por código o fecha...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
                _aplicarFiltros();
              });
            },
          ),
        ),

        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_cajasFiltradas.length} caja(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista
        Expanded(
          child: _cajasFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron cajas.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCajas,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _cajasFiltradas.length,
                    itemBuilder: (context, index) {
                      return _CajaCard(caja: _cajasFiltradas[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de caja.
class _CajaCard extends StatelessWidget {
  final Caja caja;

  const _CajaCard({required this.caja});

  @override
  Widget build(BuildContext context) {
    final balance = caja.ingresoDiario - caja.egresoDiario;
    final balancePositivo = balance >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CajaDetailScreen(cajaId: caja.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Código + estado
              Row(
                children: [
                  Icon(Icons.point_of_sale,
                      size: 20, color: Colors.deepPurple[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Caja #${caja.codigoCaja}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: caja.estaAbierta
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      caja.estaAbierta ? 'Abierta' : 'Cerrada',
                      style: TextStyle(
                        color: caja.estaAbierta
                            ? Colors.green
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Fecha y métricas
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    caja.fechaFormateada,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people_outline,
                      size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${caja.clientesHoy}',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag_outlined,
                      size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${caja.productosVendidos}',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Ingreso, egreso, balance
              Row(
                children: [
                  _MiniMonto(
                    label: 'Ingreso',
                    monto: caja.ingresoDiario,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _MiniMonto(
                    label: 'Egreso',
                    monto: caja.egresoDiario,
                    color: Colors.red,
                  ),
                  const Spacer(),
                  Text(
                    'S/ ${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: balancePositivo
                          ? Colors.deepPurple
                          : Colors.red,
                    ),
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

/// Mini etiqueta de monto.
class _MiniMonto extends StatelessWidget {
  final String label;
  final double monto;
  final Color color;

  const _MiniMonto({
    required this.label,
    required this.monto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
        Text(
          'S/ ${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
