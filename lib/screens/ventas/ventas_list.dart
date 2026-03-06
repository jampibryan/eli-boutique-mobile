import 'package:flutter/material.dart';

import '../../models/venta.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'venta_detail.dart';

/// Pantalla que lista todas las ventas desde /api/ventas.
class VentasListScreen extends StatefulWidget {
  const VentasListScreen({super.key});

  @override
  State<VentasListScreen> createState() => _VentasListScreenState();
}

class _VentasListScreenState extends State<VentasListScreen> {
  final ApiService _api = ApiService();

  List<Venta> _ventas = [];
  List<Venta> _ventasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';
  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _fetchVentas();
  }

  Future<void> _fetchVentas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/ventas');
      setState(() {
        _ventas = data.map((json) => Venta.fromJson(json)).toList();
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

  /// Obtiene los estados únicos de las ventas cargadas.
  List<String> get _estados {
    final estados = _ventas
        .map((v) => v.estadoNombre)
        .where((e) => e != 'Sin estado')
        .toSet()
        .toList();
    estados.sort();
    return estados;
  }

  /// Filtra ventas por búsqueda y estado.
  void _aplicarFiltros() {
    _ventasFiltradas = _ventas.where((v) {
      final coincideBusqueda = _busqueda.isEmpty ||
          v.codigoVenta.toLowerCase().contains(_busqueda.toLowerCase()) ||
          v.clienteNombre.toLowerCase().contains(_busqueda.toLowerCase());
      final coincideEstado = _estadoSeleccionado == null ||
          v.estadoNombre == _estadoSeleccionado;
      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVentas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando ventas...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchVentas);
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por código o cliente...',
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

        // Filtro por estado
        if (_estados.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _estadoSeleccionado == null,
                    onSelected: (_) {
                      setState(() {
                        _estadoSeleccionado = null;
                        _aplicarFiltros();
                      });
                    },
                  ),
                ),
                ..._estados.map((estado) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(estado),
                        selected: _estadoSeleccionado == estado,
                        onSelected: (_) {
                          setState(() {
                            _estadoSeleccionado =
                                _estadoSeleccionado == estado ? null : estado;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),

        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_ventasFiltradas.length} venta(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista de ventas
        Expanded(
          child: _ventasFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron ventas.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchVentas,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _ventasFiltradas.length,
                    itemBuilder: (context, index) {
                      return _VentaCard(venta: _ventasFiltradas[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de venta en la lista.
class _VentaCard extends StatelessWidget {
  final Venta venta;

  const _VentaCard({required this.venta});

  Color _estadoColor() {
    switch (venta.estadoNombre.toLowerCase()) {
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
    final estadoColor = _estadoColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VentaDetailScreen(ventaId: venta.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: código + estado
              Row(
                children: [
                  Icon(Icons.receipt_long,
                      size: 20, color: Colors.deepPurple[400]),
                  const SizedBox(width: 8),
                  Text(
                    venta.codigoVenta,
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
                      color: estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      venta.estadoNombre,
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cliente
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 18, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      venta.clienteNombre,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Fila inferior: comprobante + fecha + monto
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      venta.comprobanteNombre,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    venta.fechaFormateada,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Text(
                    'S/ ${venta.montoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.deepPurple,
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
