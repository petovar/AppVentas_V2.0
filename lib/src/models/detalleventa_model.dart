// Modelo de datos para la tabla `slave_ventas`
class DetalleVenta {
  final String idVenta;
  final String idProducto;
  final String descripcion;
  final String unidad;
  final double cantidad;
  final double precio;
  final double total;
  final double orden;
  final String createdAt;
  final String updatedAt;

  DetalleVenta({
    required this.idVenta,
    required this.idProducto,
    required this.descripcion,
    required this.unidad,
    required this.cantidad,
    required this.precio,
    required this.total,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor para crear una instancia a partir de un mapa de la base de datos
  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      idVenta: map['id_venta'] as String,
      idProducto: map['id_producto'] as String,
      descripcion: map['descripcion'] as String,
      unidad: map['unidad'] as String,
      cantidad: map['cantidad'] as double,
      precio: map['precio'] as double,
      total: map['total'] as double,
      orden: map['orden'] as double,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Método para convertir la instancia a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_venta': idVenta,
      'id_producto': idProducto,
      'descripcion': descripcion,
      'unidad': unidad,
      'cantidad': cantidad,
      'precio': precio,
      'total': total,
      'orden': orden,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
