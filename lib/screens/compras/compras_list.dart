import 'package:flutter/material.dart';

import '../../models/compra.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'compra_detail.dart';

/// Pantalla que lista todas las compras desde /api/compras.
class ComprasListScreen extends StatefulWidget {
  const ComprasListScreen({super.key});

  @override
  State<ComprasListScreen> createState() => _ComprasListScreenState();
}

class _ComprasListScreenState extends State<ComprasListScreen> {
  final ApiService _api = ApiService();

  List<Compra> _compras = [];
  List<Compra> _comprasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';
  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _fetchCompras();
  }

  Future<void> _fetchCompras() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/compras');
      setState(() {
        _compras = data.map((json) => Compra.fromJson(json)).toList();
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

  /// Obtiene los estados únicos de las compras.
  List<String> get _estados {
    final estados = _compras
        .map((c) => c.estadoNombre)
        .where((e) => e != 'Sin estado')
        .toSet()
        .toList();
    estados.sort();
    return estados;
  }

  /// Filtra compras por búsqueda y estado.
  void _aplicarFiltros() {
    _comprasFiltradas = _compras.where((c) {
      final coincideBusqueda = _busqueda.isEmpty ||
          c.codigoCompra.toLowerCase().contains(_busqueda.toLowerCase()) ||
          c.proveedorNombre.toLowerCase().contains(_busqueda.toLowerCase());
      final coincideEstado = _estadoSeleccionado == null ||
          c.estadoNombre == _estadoSeleccionado;
      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Compras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCompras,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando compras...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchCompras);
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por código o proveedor...',
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
              '${_comprasFiltradas.length} compra(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista de compras
        Expanded(
          child: _comprasFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron compras.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCompras,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _comprasFiltradas.length,
                    itemBuilder: (context, index) {
                      return _CompraCard(compra: _comprasFiltradas[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de compra en la lista.
class _CompraCard extends StatelessWidget {
  final Compra compra;

  const _CompraCard({required this.compra});

  Color _estadoColor() {
    switch (compra.estadoNombre.toLowerCase()) {
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
              builder: (_) => CompraDetailScreen(compraId: compra.id),
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
                  Icon(Icons.shopping_cart_outlined,
                      size: 20, color: Colors.deepPurple[400]),
                  const SizedBox(width: 8),
                  Text(
                    compra.codigoCompra,
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
                      compra.estadoNombre,
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

              // Proveedor
              Row(
                children: [
                  Icon(Icons.business_outlined,
                      size: 18, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      compra.proveedorNombre,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Comprobante + fecha + total
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      compra.comprobanteNombre,
                      style: const TextStyle(
                        color: Colors.teal,
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
                    compra.fechaFormateada,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Text(
                    'S/ ${compra.total.toStringAsFixed(2)}',
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
