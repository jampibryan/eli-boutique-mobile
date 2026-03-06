import 'package:flutter/material.dart';

import '../../models/proveedor.dart';
import '../../services/api_service.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';

/// Pantalla de detalle de un proveedor desde /api/proveedores/{id}.
class ProveedorDetailScreen extends StatefulWidget {
  final int proveedorId;

  const ProveedorDetailScreen({super.key, required this.proveedorId});

  @override
  State<ProveedorDetailScreen> createState() => _ProveedorDetailScreenState();
}

class _ProveedorDetailScreenState extends State<ProveedorDetailScreen> {
  final ApiService _api = ApiService();

  Proveedor? _proveedor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProveedor();
  }

  Future<void> _fetchProveedor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data =
          await _api.getData('/proveedores/${widget.proveedorId}');
      setState(() {
        _proveedor = Proveedor.fromJson(data);
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
        title: Text(_proveedor?.nombreEmpresa ?? 'Detalle proveedor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(mensaje: 'Cargando proveedor...');
    }

    if (_error != null) {
      return ErrorDisplay(
          mensaje: _error!, onReintentar: _fetchProveedor);
    }

    final p = _proveedor!;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Avatar grande
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal.withValues(alpha: 0.15),
            child: Text(
              p.iniciales,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 38,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nombre empresa
          Text(
            p.nombreEmpresa,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Badge RUC
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'RUC: ${p.ruc}',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Contacto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persona de contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.person_outlined,
                      label: 'Nombre',
                      value: p.nombreProveedor,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Apellido',
                      value: p.apellidoProveedor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Datos de contacto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Correo electrónico',
                      value: p.correoProveedor ?? 'No registrado',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: p.telefonoProveedor ?? 'No registrado',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Dirección',
                      value: p.direccionProveedor ?? 'No registrado',
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

/// Fila de información con ícono.
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
