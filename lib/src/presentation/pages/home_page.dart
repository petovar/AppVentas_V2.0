import 'dart:math';

import 'package:app_ventas/src/presentation/pages/productos_page.dart';

import 'clientes_page.dart';
import 'compras_page.dart';
import 'package:flutter/material.dart';

import '../widgets/round_button.dart';
import 'prov_page.dart';
import 'recibos_tickets.dart';
import 'ventas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mi negocio")),
      drawer: _getDrawer(context),
      body: Stack(children: [_fondoApp(), _crearBotones(context)]),
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
            RoundedButton(
              color: Colors.white,
              icon: Icons.category_outlined,
              texto: 'Inventario',
              route: '/inventario',
              context: context,
              enabledBoton: true,
            ),
            RoundedButton(
              color: Colors.white,
              icon: Icons.shopping_cart_checkout,
              texto: 'Ventas',
              route: '/ventas',
              context: context,
              enabledBoton: true,
            ),
            RoundedButton(
              color: Colors.white,
              icon: Icons.person_3,
              texto: 'Clientes',
              route: '/clientes',
              context: context,
              enabledBoton: true,
            ),
          ],
        ),
        TableRow(
          children: [
            RoundedButton(
              color: Colors.white,
              icon: Icons.receipt,
              texto: 'Recibos/Tickets',
              route: '/recibos',
              context: context,
              enabledBoton: true,
            ),
            RoundedButton(
              color: Colors.white,
              icon: Icons.add_shopping_cart_outlined,
              texto: 'Compras',
              route: '/compras',
              context: context,
              enabledBoton: true,
            ),
            RoundedButton(
              color: Colors.white,
              icon: Icons.person_4,
              texto: 'Provedores',
              route: '/proveedores',
              context: context,
              enabledBoton: true,
            ),
          ],
        ),
      ],
    );
  }
}

Drawer _getDrawer(BuildContext context) {
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
            'Mi negocio',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
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
          leading: Icon(Icons.shopping_cart_checkout),
          title: const Text('Ventas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VentasPage()),
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
          title: const Text('Recibos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecibosPage()),
            ).then((onValue) {
              if (context.mounted) Navigator.of(context).pop();
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.add_shopping_cart_outlined),
          title: const Text('Compras'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComprasPage()),
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
      ],
    ),
  );
}
