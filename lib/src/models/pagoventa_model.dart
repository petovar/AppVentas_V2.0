// Modelo de datos para la tabla `pagos_ventas`
class PagoVenta {
  final String idVenta;
  final String metodoPago;
  final String nombre;
  final double montoPago;
  final String createdAt;
  final String updatedAt;

  PagoVenta({
    required this.idVenta,
    required this.metodoPago,
    required this.nombre,
    required this.montoPago,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor para crear una instancia a partir de un mapa de la base de datos
  factory PagoVenta.fromMap(Map<String, dynamic> map) {
    return PagoVenta(
      idVenta: map['id_venta'] as String,
      metodoPago: map['metodo_pago'] as String,
      nombre: map['nombre'] as String,
      montoPago: map['monto_pago'] as double,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Método para convertir la instancia a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_venta': idVenta,
      'metodo_pago': metodoPago,
      'nombre': nombre,
      'monto_pago': montoPago,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
