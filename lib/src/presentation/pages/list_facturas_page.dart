import 'package:app_ventas/src/models/venta_model.dart';
import 'package:app_ventas/src/providers/factura_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../customs/constants.dart';
import '../../models/detalleventa_model.dart';
import '../../models/pagoventa_model.dart';

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
  void _showInvoiceDetails(
    Venta factura,
    FacturaProvider facturaProvider,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Visualizando e imprimiendo factura #${factura.idVenta} para ${factura.nombre}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // Generar y mostrar el recibo
    try {
      final Map<String, dynamic> ventaDetalle = await facturaProvider
          .getFacturaWithDetails(factura.idVenta);

      final Venta venta = ventaDetalle['venta'];
      final List<DetalleVenta> detallesFinal = ventaDetalle['detalles'];

      final PagoVenta? pago = ventaDetalle['pago'];

      _showReceiptDialog(venta, detallesFinal, pago);
    } catch (e) {
      if (kDebugMode) {
        print("Error al cargar facturas con detalles: ${e}");
      }
    }

    // Aquí puedes agregar la lógica real para navegar a una nueva pantalla
    // o generar y abrir un PDF para imprimir.
  }

  void _showReceiptDialog(
    Venta venta,
    List<DetalleVenta> detalles,
    PagoVenta? pago,
  ) {
    // Generar el contenido del recibo en un formato de texto simple
    final String receiptContent = _generateReceiptContent(
      venta,
      detalles,
      pago,
    );

    // Simular la impresión: en una app real, aquí usarías un paquete de impresora
    // y enviarías la cadena de texto o un formato específico.
    if (kDebugMode) {
      print('---------------- INICIANDO IMPRESIÓN DEL RECIBO ----------------');
      print(receiptContent);
      print('---------------- FIN DE LA IMPRESIÓN ----------------');
    }

    // Mostrar un diálogo con el recibo
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Factura y Recibo'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Factura guardada con éxito.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // const Text('Contenido del recibo (simulado):',style: TextStyle(fontStyle: FontStyle.italic),),
                const Divider(),
                Text(
                  receiptContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: receiptContent));
              },
              icon: Icon(Icons.share),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }

  String _generateReceiptContent(
    Venta venta,
    List<DetalleVenta> detalles,
    PagoVenta? pago,
  ) {
    final format = NumberFormat.currency(locale: 'es_VE', symbol: '\$');
    final now = DateTime.now();

    String content = '${Constants.nameEmpresa}\n';
    content += '-------------- o ---------------\n';
    content += 'Dirección: Altagracia de Oco.\n';
    content +=
        'Fecha: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(venta.fecha))}\n';
    content +=
        'Hora: ${DateFormat('hh:mm a').format(DateTime.parse(venta.fecha))}\n';
    content += '------------------------------\n';
    content += 'TICKET No. ${venta.idVenta.substring(0, 8)}\n';
    content += 'Cliente: ${venta.nombre}\n';
    content += 'Condición: ${venta.condicion}\n';
    content += '------------------------------\n';
    content += '         PRODUCTOS\n';
    content += '------------------------------\n';

    double subtotal = 0.0;
    for (var detalle in detalles) {
      content +=
          '${detalle.cantidad.toStringAsFixed(0)} x ${format.format(detalle.precio)} \n';
      content +=
          '${detalle.descripcion} .... ${format.format(detalle.total)}\n';
      subtotal += detalle.total;
    }

    content += '------------------------------\n';
    content += 'SUBTOTAL: ${format.format(subtotal)}\n';
    content +=
        'TOTAL:    ${format.format(subtotal)}\n'; // Asumimos 0% de IVA por ahora
    content += '------------------------------\n';
    if (pago != null) {
      content += 'Método de Pago: ${pago.metodoPago}\n';
      content += 'Monto Pagado: ${format.format(pago.montoPago)}\n';
    } else {
      content += 'Monto a Pagar: ${format.format(subtotal)}\n';
    }
    content += '------------------------------\n';
    content += '     ¡GRACIAS POR SU COMPRA!\n';
    content += '------------------------------\n';

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final facturaProvider = Provider.of<FacturaProvider>(context);
    _fetchInvoices();
    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(title: const Text('Búsqueda de Ventas')),
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
                                _showInvoiceDetails(invoice, facturaProvider);
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
