import 'package:flutter/material.dart';

import '../models/dashboard.dart';
import '../services/api_service.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/stat_card.dart';

/// Pantalla principal del Dashboard.
/// Muestra estadísticas generales del negocio desde /api/dashboard.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();

  Dashboard? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getData('/dashboard');
      setState(() {
        _dashboard = Dashboard.fromJson(data);
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
        title: const Text('Eli Boutique'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboard,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando dashboard...');
    }

    if (_error != null) {
      return ErrorDisplay(mensaje: _error!, onReintentar: _fetchDashboard);
    }

    final d = _dashboard!;

    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha y estado de caja
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple[400],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      d.fecha,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: d.cajaAbierta
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            d.cajaAbierta
                                ? Icons.lock_open
                                : Icons.lock_outline,
                            size: 16,
                            color: d.cajaAbierta ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            d.cajaAbierta ? 'Caja abierta' : 'Caja cerrada',
                            style: TextStyle(
                              color:
                                  d.cajaAbierta ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Título de sección
            Text(
              'Resumen del día',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Grid de estadísticas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                StatCard(
                  titulo: 'Ventas hoy',
                  valor: d.ventasHoy.toString(),
                  icono: Icons.point_of_sale,
                  color: Colors.green,
                ),
                StatCard(
                  titulo: 'Clientes',
                  valor: d.totalClientes.toString(),
                  icono: Icons.people,
                  color: Colors.blue,
                ),
                StatCard(
                  titulo: 'Productos',
                  valor: d.totalProductos.toString(),
                  icono: Icons.inventory_2,
                  color: Colors.orange,
                ),
                StatCard(
                  titulo: 'Proveedores',
                  valor: d.totalProveedores.toString(),
                  icono: Icons.local_shipping,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
