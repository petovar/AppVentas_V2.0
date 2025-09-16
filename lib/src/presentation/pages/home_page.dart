import 'dart:math';
import 'dart:ui';

// import 'package:app_ventas/src/customs/loading.dart';
import 'package:app_ventas/src/presentation/pages/facturas_page.dart';
import 'package:app_ventas/src/presentation/pages/list_facturas_page.dart'
    show ListFacturasPage;
import 'package:app_ventas/src/presentation/pages/productos_page.dart';
import 'package:app_ventas/src/presentation/pages/ventas_sumary_page.dart';
// import 'package:loading_indicator/loading_indicator.dart';

import '../../customs/constants.dart';
// import '../../customs/library.dart';
import 'clientes_page.dart';
// import 'compras_page.dart';
import 'package:flutter/material.dart';

import 'prov_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable de estado para controlar la visibilidad del indicador de carga.
  bool _isLoading = false;

  // // Método para manejar la navegación y el estado de carga.
  // Future<void> _navigateToPage(BuildContext context, Widget page) async {
  //   // 1. Activar el estado de carga para mostrar el indicador.
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   // 2. Esperar a que la navegación a la nueva página se complete.
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => page),
  //   );

  //   // 3. Desactivar el estado de carga una vez que la nueva página está lista.
  //   if (mounted) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _navigateToRoute(BuildContext context, String route) async {
    // 1. Activar el estado de carga para mostrar el indicador.
    setState(() {
      _isLoading = true;
    });

    // 2. Esperar a que la navegación a la nueva página se complete.
    await Navigator.pushNamed(context, route);

    // 3. Desactivar el estado de carga una vez que la nueva página está lista.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String appVersion = '2.0';
    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: Text(Constants.nameEmpresa, style: TextStyle(fontSize: 15.0)),
      ),
      drawer: _getDrawer(context, appVersion),
      body: Stack(
        children: [
          _fondoApp(),
          _crearBotones(context),
          // El indicador de carga, solo visible si _isLoading es verdadero.
          if (_isLoading)
            Container(
              color: Colors.black.withValues(
                alpha: 0.6,
              ), // Fondo semi-transparente
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fondoApp() {
    final caja = Transform.rotate(
      angle: -pi / 5.0,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90.0),
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(73, 80, 87, 0.898),
              Color.fromRGBO(83, 85, 85, 0.498),
            ],
            begin: FractionalOffset(1, 0),
            end: FractionalOffset(1, 1),
          ),
        ),
      ),
    );

    final gradiente = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset(0, 0.1),
          end: FractionalOffset(0, 1),
          colors: [
            Color.fromRGBO(20, 19, 19, 0.2),
            Color.fromRGBO(27, 28, 29, 0.894),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(top: -60, child: caja),
        Positioned(top: 140, left: -270, child: caja),
        Positioned(top: 215, left: 195, child: caja),
        gradiente,
      ],
    );
  }

  Widget _crearBotones(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            _buildRoudedButton(
              context,
              icon: Icons.people,
              label: 'Ventas',
              route: '/ventas',
              color: Colors.white,
              enabledBoton: true,
            ),
            _buildRoudedButton(
              context,
              icon: Icons.category_outlined,
              label: 'Inventario',
              route: '/inventario',
              color: Colors.white,
              enabledBoton: true,
            ),
            _buildRoudedButton(
              context,
              icon: Icons.person_3,
              label: 'Clientes',
              route: '/clientes',
              color: Colors.white,
              enabledBoton: true,
            ),
          ],
        ),
        TableRow(
          children: [
            _buildRoudedButton(
              context,
              icon: Icons.receipt,
              label: 'Resumen de\n    Ventas',
              route: '/ResumenVentas',
              color: Colors.white,
              enabledBoton: true,
            ),
            _buildRoudedButton(
              context,
              icon: Icons.list, //Icons.add_shopping_cart_outlined,
              label: 'Búsqueda de\n     Ventas',
              route: '/ListFacturas',
              color: Colors.white,
              enabledBoton: true,
            ),
            _buildRoudedButton(
              context,
              icon: Icons.person_4,
              label: 'Provedores',
              route: '/proveedores',
              color: Colors.white,
              enabledBoton: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoudedButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
    required bool enabledBoton,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
      child: InkWell(
        onTap: enabledBoton ? () => _navigateToRoute(context, route) : null,
        child: Container(
          height: 110,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 67, 107, enabledBoton ? 0.6 : 0.3),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: 2.0,
              color: const Color.fromARGB(255, 201, 196, 196),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 8.0),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 25.0,
                child: Icon(icon, color: Colors.white, size: 32.0),
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

Drawer _getDrawer(BuildContext context, String version) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Color.fromARGB(255, 73, 70, 70)),
          child: Text(
            Constants.nameEmpresa,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.shopping_cart_checkout),
          title: const Text('Ventas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturaPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.category),
          title: const Text('Inventario'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductosPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.person_3),
          title: const Text('Clientes'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClientesPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.receipt),
          title: const Text('Resumen Ventas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VentasSummaryPage(),
              ),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.add_shopping_cart_outlined),
          title: const Text('Búsqueda de Ventas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListFacturasPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.person_4),
          title: const Text('Proveedores'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProveedoresPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        const Divider(), // Línea divisoria
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Versión: $version',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}
