// import 'package:app_ventas/src/providers/factura_provider.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'src/app.dart';
// import 'src/providers/cliente_provider.dart' show ClienteProvider;
// import 'src/providers/producto_provider.dart' show ProductoProvider;

//void main() => runApp(App());
Future<void> main() async {
  // esto requiere para la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // MultiProvider(
    const App(),
    //   providers: [
    //     //
    //     ChangeNotifierProvider(
    //       create: (_) => ClienteProvider()..loadClientes(),
    //     ),
    //     ChangeNotifierProvider(
    //       create: (_) => ProductoProvider()..loadProductos(),
    //     ),
    //     ChangeNotifierProvider(create: (_) => FacturaProvider()),
    //     //
    //   ],
    //   child: const App(),
    // ),
  );
}
