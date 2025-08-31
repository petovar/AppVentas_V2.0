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

// import 'package:flutter/foundation.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'dart:async';

// import '../models/producto_model.dart' show Producto;

// class ProductoProvider with ChangeNotifier {
//   Database? _database;
//   List<Producto> _productos = [];

//   // Getter para acceder a la lista de productos desde la UI
//   List<Producto> get productos => _productos;

//   // Inicializa la base de datos si no existe
//   Future<void> _openDatabase() async {
//     if (_database != null) {
//       return;
//     }
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'productos_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE productos(id_producto TEXT PRIMARY KEY, descripcion TEXT, unidad TEXT, categoria TEXT, precio REAL, costo REAL, existencia REAL, created_at TEXT, updated_at TEXT)',
//         );
//       },
//       version: 1,
//     );
//   }

//   // Carga todos los productos desde la base de datos
//   Future<void> loadProductos() async {
//     await _openDatabase();
//     final List<Map<String, dynamic>> maps = await _database!.query('productos');

//     _productos = List.generate(maps.length, (i) {
//       return Producto.fromMap(maps[i]);
//     });
//     notifyListeners();
//   }

//   // Añade un nuevo producto a la base de datos
//   Future<void> addProducto(Producto producto) async {
//     await _openDatabase();
//     try {
//       await _database!.insert(
//         'productos',
//         producto.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//       // Re-cargamos la lista para asegurar la consistencia
//       await loadProductos();
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al agregar producto: $e');
//       }
//     }
//   }

//   // Actualiza un producto existente
//   Future<void> updateProducto(Producto producto) async {
//     await _openDatabase();
//     try {
//       await _database!.update(
//         'productos',
//         producto.toMap(),
//         where: 'id_producto = ?',
//         whereArgs: [producto.idProducto],
//       );
//       // Re-cargamos la lista para reflejar los cambios
//       await loadProductos();
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al actualizar producto: $e');
//       }
//     }
//   }

//   // Elimina un producto por su ID
//   Future<void> deleteProducto(String idProducto) async {
//     await _openDatabase();
//     try {
//       await _database!.delete(
//         'productos',
//         where: 'id_producto = ?',
//         whereArgs: [idProducto],
//       );
//       // Re-cargamos la lista para eliminar el producto
//       await loadProductos();
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al eliminar producto: $e');
//       }
//     }
//   }
// }
