import 'package:flutter/material.dart';

/// Indicador de carga reutilizable con mensaje opcional.
class LoadingIndicator extends StatelessWidget {
  final String mensaje;

  const LoadingIndicator({
    super.key,
    this.mensaje = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
