import 'package:app_ventas/src/models/venta_model.dart';
import 'package:app_ventas/src/providers/factura_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../customs/constants.dart';

class ListFacturasPage extends StatefulWidget {
  const ListFacturasPage({super.key});

  @override
  State<ListFacturasPage> createState() => _ListFacturasPageState();
}

class _ListFacturasPageState extends State<ListFacturasPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Venta> _allInvoices = [];
  List<Venta> _filteredInvoices = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FacturaProvider>(context, listen: false).loadFacturas();
    });
    // _fetchInvoices();
    _searchController.addListener(() {
      _filterInvoices();
    });
  }

  // Carga las facturas de la base de datos de forma asíncrona.
  Future<void> _fetchInvoices() async {
    final facturaProvider = Provider.of<FacturaProvider>(context);
    try {
      final fetchedInvoices = facturaProvider.facturas;
      setState(() {
        _allInvoices = fetchedInvoices;
        _isLoading = false;
      });
    } catch (e) {
      // Manejar errores si la carga falla.
      if (kDebugMode) {
        print('Error al cargar las facturas: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtra las facturas según el texto de búsqueda.
  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredInvoices = [];
      } else {
        _filteredInvoices =
            _allInvoices.where((factura) {
              final clientName = factura.nombre.toLowerCase();
              // final clientAlias = factura.cliente.alias.toLowerCase();
              return clientName.contains(
                query,
              ); // || clientAlias.contains(query);
            }).toList();
      }
    });
  }

  // Muestra una ventana emergente para simular la visualización o impresión de una factura.
  void _showInvoiceDetails(Venta factura) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Visualizando e imprimiendo factura #${factura.idVenta} para ${factura.nombre}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // Aquí puedes agregar la lógica real para navegar a una nueva pantalla
    // o generar y abrir un PDF para imprimir.
  }

  @override
  Widget build(BuildContext context) {
    _fetchInvoices();
    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(title: const Text('Listado de Ventas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda.
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre de cliente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchController.text.isEmpty
                      ? const Center(
                        child: Text(
                          'Ingrese un nombre de cliente o alias para buscar facturas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = _filteredInvoices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(invoice.nombre),
                              subtitle: Text(
                                'Condición: ${invoice.condicion}\nFecha: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(invoice.fecha))}',
                              ),
                              trailing: const Icon(Icons.print),
                              onTap: () {
                                _showInvoiceDetails(invoice);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
