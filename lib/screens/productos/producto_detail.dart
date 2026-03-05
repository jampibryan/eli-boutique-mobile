import 'package:flutter/material.dart';

import '../../models/producto.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';

/// Pantalla de detalle de un producto desde /api/productos/{id}.
class ProductoDetailScreen extends StatefulWidget {
  final int productoId;

  const ProductoDetailScreen({super.key, required this.productoId});

  @override
  State<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends State<ProductoDetailScreen> {
  final ApiService _api = ApiService();

  Producto? _producto;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducto();
  }

  Future<void> _fetchProducto() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getData('/productos/${widget.productoId}');
      setState(() {
        _producto = Producto.fromJson(data);
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
        title: Text(_producto?.descripcionP ?? 'Detalle producto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando producto...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchProducto);
    }

    final p = _producto!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          SizedBox(
            width: double.infinity,
            height: 280,
            child: p.imagenP != null
                ? Image.network(
                    p.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Código y género
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.codigoP,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.generoNombre,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nombre del producto
                Text(
                  p.descripcionP,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Categoría
                Text(
                  p.categoriaNombre,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),

                // Precio y stock total
                Row(
                  children: [
                    Text(
                      'S/ ${p.precioP.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: p.stockTotal > 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stock total: ${p.stockTotal}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              p.stockTotal > 0 ? Colors.green[700] : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Stock por talla
                const Text(
                  'Stock por talla',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (p.tallaStocks.isEmpty)
                  const Text('Sin información de tallas.')
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: p.tallaStocks.length,
                    itemBuilder: (context, index) {
                      final ts = p.tallaStocks[index];
                      final tieneStock = ts.stock > 0;
                      return Container(
                        decoration: BoxDecoration(
                          color: tieneStock
                              ? Colors.deepPurple.withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tieneStock
                                ? Colors.deepPurple.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ts.tallaNombre,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tieneStock
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ts.stock}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: tieneStock
                                    ? Colors.green[700]
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
      ),
    );
  }
}
