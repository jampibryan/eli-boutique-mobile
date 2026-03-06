import 'package:flutter/material.dart';

import '../../models/proveedor.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'proveedor_detail.dart';

/// Pantalla que lista todos los proveedores desde /api/proveedores.
class ProveedoresListScreen extends StatefulWidget {
  const ProveedoresListScreen({super.key});

  @override
  State<ProveedoresListScreen> createState() => _ProveedoresListScreenState();
}

class _ProveedoresListScreenState extends State<ProveedoresListScreen> {
  final ApiService _api = ApiService();

  List<Proveedor> _proveedores = [];
  List<Proveedor> _proveedoresFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _fetchProveedores();
  }

  Future<void> _fetchProveedores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/proveedores');
      setState(() {
        _proveedores =
            data.map((json) => Proveedor.fromJson(json)).toList();
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
    _proveedoresFiltrados = _proveedores.where((p) {
      return _busqueda.isEmpty ||
          p.nombreEmpresa.toLowerCase().contains(_busqueda.toLowerCase()) ||
          p.contactoNombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          p.ruc.contains(_busqueda);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Proveedores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProveedores,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando proveedores...');
    }

    if (_error != null) {
      return ErrorDisplay(
          mensaje: _error!, onReintentar: _fetchProveedores);
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por empresa, contacto o RUC...',
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
              '${_proveedoresFiltrados.length} proveedor(es)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista
        Expanded(
          child: _proveedoresFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron proveedores.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProveedores,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _proveedoresFiltrados.length,
                    itemBuilder: (context, index) {
                      return _ProveedorCard(
                          proveedor: _proveedoresFiltrados[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de proveedor.
class _ProveedorCard extends StatelessWidget {
  final Proveedor proveedor;

  const _ProveedorCard({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProveedorDetailScreen(proveedorId: proveedor.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.teal.withValues(alpha: 0.15),
                child: Text(
                  proveedor.iniciales,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proveedor.nombreEmpresa,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            proveedor.contactoNombre,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.numbers,
                            size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'RUC: ${proveedor.ruc}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
