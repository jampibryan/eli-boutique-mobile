import 'package:flutter/material.dart';

import '../../models/cliente.dart';

/// Pantalla de detalle de un cliente.
/// Recibe el objeto Cliente directamente (ya cargado desde la lista).
class ClienteDetailScreen extends StatelessWidget {
  final Cliente cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    final esHombre = cliente.generoNombre.toLowerCase() == 'hombre';
    final avatarColor = esHombre ? Colors.blue : Colors.pink;

    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.nombreCompleto),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Avatar grande con iniciales
            CircleAvatar(
              radius: 50,
              backgroundColor: avatarColor.withValues(alpha: 0.15),
              child: Text(
                cliente.iniciales,
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nombre completo
            Text(
              cliente.nombreCompleto,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Badge de género
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: avatarColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    esHombre ? Icons.male : Icons.female,
                    size: 18,
                    color: avatarColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cliente.generoNombre,
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tarjeta con información de contacto
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
                        icon: Icons.badge_outlined,
                        label: 'DNI',
                        value: cliente.dniCliente,
                      ),

                      const Divider(height: 24),

                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Correo electrónico',
                        value: cliente.correoCliente ?? 'No registrado',
                      ),

                      const Divider(height: 24),

                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: cliente.telefonoCliente ?? 'No registrado',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tarjeta con información adicional
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
                        'Datos del registro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _InfoRow(
                        icon: Icons.person_outlined,
                        label: 'Nombre',
                        value: cliente.nombreCliente,
                      ),

                      const Divider(height: 24),

                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Apellido',
                        value: cliente.apellidoCliente,
                      ),

                      const Divider(height: 24),

                      _InfoRow(
                        icon: Icons.wc_outlined,
                        label: 'Género',
                        value: cliente.generoNombre,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Fila de información con ícono, etiqueta y valor.
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
