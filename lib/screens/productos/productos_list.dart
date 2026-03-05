import 'package:flutter/material.dart';

import '../../models/producto.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import 'producto_detail.dart';

/// Pantalla que lista todos los productos desde /api/productos.
class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  final ApiService _api = ApiService();

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _busqueda = '';
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getList('/productos');
      setState(() {
        _productos = data.map((json) => Producto.fromJson(json)).toList();
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

  /// Obtiene las categorías únicas de los productos cargados.
  List<String> get _categorias {
    final cats = _productos
        .map((p) => p.categoriaNombre)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  /// Filtra productos por búsqueda y categoría.
  void _aplicarFiltros() {
    _productosFiltrados = _productos.where((p) {
      final coincideBusqueda = _busqueda.isEmpty ||
          p.descripcionP.toLowerCase().contains(_busqueda.toLowerCase()) ||
          p.codigoP.toLowerCase().contains(_busqueda.toLowerCase());
      final coincideCategoria = _categoriaSeleccionada == null ||
          p.categoriaNombre == _categoriaSeleccionada;
      return coincideBusqueda && coincideCategoria;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProductos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando productos...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchProductos);
    }

    return Column(
      children: [
        // Barra de búsqueda y filtro
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
                _aplicarFiltros();
              });
            },
          ),
        ),

        // Filtro por categoría con chips
        if (_categorias.length > 1)
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
                    selected: _categoriaSeleccionada == null,
                    onSelected: (_) {
                      setState(() {
                        _categoriaSeleccionada = null;
                        _aplicarFiltros();
                      });
                    },
                  ),
                ),
                ..._categorias.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _categoriaSeleccionada == cat,
                        onSelected: (_) {
                          setState(() {
                            _categoriaSeleccionada =
                                _categoriaSeleccionada == cat ? null : cat;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),

        // Contador de resultados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_productosFiltrados.length} producto(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),

        // Lista de productos
        Expanded(
          child: _productosFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron productos.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProductos,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _productosFiltrados.length,
                    itemBuilder: (context, index) {
                      return _ProductoCard(
                        producto: _productosFiltrados[index],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Card individual de producto en la lista.
class _ProductoCard extends StatelessWidget {
  final Producto producto;

  const _ProductoCard({required this.producto});

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
              builder: (_) => ProductoDetailScreen(productoId: producto.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: producto.imagenP != null
                    ? Image.network(
                        producto.imagenUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 14),

              // Info del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.descripcionP,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${producto.codigoP} • ${producto.categoriaNombre}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Tallas disponibles
                        ...producto.tallaStocks.map((ts) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ts.stock > 0
                                    ? Colors.deepPurple.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${ts.tallaNombre}:${ts.stock}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ts.stock > 0
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              // Precio y stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'S/ ${producto.precioP.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: producto.stockTotal > 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stock: ${producto.stockTotal}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: producto.stockTotal > 0
                            ? Colors.green[700]
                            : Colors.red,
                      ),
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

  Widget _placeholderImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
