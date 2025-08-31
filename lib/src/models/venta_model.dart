// Modelo de datos para la tabla `master_ventas`
class Venta {
  final String idVenta;
  final String idCliente;
  final String nombre;
  final String fecha;
  final String condicion;
  final String createdAt;
  final String updatedAt;

  Venta({
    required this.idVenta,
    required this.idCliente,
    required this.nombre,
    required this.fecha,
    required this.condicion,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor para crear una instancia a partir de un mapa de la base de datos
  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      idVenta: map['id_venta'] as String,
      idCliente: map['id_cliente'] as String,
      nombre: map['nombre'] as String,
      fecha: map['fecha'] as String,
      condicion: map['condicion'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Método para convertir la instancia a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_venta': idVenta,
      'id_cliente': idCliente,
      'nombre': nombre,
      'fecha': fecha,
      'condicion': condicion,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// // Modelo de datos para la tabla `master_ventas`
// class Venta {
//   final String idVenta;
//   final int? idCliente;
//   final String nombre;
//   final String fecha;
//   final String condicion;
//   final String createdAt;
//   final String updatedAt;

//   Venta({
//     required this.idVenta,
//     required this.idCliente,
//     required this.nombre,
//     required this.fecha,
//     required this.condicion,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   // Constructor para crear una instancia a partir de un mapa de la base de datos
//   factory Venta.fromMap(Map<String, dynamic> map) {
//     return Venta(
//       idVenta: map['id_venta'] as String,
//       idCliente: map['id_cliente'] as int,
//       nombre: map['nombre'] as String,
//       fecha: map['fecha'] as String,
//       condicion: map['condicion'] as String,
//       createdAt: map['created_at'] as String,
//       updatedAt: map['updated_at'] as String,
//     );
//   }

//   // Método para convertir la instancia a un mapa para la base de datos
//   Map<String, dynamic> toMap() {
//     return {
//       'id_venta': idVenta,
//       'id_cliente': idCliente,
//       'nombre': nombre,
//       'fecha': fecha,
//       'condicion': condicion,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }
