import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
    final String receiptContent = _generateReceiptContent(
      venta,
      detalles,
      pago,
    );

    // Simular la impresión: en una app real, aquí usarías un paquete de impresora
    // y enviarías la cadena de texto o un formato específico.
    print('---------------- INICIANDO IMPRESIÓN DEL RECIBO ----------------');
    print(receiptContent);
    print('---------------- FIN DE LA IMPRESIÓN ----------------');

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
                const Text(
                  'Contenido del recibo (simulado):',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const Divider(),
                Text(
                  receiptContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
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
    final format = NumberFormat.currency(locale: 'es_VE', symbol: 'Bs ');
    final now = DateTime.now();

    String content = '       - NOMBRE DEL NEGOCIO -\n';
    content += '    Dirección: Calle 123, Ciudad\n';
    content += '    Fecha: ${DateFormat('dd-MM-yyyy').format(now)}\n';
    content += '    Hora: ${DateFormat('hh:mm a').format(now)}\n';
    content += '    ------------------------------\n';
    content += '    FACTURA NRO. ${venta.idVenta.substring(0, 8)}\n';
    content += '    Cliente: ${venta.nombre}\n';
    content += '    Condición: ${venta.condicion}\n';
    content += '    ------------------------------\n';
    content += '    PRODUCTOS\n';
    content += '    ------------------------------\n';

    double subtotal = 0.0;
    for (var detalle in detalles) {
      content +=
          '    ${detalle.descripcion} x${detalle.cantidad.toStringAsFixed(0)}\n';
      content +=
          '    ${format.format(detalle.precio)} = ${format.format(detalle.total)}\n';
      subtotal += detalle.total;
    }

    content += '    ------------------------------\n';
    content += '    SUBTOTAL: ${format.format(subtotal)}\n';
    content +=
        '    TOTAL:    ${format.format(subtotal)}\n'; // Asumimos 0% de IVA por ahora
    content += '    ------------------------------\n';
    if (pago != null) {
      content += '    Método de Pago: ${pago.metodoPago}\n';
      content += '    Monto Pagado: ${format.format(pago.montoPago)}\n';
    } else {
      content += '    Monto a Pagar: ${format.format(subtotal)}\n';
    }
    content += '    ------------------------------\n';
    content += '          ¡GRACIAS POR SU COMPRA!\n';
    content += '    ------------------------------\n';

    return content;
  }

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

    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: const Text('Nueva Factura'),
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
              _buildClientSelector(allClients),
              const SizedBox(height: 8),

              // Sección de detalles de la factura
              _buildSectionTitle('Detalles de la Factura'),
              _buildProductList(allProducts),
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
              // TextFormField(
              //   controller: _totalController,
              //   readOnly: true,
              //   decoration: InputDecoration(
              //     labelText: 'Total',
              //     prefixText: '\$',
              //     border: const OutlineInputBorder(),
              //     filled: true,
              //     fillColor: Colors.grey[200],
              //   ),
              // ),
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
                  'Cantidad: ${detalle.cantidad.toStringAsFixed(2)} | Precio: \$${detalle.precio.toStringAsFixed(2)}',
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
                                '${item.unidad}';
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

  // void _showQuantityDialog(
  //   Producto producto,
  //   Function(double) onQuantitySelected,
  // ) {
  //   final TextEditingController quantityController = TextEditingController(
  //     text: '1',
  //   );
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Ingresar Cantidad de ${producto.descripcion}'),
  //         content: TextField(
  //           controller: quantityController,
  //           keyboardType: TextInputType.number,
  //           decoration: const InputDecoration(
  //             labelText: 'Cantidad',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancelar'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               final double? quantity = double.tryParse(
  //                 quantityController.text,
  //               );
  //               if (quantity != null) {
  //                 onQuantitySelected(quantity);
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //             child: const Text('Agregar'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}


// class _FacturaPageState extends State<FacturaPage> {
//   Cliente? _selectedClient;
//   final List<DetalleVenta> _facturaItems = [];
//   String _condicionPago = 'Contado';
//   String _metodoPago = 'Efectivo';
//   double _totalFactura = 0.0;
//   final _uuid = const Uuid();

//   @override
//   void initState() {
//     super.initState();
//     // Cargar los productos y clientes al iniciar la página
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ClienteProvider>(context, listen: false).loadClientes();
//       Provider.of<ProductoProvider>(context, listen: false).loadProductos();
//     });
//   }

//   // Método para calcular el total de la factura
//   void _calculateTotal() {
//     double total = 0.0;
//     for (var item in _facturaItems) {
//       total += item.total;
//     }
//     setState(() {
//       _totalFactura = total;
//     });
//   }

//   // Diálogo para buscar y seleccionar clientes
//   Future<void> _showClientSearchDialog() async {
//     final clienteProvider = Provider.of<ClienteProvider>(
//       context,
//       listen: false,
//     );
//     final Cliente? result = await showDialog<Cliente>(
//       context: context,
//       builder: (BuildContext context) {
//         return _SearchDialog<Cliente>(
//           title: 'Buscar Cliente',
//           items: clienteProvider.clientes,
//           itemToString: (cliente) => cliente.mName,
//         );
//       },
//     );

//     if (result != null) {
//       setState(() {
//         _selectedClient = result;
//       });
//     }
//   }

//   // Diálogo para buscar y seleccionar productos para agregar a la factura
//   Future<void> _showAddProductDialog() async {
//     final productoProvider = Provider.of<ProductoProvider>(
//       context,
//       listen: false,
//     );
//     final Producto? result = await showDialog<Producto>(
//       context: context,
//       builder: (BuildContext context) {
//         return _SearchDialog<Producto>(
//           title: 'Buscar Producto',
//           items: productoProvider.productos,
//           itemToString: (producto) => producto.descripcion,
//         );
//       },
//     );

//     if (result != null) {
//       _showQuantityDialog(result);
//     }
//   }

//   // Diálogo para ingresar la cantidad de un producto seleccionado
//   void _showQuantityDialog(Producto producto) {
//     final TextEditingController cantidadController = TextEditingController(
//       text: '1',
//     );
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Cantidad de ${producto.descripcion}'),
//           content: TextField(
//             controller: cantidadController,
//             decoration: const InputDecoration(labelText: 'Cantidad'),
//             keyboardType: TextInputType.number,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final cantidad =
//                     double.tryParse(cantidadController.text) ?? 1.0;
//                 final totalItem = cantidad * producto.precio;
//                 setState(() {
//                   _facturaItems.add(
//                     DetalleVenta(
//                       idVenta: '', // Se asignará al guardar
//                       idProducto: producto.idProducto,
//                       descripcion: producto.descripcion,
//                       unidad: producto.unidad,
//                       cantidad: cantidad,
//                       precio: producto.precio,
//                       total: totalItem,
//                       orden: _facturaItems.length.toDouble() + 1,
//                       createdAt: DateTime.now().toIso8601String(),
//                       updatedAt: DateTime.now().toIso8601String(),
//                     ),
//                   );
//                 });
//                 _calculateTotal();
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Agregar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Diálogo para editar la cantidad de un producto
//   void _showEditItemDialog(int index) {
//     final item = _facturaItems[index];
//     final TextEditingController cantidadController = TextEditingController(
//       text: item.cantidad.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Editar Cantidad de ${item.descripcion}'),
//           content: TextField(
//             controller: cantidadController,
//             decoration: const InputDecoration(labelText: 'Nueva Cantidad'),
//             keyboardType: TextInputType.number,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final nuevaCantidad =
//                     double.tryParse(cantidadController.text) ?? item.cantidad;
//                 if (nuevaCantidad > 0) {
//                   final totalItem = nuevaCantidad * item.precio;
//                   setState(() {
//                     _facturaItems[index] = DetalleVenta(
//                       idVenta: item.idVenta,
//                       idProducto: item.idProducto,
//                       descripcion: item.descripcion,
//                       unidad: item.unidad,
//                       cantidad: nuevaCantidad,
//                       precio: item.precio,
//                       total: totalItem,
//                       orden: item.orden,
//                       createdAt: item.createdAt,
//                       updatedAt: DateTime.now().toIso8601String(),
//                     );
//                   });
//                   _calculateTotal();
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Guardar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Diálogo de confirmación para eliminar un producto
//   void _showDeleteItemConfirmation(int index) {
//     final item = _facturaItems[index];
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Eliminar Producto'),
//           content: Text(
//             '¿Estás seguro de que quieres eliminar ${item.descripcion} de la factura?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _facturaItems.removeAt(index);
//                 });
//                 _calculateTotal();
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text(
//                 'Eliminar',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showFacturaReceipt(Venta venta, List<DetalleVenta> detalles) {
//     final total = detalles.fold(0.0, (sum, item) => sum + item.total);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Recibo de Factura', textAlign: TextAlign.center),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Divider(),
//                 Text('Cliente: ${venta.nombre}'),
//                 Text('Fecha: ${venta.fecha.substring(0, 10)}'),
//                 const Divider(),
//                 const Text('Productos:'),
//                 ...detalles.map(
//                   (item) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '${item.cantidad.toStringAsFixed(0)} x ${item.descripcion}',
//                           ),
//                         ),
//                         Text('\$${item.total.toStringAsFixed(2)}'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Total:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '\$${total.toStringAsFixed(2)}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 Text('Condición: ${venta.condicion}'),
//                 if (venta.condicion == 'Contado')
//                   Text('Método de Pago: $_metodoPago'),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cerrar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _printFactura() {
//     // Aquí iría la lógica para enviar la factura a la impresora térmica.
//     // Esto es un ejemplo, la implementación real dependería de la librería y el
//     // hardware de la impresora.
//     // print('Enviando factura a la impresora térmica...');
//     // print('Factura: $_totalFactura, Cliente: ${_selectedClient?.mName}, Items: ${_facturaItems.length}');
//     // ...
//   }

//   // Método para guardar la factura en la base de datos
//   void _saveFactura() {
//     if (_selectedClient == null || _facturaItems.isEmpty) {
//       // Mostrar alerta si no se ha seleccionado cliente o no hay productos
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Por favor, selecciona un cliente y agrega al menos un producto.',
//           ),
//         ),
//       );
//       return;
//     }

//     final String idVenta = _uuid.v4(); // Generar un ID único para la venta
//     final venta = Venta(
//       idVenta: idVenta,
//       idCliente: _selectedClient!.mIdx,
//       nombre: _selectedClient!.mName,
//       fecha: DateTime.now().toIso8601String(),
//       condicion: _condicionPago,
//       createdAt: DateTime.now().toIso8601String(),
//       updatedAt: DateTime.now().toIso8601String(),
//     );

//     PagoVenta? pago;
//     if (_condicionPago == 'Contado') {
//       pago = PagoVenta(
//         idVenta: idVenta,
//         metodoPago: _metodoPago,
//         nombre: _selectedClient!.mName,
//         montoPago: _totalFactura,
//         createdAt: DateTime.now().toIso8601String(),
//         updatedAt: DateTime.now().toIso8601String(),
//       );
//     }

//     // Actualizar los detalles con el ID de la venta
//     final detallesFinal =
//         _facturaItems.map((detalle) {
//           return DetalleVenta(
//             idVenta: idVenta,
//             idProducto: detalle.idProducto,
//             descripcion: detalle.descripcion,
//             unidad: detalle.unidad,
//             cantidad: detalle.cantidad,
//             precio: detalle.precio,
//             total: detalle.total,
//             orden: detalle.orden,
//             createdAt: detalle.createdAt,
//             updatedAt: DateTime.now().toIso8601String(),
//           );
//         }).toList();

//     Provider.of<FacturaProvider>(
//       context,
//       listen: false,
//     ).saveFactura(venta: venta, detalles: detallesFinal, pago: pago).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Factura guardada correctamente.')),
//       );
//       _showFacturaReceipt(venta, detallesFinal);
//       // Limpiar la página para una nueva factura
//       setState(() {
//         _selectedClient = null;
//         _facturaItems.clear();
//         _totalFactura = 0.0;
//         _condicionPago = 'Contado';
//         _metodoPago = 'Efectivo';
//       });
//       _printFactura();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.colorBackgroundScafold,
//       appBar: AppBar(
//         title: const Text('Nueva Factura'),
//         // backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Sección para seleccionar el cliente con búsqueda
//             const Text(
//               'Cliente',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10.0),
//             GestureDetector(
//               onTap: _showClientSearchDialog,
//               child: AbsorbPointer(
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Seleccionar Cliente',
//                     border: OutlineInputBorder(),
//                   ),
//                   child: Text(
//                     _selectedClient?.mName ?? 'Toca para buscar y seleccionar',
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Listado de productos a facturar
//             const Text(
//               'Productos',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10.0),
//             ..._facturaItems.asMap().entries.map((entry) {
//               int idx = entry.key;
//               DetalleVenta item = entry.value;
//               return Card(
//                 child: ListTile(
//                   title: Text(item.descripcion),
//                   subtitle: Text(
//                     'Cantidad: ${item.cantidad} x \$${item.precio.toStringAsFixed(2)}',
//                   ),
//                   trailing: Text('\$${item.total.toStringAsFixed(2)}'),
//                   onTap: () => _showEditItemDialog(idx),
//                   onLongPress: () => _showDeleteItemConfirmation(idx),
//                 ),
//               );
//             }).toList(),

//             const SizedBox(height: 10),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: _showAddProductDialog,
//                 icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
//                 label: const Text(
//                   'Agregar Producto',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Total de la factura
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total:',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '\$${_totalFactura.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Condición de pago
//             const Text(
//               'Condición de Pago',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10.0),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Condición',
//                 border: OutlineInputBorder(),
//               ),
//               value: _condicionPago,
//               items:
//                   ['Contado', 'Crédito'].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _condicionPago = newValue!;
//                 });
//               },
//             ),

//             const SizedBox(height: 20),

//             // Método de pago (solo si es de contado)
//             if (_condicionPago == 'Contado') ...[
//               const Text(
//                 'Método de Pago',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10.0),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Método',
//                   border: OutlineInputBorder(),
//                 ),
//                 value: _metodoPago,
//                 items:
//                     ['Divisas', 'Pago Móvil', 'Efectivo', 'Transferencia'].map((
//                       String value,
//                     ) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _metodoPago = newValue!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//             ],

//             Center(
//               child: ElevatedButton(
//                 onPressed: _saveFactura,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   minimumSize: const Size.fromHeight(50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text(
//                   'Guardar e Imprimir',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget genérico para el diálogo de búsqueda
// class _SearchDialog<T> extends StatefulWidget {
//   final String title;
//   final List<T> items;
//   final String Function(T) itemToString;

//   const _SearchDialog({
//     super.key,
//     required this.title,
//     required this.items,
//     required this.itemToString,
//   });

//   @override
//   _SearchDialogState<T> createState() => _SearchDialogState<T>();
// }

// class _SearchDialogState<T> extends State<_SearchDialog<T>> {
//   final TextEditingController _searchController = TextEditingController();
//   List<T> _filteredItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _filteredItems = widget.items;
//     _searchController.addListener(_filterItems);
//   }

//   void _filterItems() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredItems =
//           widget.items.where((item) {
//             return widget.itemToString(item).toLowerCase().contains(query);
//           }).toList();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterItems);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.title),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 hintText: 'Escribe para buscar...',
//                 prefixIcon: Icon(Icons.search),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Flexible(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredItems.length,
//                 itemBuilder: (context, index) {
//                   final item = _filteredItems[index];
//                   return ListTile(
//                     title: Text(widget.itemToString(item)),
//                     onTap: () {
//                       Navigator.of(context).pop(item);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }