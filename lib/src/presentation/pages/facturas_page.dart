import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

import '../../customs/libreria.dart';
import '../../models/cliente_model.dart';
import '../../models/detalleventa_model.dart';
import '../../models/pagoventa_model.dart';
import '../../models/producto_model.dart';
import '../../models/venta_model.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/factura_provider.dart';
import '../../providers/producto_provider.dart';

class FacturaPage extends StatefulWidget {
  const FacturaPage({super.key});

  @override
  State<FacturaPage> createState() => _FacturaPageState();
}

class _FacturaPageState extends State<FacturaPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  String? _selectedPaymentMethod;
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _pagoController = TextEditingController();
  List<DetalleVenta> _detalles = [];
  bool _isCredit = false;

  final Map<String, double> _paymentMethods = {
    'Divisa': 0.0,
    'Efectivo': 0.0,
    'Pago movil': 0.0,
    'Transferencia': 0.0,
    'Tarjeta': 0.0,
  };

  @override
  void dispose() {
    _totalController.dispose();
    _pagoController.dispose();
    super.dispose();
  }

  // Método para agregar un producto a la lista
  void _addProduct(Producto producto, double cantidad) {
    if (cantidad <= 0) return;
    setState(() {
      final existingDetail =
          _detalles.where((d) => d.idProducto == producto.idProducto).toList();
      if (existingDetail.isNotEmpty) {
        final index = _detalles.indexOf(existingDetail.first);
        _detalles[index] = existingDetail.first.copyWith(
          cantidad: existingDetail.first.cantidad + cantidad,
          total:
              (existingDetail.first.cantidad + cantidad) *
              existingDetail.first.precio,
        );
      } else {
        final now = DateTime.now().toIso8601String();
        final detalle = DetalleVenta(
          idVenta: '',
          idProducto: producto.idProducto,
          descripcion: producto.descripcion,
          unidad: producto.unidad,
          cantidad: cantidad,
          precio: producto.precio,
          total: cantidad * producto.precio,
          orden: _detalles.length.toDouble(),
          createdAt: now,
          updatedAt: now,
        );
        _detalles.add(detalle);
      }
      _updateTotal();
    });
  }

  // Método para actualizar el total de la factura
  void _updateTotal() {
    double total = _detalles.fold(0.0, (sum, detalle) => sum + detalle.total);
    setState(() {
      _totalController.text = total.toStringAsFixed(2);
      _pagoController.text = total.toStringAsFixed(2);
    });
  }

  // Método para guardar la factura
  void _saveFactura() async {
    if (_formKey.currentState!.validate() && _detalles.isNotEmpty) {
      final facturaProvider = Provider.of<FacturaProvider>(
        context,
        listen: false,
      );
      final clienteProvider = Provider.of<ClienteProvider>(
        context,
        listen: false,
      );
      final productoProvider = Provider.of<ProductoProvider>(
        context,
        listen: false,
      );

      final cliente = clienteProvider.clientes.firstWhere(
        (c) => c.mIdx == _selectedClientId,
      );

      final String idVenta = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      final Venta venta = Venta(
        idVenta: idVenta,
        idCliente: cliente.mIdx,
        nombre: cliente.mName,
        fecha: now,
        condicion: _isCredit ? 'Crédito' : 'Contado',
        createdAt: now,
        updatedAt: now,
      );

      final List<DetalleVenta> detallesFinal =
          _detalles.map((d) => d.copyWith(idVenta: idVenta)).toList();

      PagoVenta? pago;
      if (!_isCredit && _selectedPaymentMethod != null) {
        final montoPago = double.tryParse(_pagoController.text) ?? 0.0;
        pago = PagoVenta(
          idVenta: idVenta,
          metodoPago: _selectedPaymentMethod!,
          nombre: cliente.mName,
          montoPago: montoPago,
          createdAt: now,
          updatedAt: now,
        );
      }

      await facturaProvider.saveFactura(
        venta: venta,
        detalles: detallesFinal,
        pago: pago,
      );

      await productoProvider.updateExistencia(detalles: detallesFinal);

      if (!mounted) return;

      // Generar y mostrar el recibo
      _showReceiptDialog(venta, detallesFinal, pago);

      // Limpiar el formulario
      _formKey.currentState!.reset();
      setState(() {
        _detalles = [];
        _selectedClientId = null;
        _selectedPaymentMethod = null;
        _totalController.text = '0.00';
        _pagoController.text = '0.00';
        _isCredit = false;
      });
    }
  }

  void _showReceiptDialog(
    Venta venta,
    List<DetalleVenta> detalles,
    PagoVenta? pago,
  ) {
    // Generar el contenido del recibo en un formato de texto simple
    final String receiptContent = Libreria.generateReceiptContent(
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
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
                const Divider(),
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

  // String _generateReceiptContent(
  //   Venta venta,
  //   List<DetalleVenta> detalles,
  //   PagoVenta? pago,
  // ) {
  //   final format = NumberFormat.currency(locale: 'es_VE', symbol: '\$');
  //   final now = DateTime.now();

  //   String content = '${Constants.nameEmpresa}\n';
  //   content += '-------------- o ---------------\n';
  //   content += 'Dirección: Altagracia de Oco.\n';
  //   content += 'Fecha: ${DateFormat('dd-MM-yyyy').format(now)}\n';
  //   content += 'Hora: ${DateFormat('hh:mm a').format(now)}\n';
  //   content += '--------------------------------\n';
  //   content += 'TICKET No. ${venta.idVenta.substring(0, 8)}\n';
  //   content += 'Cliente: ${venta.nombre}\n';
  //   content += 'Condición: ${venta.condicion}\n';
  //   content += '--------------------------------\n';
  //   content += '         PRODUCTOS\n';
  //   content += '--------------------------------\n';

  //   double subtotal = 0.0;
  //   for (var detalle in detalles) {
  //     content +=
  //         '${detalle.cantidad.toStringAsFixed(2)} x ${format.format(detalle.precio)} \n';
  //     content +=
  //         '${detalle.descripcion} .... ${format.format(detalle.total)}\n';
  //     subtotal += detalle.total;
  //   }

  //   content += '--------------------------------\n';
  //   content += 'SUBTOTAL: ${format.format(subtotal)}\n';
  //   content +=
  //       'TOTAL:    ${format.format(subtotal)}\n'; // Asumimos 0% de IVA por ahora
  //   content += '--------------------------------\n';
  //   if (pago != null) {
  //     content += 'Método de Pago: ${pago.metodoPago}\n';
  //     content += 'Monto Pagado: ${format.format(pago.montoPago)}\n';
  //   } else {
  //     content += 'Monto a Pagar: ${format.format(subtotal)}\n';
  //   }
  //   content += '--------------------------------\n';
  //   content += '     ¡GRACIAS POR SU COMPRA!\n';
  //   content += '--------------------------------\n';

  //   return content;
  // }

  // Método para editar la cantidad de un producto existente
  void _editProductQuantity(int index) {
    final detalle = _detalles[index];
    _showQuantityDialog(detalle.descripcion, (newQuantity) {
      if (newQuantity > 0) {
        setState(() {
          _detalles[index] = detalle.copyWith(
            cantidad: newQuantity,
            total: newQuantity * detalle.precio,
          );
          _updateTotal();
        });
      }
    }, initialQuantity: detalle.cantidad);
  }

  // Método para eliminar un producto de la lista
  void _removeProduct(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este producto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _detalles.removeAt(index);
                    _updateTotal();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(context);
    final productoProvider = Provider.of<ProductoProvider>(context);
    final allClients = clienteProvider.clientes;
    final allProducts = productoProvider.productos;

    final sortedClients = List<Cliente>.from(allClients);
    sortedClients.sort((a, b) => a.mName.compareTo(b.mName));

    final sortedProducts = List<Producto>.from(allProducts);
    sortedProducts.sort((a, b) => a.descripcion.compareTo(b.descripcion));

    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        // backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de selección de cliente
              _buildSectionTitle('Cliente'),
              _buildClientSelector(sortedClients),
              const SizedBox(height: 8),

              // Sección de detalles de la factura
              _buildSectionTitle('Detalles de la Factura'),
              _buildProductList(sortedProducts),
              Divider(color: Colors.black),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total venta',
                      style: TextStyle(
                        fontSize: 18.8,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 2, 48, 4),
                      ),
                    ),
                    Text(
                      '\$${_totalController.text}',
                      style: TextStyle(
                        fontSize: 18.8,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 2, 48, 4),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.black),
              // Sección de Pago
              SizedBox(height: 10.0),
              _buildSectionTitle('Pago'),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Crédito'),
                      value: _isCredit,
                      onChanged: (bool? value) {
                        setState(() {
                          _isCredit = value!;
                          if (_isCredit) {
                            _selectedPaymentMethod = null;
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Contado'),
                      value: !_isCredit,
                      onChanged: (bool? value) {
                        setState(() {
                          _isCredit = !value!;
                          if (!_isCredit) {
                            _selectedPaymentMethod = 'Efectivo';
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (!_isCredit) _buildPaymentMethodSelector(),
              SizedBox(height: 10.0),
              if (!_isCredit)
                TextFormField(
                  controller: _pagoController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Recibido',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el monto recibido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveFactura,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Factura'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 5, 78, 71),
        ),
      ),
    );
  }

  Widget _buildClientSelector(List<Cliente> clients) {
    return TextFormField(
      readOnly: true,
      onTap: () async {
        final selectedClient = await _showSearchDialog<Cliente>(clients);
        if (selectedClient != null) {
          setState(() {
            _selectedClientId = selectedClient.mIdx;
          });
        }
      },
      controller: TextEditingController(
        text:
            _selectedClientId != null
                ? clients.firstWhere((c) => c.mIdx == _selectedClientId).mName
                : '',
      ),
      decoration: const InputDecoration(
        labelText: 'Seleccionar Cliente',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.search),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Debe seleccionar un cliente';
        }
        return null;
      },
    );
  }

  Widget _buildProductList(List<Producto> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final selectedProduct = await _showSearchDialog<Producto>(products);
            if (selectedProduct != null) {
              _showQuantityDialog(selectedProduct.descripcion, (cantidad) {
                _addProduct(selectedProduct, cantidad);
              });
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar Producto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 14, 98, 167),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _detalles.length,
          itemBuilder: (context, index) {
            final detalle = _detalles[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(detalle.descripcion),
                subtitle: Text(
                  '${detalle.cantidad.toStringAsFixed(2)} (${detalle.unidad}) x \$${detalle.precio.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '\$${detalle.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18.0),
                ),
                onTap: () => _editProductQuantity(index),
                onLongPress: () => _removeProduct(index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'Método de Pago',
        border: OutlineInputBorder(),
      ),
      items:
          _paymentMethods.keys
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPaymentMethod = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Seleccione un método de pago';
        }
        return null;
      },
    );
  }

  Future<T?> _showSearchDialog<T>(List<T> items) {
    final TextEditingController searchController = TextEditingController();
    List<T> filteredItems = items;

    return showDialog<T?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Buscar y Seleccionar'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredItems =
                              items.where((item) {
                                if (item is Cliente) {
                                  return item.mName.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ) ||
                                      item.mAlias.toLowerCase().contains(
                                        value.toLowerCase(),
                                      );
                                } else if (item is Producto) {
                                  return item.descripcion
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.categoria.toLowerCase().contains(
                                        value.toLowerCase(),
                                      );
                                }
                                return false;
                              }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          String title = '';
                          String subtitle = '';
                          if (item is Cliente) {
                            title = item.mName;
                            subtitle = item.mAlias;
                          } else if (item is Producto) {
                            title = item.descripcion;
                            subtitle =
                                '\$${item.precio.toStringAsFixed(2)} | '
                                '${item.unidad} | ${item.existencia.toStringAsFixed(2)} en stock ';
                          }
                          return ListTile(
                            title: Text(title),
                            subtitle: Text(subtitle),
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuantityDialog(
    String descripcion,
    Function(double) onQuantitySelected, {
    double? initialQuantity = 1,
  }) {
    late FocusNode focusNode;
    focusNode = FocusNode();
    final TextEditingController quantityController = TextEditingController(
      text: initialQuantity?.toString(),
    );
    focusNode.requestFocus();
    quantityController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: quantityController.text.length,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingresar Cantidad de $descripcion'),
          content: TextField(
            focusNode: focusNode,
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? quantity = double.tryParse(
                  quantityController.text,
                );
                if (quantity != null) {
                  onQuantitySelected(quantity);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
