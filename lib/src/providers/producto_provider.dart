import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        return db.execute(
          "CREATE TABLE productos(id_producto TEXT PRIMARY KEY, descripcion TEXT, unidad TEXT, categoria TEXT, precio REAL, costo REAL, existencia REAL, created_at TEXT, updated_at TEXT)",
        );
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
}
