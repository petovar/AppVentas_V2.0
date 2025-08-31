import 'package:intl/intl.dart';

class Producto {
  final String idProducto;
  final String descripcion;
  final String unidad;
  final String categoria;
  final double precio;
  final double costo;
  final double existencia;
  final String createdAt;
  final String updatedAt;

  Producto({
    required this.idProducto,
    required this.descripcion,
    required this.unidad,
    required this.categoria,
    required this.precio,
    required this.costo,
    required this.existencia,
    String? createdAt,
    String? updatedAt,
  }) : createdAt =
           createdAt ??
           DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
       updatedAt =
           updatedAt ??
           DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  // Convierte un Map (fila de la base de datos) en un objeto Producto
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      idProducto: map['id_producto'] as String,
      descripcion: map['descripcion'] as String,
      unidad: map['unidad'] as String,
      categoria: map['categoria'] as String,
      precio: map['precio'] as double,
      costo: map['costo'] as double,
      existencia: map['existencia'] as double,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Convierte un objeto Producto en un Map para insertarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_producto': idProducto,
      'descripcion': descripcion,
      'unidad': unidad,
      'categoria': categoria,
      'precio': precio,
      'costo': costo,
      'existencia': existencia,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Crea una copia del objeto, útil para actualizaciones
  Producto copyWith({
    String? idProducto,
    String? descripcion,
    String? unidad,
    String? categoria,
    double? precio,
    double? costo,
    double? existencia,
    String? createdAt,
    String? updatedAt,
  }) {
    return Producto(
      idProducto: idProducto ?? this.idProducto,
      descripcion: descripcion ?? this.descripcion,
      unidad: unidad ?? this.unidad,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
      existencia: existencia ?? this.existencia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
