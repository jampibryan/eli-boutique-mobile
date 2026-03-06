import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'cliente_detail.dart';

/// Pantalla que lista todos los clientes desde /api/clientes.
class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  final ApiService _api = ApiService();

  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';
  String? _generoSeleccionado;

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/clientes');
      setState(() {
        _clientes = data.map((json) => Cliente.fromJson(json)).toList();
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

  /// Géneros únicos de los clientes cargados.
  List<String> get _generos {
    final gens = _clientes.map((c) => c.generoNombre).toSet().toList();
    gens.sort();
    return gens;
  }

  /// Filtra clientes por búsqueda y género.
  void _aplicarFiltros() {
    _clientesFiltrados = _clientes.where((c) {
      final query = _busqueda.toLowerCase();
      final coincideBusqueda = _busqueda.isEmpty ||
          c.nombreCompleto.toLowerCase().contains(query) ||
          c.dniCliente.contains(query) ||
          (c.correoCliente?.toLowerCase().contains(query) ?? false) ||
          (c.telefonoCliente?.contains(query) ?? false);
      final coincideGenero =
          _generoSeleccionado == null || c.generoNombre == _generoSeleccionado;
      return coincideBusqueda && coincideGenero;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClientes,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando clientes...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchClientes);
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, DNI, correo o teléfono...',
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

        // Filtro por género con chips
        if (_generos.length > 1)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _generoSeleccionado == null,
                    onSelected: (_) {
                      setState(() {
                        _generoSeleccionado = null;
                        _aplicarFiltros();
                      });
                    },
                  ),
                ),
                ..._generos.map(
                  (gen) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(gen),
                      selected: _generoSeleccionado == gen,
                      onSelected: (_) {
                        setState(() {
                          _generoSeleccionado =
                              _generoSeleccionado == gen ? null : gen;
                          _aplicarFiltros();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Contador de resultados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_clientesFiltrados.length} cliente(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista de clientes
        Expanded(
          child: _clientesFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron clientes.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchClientes,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      return _ClienteCard(
                        cliente: _clientesFiltrados[index],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de cliente en la lista.
class _ClienteCard extends StatelessWidget {
  final Cliente cliente;

  const _ClienteCard({required this.cliente});

  @override
  Widget build(BuildContext context) {
    final esHombre = cliente.generoNombre.toLowerCase() == 'hombre';
    final avatarColor = esHombre ? Colors.blue : Colors.pink;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClienteDetailScreen(clienteId: cliente.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  cliente.iniciales,
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info del cliente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombreCompleto,
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
                        Icon(Icons.badge_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'DNI: ${cliente.dniCliente}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    if (cliente.telefonoCliente != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            cliente.telefonoCliente!,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Badge género
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cliente.generoNombre,
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
