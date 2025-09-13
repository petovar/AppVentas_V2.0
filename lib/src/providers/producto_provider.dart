import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/detalleventa_model.dart' show DetalleVenta;
import '../models/producto_model.dart' show Producto;

class ProductoProvider extends ChangeNotifier {
  //late Database _database;
  Database? _database;
  List<Producto> _productos = [];

  List<Producto> get productos => _productos;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'productos_database.db'),
      onCreate: (db, version) {
        return db.execute('''
            CREATE TABLE productos(
            id_producto TEXT PRIMARY KEY, 
            descripcion TEXT, 
            unidad TEXT, 
            categoria TEXT, 
            precio REAL, 
            costo REAL, 
            existencia REAL, 
            created_at TEXT, 
            updated_at TEXT)''');
      },
      version: 2,
    );
  }

  Future<void> loadProductos() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database!.query('productos');
    _productos = List.generate(maps.length, (i) {
      return Producto.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addProducto(Producto producto) async {
    await _database?.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadProductos();
  }

  Future<void> updateProducto(Producto producto) async {
    await _database!.update(
      'productos',
      producto.toMap(),
      where: 'id_producto = ?',
      whereArgs: [producto.idProducto],
    );
    await loadProductos();
  }

  Future<void> deleteProducto(String id) async {
    await _database!.delete(
      'productos',
      where: 'id_producto = ?',
      whereArgs: [id],
    );
    await loadProductos();
  }

  // Nuevo método para obtener la existencia de todos los productos
  Future<List<Map<String, dynamic>>> getProductStock() async {
    await initializeDatabase();
    return _database!.query('productos', orderBy: 'descripcion');
  }

  // 4. Actualizar la existencia de productos en la base de datos de productos
  Future<void> updateExistencia({required List<DetalleVenta> detalles}) async {
    await _database!.transaction((txn) async {
      for (var detalle in detalles) {
        // Consultar la existencia actual
        final currentProduct = await txn.query(
          'productos',
          where: 'id_producto = ?',
          whereArgs: [detalle.idProducto],
        );

        if (currentProduct.isNotEmpty) {
          final currentExistence = currentProduct.first['existencia'] as double;
          final newExistence = currentExistence - detalle.cantidad;

          // Actualizar la existencia del producto
          await txn.update(
            'productos',
            {'existencia': newExistence},
            where: 'id_producto = ?',
            whereArgs: [detalle.idProducto],
          );
        }
      }
    });
  }
}
