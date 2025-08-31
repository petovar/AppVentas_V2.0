import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cliente_model.dart' show Cliente;

class ClienteProvider extends ChangeNotifier {
  late Database _database;
  List<Cliente> _clientes = [];

  List<Cliente> get clientes => _clientes;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'clientes_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE clientes(mIdx TEXT PRIMARY KEY, mName TEXT, mAlias TEXT, mTelefono TEXT, mEmail TEXT, mDireccion TEXT, mCreatedAt TEXT, mUpdatedAt TEXT)",
        );
      },
      version: 2,
    );
    if (kDebugMode) {
      print("Ya inicilizo la bd de clientes");
    }
  }

  Future<void> loadClientes() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('clientes');
    _clientes = List.generate(maps.length, (i) {
      return Cliente.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addCliente(Cliente cliente) async {
    await _database.insert(
      'clientes',
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadClientes();
  }

  Future<void> updateCliente(Cliente cliente) async {
    await _database.update(
      'clientes',
      cliente.toMap(),
      where: 'mIdx = ?',
      whereArgs: [cliente.mIdx],
    );
    await loadClientes();
  }

  Future<void> deleteCliente(String id) async {
    await _database.delete('clientes', where: 'mIdx = ?', whereArgs: [id]);
    await loadClientes();
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import '../models/cliente_model.dart';
// // import 'cliente.dart';
// import 'dart:async';

// class ClienteProvider with ChangeNotifier {
//   Database? _database;
//   List<Cliente> _clientes = [];

//   // Getter para acceder a la lista de clientes desde la UI
//   List<Cliente> get clientes => _clientes;

//   // Inicializa la base de datos si no existe
//   Future<void> _openDatabase() async {
//     if (_database != null) {
//       return;
//     }
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'clientes_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE clientes(mIdx INTEGER PRIMARY KEY AUTOINCREMENT, mName TEXT, mAlias TEXT, mTelefono TEXT, mEmail TEXT, mDireccion TEXT, mCreatedAt TEXT, mUpdatedAt TEXT)',
//         );
//       },
//       version: 1,
//     );
//   }

//   // Carga todos los clientes desde la base de datos
//   Future<void> loadClientes() async {
//     await _openDatabase();
//     final List<Map<String, dynamic>> maps = await _database!.query('clientes');

//     _clientes = List.generate(maps.length, (i) {
//       return Cliente.fromMap(maps[i]);
//     });
//     notifyListeners();
//   }

//   // Añade un nuevo cliente a la base de datos
//   Future<void> addCliente(Cliente cliente) async {
//     await _openDatabase();
//     try {
//       final id = await _database!.insert(
//         'clientes',
//         cliente.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//       // Re-cargamos la lista para asegurar la consistencia
//       await loadClientes();
//       notifyListeners();
//     } catch (e) {
//       print('Error al agregar cliente: $e');
//     }
//   }

//   // Actualiza un cliente existente
//   Future<void> updateCliente(Cliente cliente) async {
//     await _openDatabase();
//     try {
//       await _database!.update(
//         'clientes',
//         cliente.toMap(),
//         where: 'mIdx = ?',
//         whereArgs: [cliente.mIdx],
//       );
//       // Re-cargamos la lista para reflejar los cambios
//       await loadClientes();
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al actualizar cliente: $e');
//       }
//     }
//   }

//   // Elimina un cliente por su ID
//   Future<void> deleteCliente(int mIdx) async {
//     await _openDatabase();
//     try {
//       await _database!.delete('clientes', where: 'mIdx = ?', whereArgs: [mIdx]);
//       // Re-cargamos la lista para eliminar el cliente
//       await loadClientes();
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al eliminar cliente: $e');
//       }
//     }
//   }
// }

// // import 'package:app_ventas/src/providers/clientes_in_memory.dart';
// // import 'package:flutter/material.dart';
// // import '../models/cliente_model.dart';

// // class ClienteProvider extends ChangeNotifier {
// //   // Cliente
// //   // Cliente _mCliente = Cliente();
// //   // Cliente get mCliente => _mCliente;
// //   // set mCliente(Cliente mCliente) {
// //   //   _mCliente = mCliente;
// //   //   notifyListeners();

// //   // }
// //   List<Cliente> _clientes = [];

// //   void addItem(Cliente itemData) {
// //     _clientes.add(itemData);
// //     notifyListeners();
// //   }

// //   List<Cliente> get allClientes {

// //     return _clientes;
// //   }
// // }
