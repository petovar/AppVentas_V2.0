import 'package:app_ventas/src/presentation/pages/facturas_page.dart';
import 'package:app_ventas/src/presentation/pages/productos_page.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/clientes_page.dart';
import 'presentation/pages/compras_page.dart';
import 'presentation/pages/prov_page.dart';
import 'presentation/pages/recibos_tickets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentation/pages/home_page.dart';
import 'providers/cliente_provider.dart';
import 'providers/factura_provider.dart';
import 'providers/producto_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<void> initialization = Future.wait([
      ClienteProvider().initializeDatabase(),
      ProductoProvider().initializeDatabase(),
      FacturaProvider().initializeDatabase(),
    ]);

    return FutureBuilder(
      future: initialization,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ClienteProvider()..loadClientes(),
              ),
              ChangeNotifierProvider(
                create: (_) => ProductoProvider()..loadProductos(),
              ),
              ChangeNotifierProvider(create: (_) => FacturaProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Solser App',
              initialRoute: '/',
              theme: ThemeData.light().copyWith(
                primaryColor: const Color.fromARGB(255, 8, 8, 8),
                hintColor: Colors.blueAccent,
                appBarTheme: ThemeData.light().appBarTheme.copyWith(
                  backgroundColor: Colors.indigo[800],
                  iconTheme: ThemeData.dark().iconTheme,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  centerTitle: true,
                  titleTextStyle: TextStyle(fontSize: 24, color: Colors.white),
                ),

                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Colors.blue[900],
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey[500],
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Colors.indigo[900],
                  foregroundColor: Colors.white,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              routes: {
                '/': (BuildContext context) => HomePage(),
                '/inventario': (BuildContext context) => ProductosPage(),
                '/ventas': (BuildContext context) => FacturaPage(),
                '/clientes': (BuildContext context) => ClientesPage(),
                '/recibos': (BuildContext context) => RecibosPage(),
                '/compras': (BuildContext context) => ComprasPage(),
                '/proveedores': (BuildContext context) => ProveedoresPage(),
              },
            ),
          );
        } else {
          // Mientras la inicialización está en curso, mostramos una pantalla de carga
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }
}
