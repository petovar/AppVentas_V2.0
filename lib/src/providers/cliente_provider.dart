import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
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
      //print("Ya inicilizo la bd de clientes");
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
