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

  // Nuevo método para obtener una venta y sus detalles
  Future<Map<String, dynamic>> getFacturaWithDetails(String idVenta) async {
    await initializeDatabase();
    final List<Map<String, dynamic>> masterMaps = await _database.query(
      'master_ventas',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    if (masterMaps.isEmpty) return {};

    final venta = Venta.fromMap(masterMaps.first);
    final List<Map<String, dynamic>> slaveMaps = await _database.query(
      'slave_ventas',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    final detalles = List.generate(slaveMaps.length, (i) {
      return DetalleVenta.fromMap(slaveMaps[i]);
    });

    return {'venta': venta, 'detalles': detalles};
  }

  // Nuevo método para obtener un resumen de ventas
  Future<Map<String, dynamic>> getSalesSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await initializeDatabase();
    if (_database == null) {
      throw Exception(
        "Database not initialized. Call initializeDatabase() first.",
      );
    }

    // Construir la cláusula WHERE para filtrar por fecha
    String whereClause = '';
    List<String> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE T1.fecha BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      whereClause = 'WHERE T1.fecha >= ?';
      whereArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      whereClause = 'WHERE T1.fecha <= ?';
      whereArgs = [endDate.toIso8601String()];
    }

    // Obtener el total de ventas
    final resultTotal = await _database.rawQuery(
      'SELECT SUM(T2.total) as total_ventas FROM master_ventas T1 JOIN slave_ventas T2 ON T1.id_venta = T2.id_venta $whereClause',
      whereArgs,
    );
    final totalVentas = resultTotal.first['total_ventas'] ?? 0.0;

    // Obtener el número de facturas
    final resultCount = await _database.rawQuery(
      'SELECT COUNT(*) as num_facturas FROM master_ventas T1 $whereClause',
      whereArgs,
    );
    final numFacturas = resultCount.first['num_facturas'] ?? 0;

    // Obtener las ventas por condición (contado y crédito)
    final salesByCondition = await _database.rawQuery(
      'SELECT T1.condicion, SUM(T2.total) as total FROM master_ventas T1 JOIN slave_ventas T2 ON T1.id_venta = T2.id_venta $whereClause GROUP BY T1.condicion',
      whereArgs,
    );
    final salesByConditionMap = {'Contado': 0.0, 'Crédito': 0.0};
    for (var row in salesByCondition) {
      salesByConditionMap[row['condicion'] as String] =
          (row['total'] ?? 0.0) as double;
    }

    // Obtener los pagos por método
    final paymentsByMethod = await _database.rawQuery(
      'SELECT T1.metodo_pago, SUM(T1.monto_pago) as total FROM pagos_ventas T1 JOIN master_ventas T2 ON T1.id_venta = T2.id_venta $whereClause GROUP BY T1.metodo_pago',
      whereArgs,
    );
    final paymentsByMethodMap = {
      for (var row in paymentsByMethod)
        row['metodo_pago'] as String: (row['total'] ?? 0.0) as double,
    };

    // Obtener los 10 productos más vendidos
    final resultTopProducts = await _database.rawQuery(
      'SELECT T2.descripcion, SUM(T2.cantidad) as total_cantidad FROM master_ventas T1 JOIN slave_ventas T2 ON T1.id_venta = T2.id_venta $whereClause GROUP BY T2.descripcion ORDER BY total_cantidad DESC LIMIT 10',
      whereArgs,
    );
    final topProducts =
        resultTopProducts
            .map(
              (e) => {
                'descripcion': e['descripcion'],
                'total_cantidad': e['total_cantidad'],
              },
            )
            .toList();

    return {
      'total_ventas': totalVentas,
      'num_facturas': numFacturas,
      'sales_by_condition': salesByConditionMap,
      'payments_by_method': paymentsByMethodMap,
      'top_products': topProducts,
    };
  }
}
