import '../config/api_config.dart';

/// Modelo de Producto que corresponde a /api/productos.
class Producto {
  final int id;
  final String codigoP;
  final String descripcionP;
  final double precioP;
  final String? imagenP;
  final int stockTotal;
  final CategoriaProducto? categoria;
  final ProductoGenero? genero;
  final List<TallaStock> tallaStocks;
  final DateTime? createdAt;

  Producto({
    required this.id,
    required this.codigoP,
    required this.descripcionP,
    required this.precioP,
    this.imagenP,
    required this.stockTotal,
    this.categoria,
    this.genero,
    required this.tallaStocks,
    this.createdAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      codigoP: json['codigoP'] ?? '',
      descripcionP: json['descripcionP'] ?? '',
      precioP: double.tryParse(json['precioP']?.toString() ?? '0') ?? 0,
      imagenP: json['imagenP'],
      stockTotal: int.tryParse(json['stock_total']?.toString() ?? '0') ?? 0,
      categoria: json['categoria_producto'] != null
          ? CategoriaProducto.fromJson(json['categoria_producto'])
          : null,
      genero: json['producto_genero'] != null
          ? ProductoGenero.fromJson(json['producto_genero'])
          : null,
      tallaStocks: json['talla_stocks'] != null
          ? (json['talla_stocks'] as List)
              .map((t) => TallaStock.fromJson(t))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// URL completa de la imagen del producto.
  String get imagenUrl => ApiConfig.imageUrl(imagenP);

  /// Nombre de la categoría o 'Sin categoría'.
  String get categoriaNombre => categoria?.nombreCP ?? 'Sin categoría';

  /// Descripción del género o 'Sin género'.
  String get generoNombre => genero?.descripcion ?? 'Sin género';

  @override
  String toString() => 'Producto($id: $descripcionP - S/$precioP)';
}

/// Categoría del producto (ej: "Polos & Camisetas").
class CategoriaProducto {
  final int id;
  final String nombreCP;
  final String? descripcionCP;

  CategoriaProducto({
    required this.id,
    required this.nombreCP,
    this.descripcionCP,
  });

  factory CategoriaProducto.fromJson(Map<String, dynamic> json) {
    return CategoriaProducto(
      id: json['id'],
      nombreCP: json['nombreCP'] ?? '',
      descripcionCP: json['descripcionCP'],
    );
  }
}

/// Género del producto (ej: "Unisex", "Masculino", "Femenino").
class ProductoGenero {
  final int id;
  final String descripcion;

  ProductoGenero({
    required this.id,
    required this.descripcion,
  });

  factory ProductoGenero.fromJson(Map<String, dynamic> json) {
    return ProductoGenero(
      id: json['id'],
      descripcion: json['descripcion'] ?? '',
    );
  }
}

/// Stock por talla de un producto (ej: S=8, M=2, L=11, XL=2).
class TallaStock {
  final int id;
  final int stock;
  final Talla? talla;

  TallaStock({
    required this.id,
    required this.stock,
    this.talla,
  });

  factory TallaStock.fromJson(Map<String, dynamic> json) {
    return TallaStock(
      id: json['id'],
      stock: json['stock'] ?? 0,
      talla: json['talla'] != null ? Talla.fromJson(json['talla']) : null,
    );
  }

  /// Nombre de la talla (ej: "S", "M", "L").
  String get tallaNombre => talla?.descripcion ?? '?';
}

/// Talla (ej: S, M, L, XL).
class Talla {
  final int id;
  final String descripcion;

  Talla({required this.id, required this.descripcion});

  factory Talla.fromJson(Map<String, dynamic> json) {
    return Talla(
      id: json['id'],
      descripcion: json['descripcion'] ?? '',
    );
  }
}
