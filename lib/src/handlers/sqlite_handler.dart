import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHandler {
  Future<Database> getDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'dbventas1_sqlite.db');

    // Abre o crea la base de datos
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Método para crear las tablas
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        idx TEXT PRIMARY KEY,
        name TEXT,
        alias TEXT,
        telefono TEXT,
        email TEXT,
        direccion TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE proveedores (
        idx TEXT PRIMARY KEY,
        empresa TEXT,
        nombre_proveedor TEXT,
        teleofono1 TEXT,
        teleofono2 TEXT,
        email TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE productos (
        id_producto TEXT,
        descripcion TEXT,
        unidad TEXT,
        categoria TEXT,
        precio REAL,
        costo REAL,
        existencia REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE master_ventas (
        id_venta TEXT PRIMARY KEY,
        id_cliente TEXT,
        nombre TEXT,
        fecha TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE slave_ventas (
        id_venta TEXT,
        id_producto TEXT,
        descripcion TEXT,
        unidad TEXT,
        cantidad REAL,
        precio REAL,
        total REAL,
        orden REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE master_compras (
        id_compra TEXT PRIMARY KEY,
        id_proveedor TEXT,
        empresa TEXT,
        fecha TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE slave_ventas (
        id_compra TEXT,
        id_producto TEXT,
        descripcion TEXT,
        unidad TEXT,
        cantidad REAL,
        precio REAL,
        total REAL,
        orden REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );


    ''');
  }
}
