import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/detalleventa_model.dart';
import '../models/pagoventa_model.dart';
import '../models/venta_model.dart';

class FacturaProvider extends ChangeNotifier {
  late Database _database;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'ventas_database.db'),
      onCreate: (db, version) {
        // Crear las tablas si no existen
        db.execute(
          "CREATE TABLE master_ventas(id_venta TEXT PRIMARY KEY, id_cliente TEXT, nombre TEXT, fecha TEXT, condicion TEXT, created_at TEXT, updated_at TEXT)",
        );
        db.execute(
          "CREATE TABLE slave_ventas(id_venta TEXT, id_producto TEXT, descripcion TEXT, unidad TEXT, cantidad REAL, precio REAL, total REAL, orden REAL, created_at TEXT, updated_at TEXT)",
        );
        db.execute(
          "CREATE TABLE pagos_ventas(id_venta TEXT, metodo_pago TEXT, nombre TEXT, monto_pago REAL, created_at TEXT, updated_at TEXT)",
        );
      },
      version: 2,
    );
    if (kDebugMode) {
      print("Ya inicilizo la bd de ventas");
    }
  }

  Future<void> saveFactura({
    required Venta venta,
    required List<DetalleVenta> detalles,
    PagoVenta? pago,
  }) async {
    await initializeDatabase();
    await _database.transaction((txn) async {
      // Guardar la venta maestra
      await txn.insert(
        'master_ventas',
        venta.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Guardar los detalles de la venta
      for (var detalle in detalles) {
        await txn.insert(
          'slave_ventas',
          detalle.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Si hay un pago, guardarlo
      if (pago != null) {
        await txn.insert(
          'pagos_ventas',
          pago.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    // Notificar a los listeners que la base de datos ha cambiado
    notifyListeners();
  }

  // Puedes agregar más métodos para consultar, editar y eliminar facturas si lo necesitas.
}
