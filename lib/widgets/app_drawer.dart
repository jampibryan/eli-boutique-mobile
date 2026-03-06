import 'package:flutter/material.dart';

import '../screens/cajas/cajas_list.dart';
import '../screens/clientes/clientes_list.dart';
import '../screens/compras/compras_list.dart';
import '../screens/dashboard_screen.dart';
import '../screens/productos/productos_list.dart';
import '../screens/proveedores/proveedores_list.dart';
import '../screens/ventas/ventas_list.dart';

/// Drawer de navegación compartido entre todas las pantallas principales.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.store, size: 40, color: Colors.deepPurple),
                SizedBox(height: 10),
                Text(
                  'Eli Boutique',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'Sistema de consulta',
                  style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                ),
              ],
            ),
          ),

          // Dashboard
          _DrawerTile(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => _navigateTo(context, const DashboardScreen()),
          ),

          const Divider(),
          _SectionLabel('Catálogo'),

          _DrawerTile(
            icon: Icons.inventory_2_outlined,
            label: 'Productos',
            onTap: () => _navigateTo(context, const ProductosListScreen()),
          ),
          _DrawerTile(
            icon: Icons.people_outlined,
            label: 'Clientes',
            onTap: () => _navigateTo(context, const ClientesListScreen()),
          ),

          const Divider(),
          _SectionLabel('Transacciones'),

          _DrawerTile(
            icon: Icons.point_of_sale_outlined,
            label: 'Ventas',
            onTap: () => _navigateTo(context, const VentasListScreen()),
          ),
          _DrawerTile(
            icon: Icons.shopping_cart_outlined,
            label: 'Compras',
            onTap: () => _navigateTo(context, const ComprasListScreen()),
          ),

          const Divider(),
          _SectionLabel('Gestión'),

          _DrawerTile(
            icon: Icons.local_shipping_outlined,
            label: 'Proveedores',
            onTap: () =>
                _navigateTo(context, const ProveedoresListScreen()),
          ),
          _DrawerTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Cajas',
            onTap: () => _navigateTo(context, const CajasListScreen()),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: onTap,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
