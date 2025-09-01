import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/material.dart';
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
  Cliente? _selectedClient;
  final List<DetalleVenta> _facturaItems = [];
  String _condicionPago = 'Contado';
  String _metodoPago = 'Efectivo';
  double _totalFactura = 0.0;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Cargar los productos y clientes al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClienteProvider>(context, listen: false).loadClientes();
      Provider.of<ProductoProvider>(context, listen: false).loadProductos();
    });
  }

  // Método para calcular el total de la factura
  void _calculateTotal() {
    double total = 0.0;
    for (var item in _facturaItems) {
      total += item.total;
    }
    setState(() {
      _totalFactura = total;
    });
  }

  // Diálogo para buscar y seleccionar clientes
  Future<void> _showClientSearchDialog() async {
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    final Cliente? result = await showDialog<Cliente>(
      context: context,
      builder: (BuildContext context) {
        return _SearchDialog<Cliente>(
          title: 'Buscar Cliente',
          items: clienteProvider.clientes,
          itemToString: (cliente) => cliente.mName,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedClient = result;
      });
    }
  }

  // Diálogo para buscar y seleccionar productos para agregar a la factura
  Future<void> _showAddProductDialog() async {
    final productoProvider = Provider.of<ProductoProvider>(
      context,
      listen: false,
    );
    final Producto? result = await showDialog<Producto>(
      context: context,
      builder: (BuildContext context) {
        return _SearchDialog<Producto>(
          title: 'Buscar Producto',
          items: productoProvider.productos,
          itemToString: (producto) => producto.descripcion,
        );
      },
    );

    if (result != null) {
      _showQuantityDialog(result);
    }
  }

  // Diálogo para ingresar la cantidad de un producto seleccionado
  void _showQuantityDialog(Producto producto) {
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cantidad de ${producto.descripcion}'),
          content: TextField(
            controller: cantidadController,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final cantidad =
                    double.tryParse(cantidadController.text) ?? 1.0;
                final totalItem = cantidad * producto.precio;
                setState(() {
                  _facturaItems.add(
                    DetalleVenta(
                      idVenta: '', // Se asignará al guardar
                      idProducto: producto.idProducto,
                      descripcion: producto.descripcion,
                      unidad: producto.unidad,
                      cantidad: cantidad,
                      precio: producto.precio,
                      total: totalItem,
                      orden: _facturaItems.length.toDouble() + 1,
                      createdAt: DateTime.now().toIso8601String(),
                      updatedAt: DateTime.now().toIso8601String(),
                    ),
                  );
                });
                _calculateTotal();
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar la cantidad de un producto
  void _showEditItemDialog(int index) {
    final item = _facturaItems[index];
    final TextEditingController cantidadController = TextEditingController(
      text: item.cantidad.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Cantidad de ${item.descripcion}'),
          content: TextField(
            controller: cantidadController,
            decoration: const InputDecoration(labelText: 'Nueva Cantidad'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaCantidad =
                    double.tryParse(cantidadController.text) ?? item.cantidad;
                if (nuevaCantidad > 0) {
                  final totalItem = nuevaCantidad * item.precio;
                  setState(() {
                    _facturaItems[index] = DetalleVenta(
                      idVenta: item.idVenta,
                      idProducto: item.idProducto,
                      descripcion: item.descripcion,
                      unidad: item.unidad,
                      cantidad: nuevaCantidad,
                      precio: item.precio,
                      total: totalItem,
                      orden: item.orden,
                      createdAt: item.createdAt,
                      updatedAt: DateTime.now().toIso8601String(),
                    );
                  });
                  _calculateTotal();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de confirmación para eliminar un producto
  void _showDeleteItemConfirmation(int index) {
    final item = _facturaItems[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: Text(
            '¿Estás seguro de que quieres eliminar ${item.descripcion} de la factura?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _facturaItems.removeAt(index);
                });
                _calculateTotal();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFacturaReceipt(Venta venta, List<DetalleVenta> detalles) {
    final total = detalles.fold(0.0, (sum, item) => sum + item.total);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recibo de Factura', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                Text('Cliente: ${venta.nombre}'),
                Text('Fecha: ${venta.fecha.substring(0, 10)}'),
                const Divider(),
                const Text('Productos:'),
                ...detalles.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.cantidad.toStringAsFixed(0)} x ${item.descripcion}',
                          ),
                        ),
                        Text('\$${item.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                Text('Condición: ${venta.condicion}'),
                if (venta.condicion == 'Contado')
                  Text('Método de Pago: $_metodoPago'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _printFactura() {
    // Aquí iría la lógica para enviar la factura a la impresora térmica.
    // Esto es un ejemplo, la implementación real dependería de la librería y el
    // hardware de la impresora.
    // print('Enviando factura a la impresora térmica...');
    // print('Factura: $_totalFactura, Cliente: ${_selectedClient?.mName}, Items: ${_facturaItems.length}');
    // ...
  }

  // Método para guardar la factura en la base de datos
  void _saveFactura() {
    if (_selectedClient == null || _facturaItems.isEmpty) {
      // Mostrar alerta si no se ha seleccionado cliente o no hay productos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona un cliente y agrega al menos un producto.',
          ),
        ),
      );
      return;
    }

    final String idVenta = _uuid.v4(); // Generar un ID único para la venta
    final venta = Venta(
      idVenta: idVenta,
      idCliente: _selectedClient!.mIdx,
      nombre: _selectedClient!.mName,
      fecha: DateTime.now().toIso8601String(),
      condicion: _condicionPago,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    PagoVenta? pago;
    if (_condicionPago == 'Contado') {
      pago = PagoVenta(
        idVenta: idVenta,
        metodoPago: _metodoPago,
        nombre: _selectedClient!.mName,
        montoPago: _totalFactura,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }

    // Actualizar los detalles con el ID de la venta
    final detallesFinal =
        _facturaItems.map((detalle) {
          return DetalleVenta(
            idVenta: idVenta,
            idProducto: detalle.idProducto,
            descripcion: detalle.descripcion,
            unidad: detalle.unidad,
            cantidad: detalle.cantidad,
            precio: detalle.precio,
            total: detalle.total,
            orden: detalle.orden,
            createdAt: detalle.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }).toList();

    Provider.of<FacturaProvider>(
      context,
      listen: false,
    ).saveFactura(venta: venta, detalles: detallesFinal, pago: pago).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura guardada correctamente.')),
      );
      _showFacturaReceipt(venta, detallesFinal);
      // Limpiar la página para una nueva factura
      setState(() {
        _selectedClient = null;
        _facturaItems.clear();
        _totalFactura = 0.0;
        _condicionPago = 'Contado';
        _metodoPago = 'Efectivo';
      });
      _printFactura();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: const Text('Nueva Factura'),
        // backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección para seleccionar el cliente con búsqueda
            const Text(
              'Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: _showClientSearchDialog,
              child: AbsorbPointer(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Cliente',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedClient?.mName ?? 'Toca para buscar y seleccionar',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Listado de productos a facturar
            const Text(
              'Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            ..._facturaItems.asMap().entries.map((entry) {
              int idx = entry.key;
              DetalleVenta item = entry.value;
              return Card(
                child: ListTile(
                  title: Text(item.descripcion),
                  subtitle: Text(
                    'Cantidad: ${item.cantidad} x \$${item.precio.toStringAsFixed(2)}',
                  ),
                  trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                  onTap: () => _showEditItemDialog(idx),
                  onLongPress: () => _showDeleteItemConfirmation(idx),
                ),
              );
            }).toList(),

            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  'Agregar Producto',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Total de la factura
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_totalFactura.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Condición de pago
            const Text(
              'Condición de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Condición',
                border: OutlineInputBorder(),
              ),
              value: _condicionPago,
              items:
                  ['Contado', 'Crédito'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _condicionPago = newValue!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Método de pago (solo si es de contado)
            if (_condicionPago == 'Contado') ...[
              const Text(
                'Método de Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Método',
                  border: OutlineInputBorder(),
                ),
                value: _metodoPago,
                items:
                    ['Divisas', 'Pago Móvil', 'Efectivo', 'Transferencia'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _metodoPago = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

            Center(
              child: ElevatedButton(
                onPressed: _saveFactura,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Guardar e Imprimir',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget genérico para el diálogo de búsqueda
class _SearchDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemToString;

  const _SearchDialog({
    super.key,
    required this.title,
    required this.items,
    required this.itemToString,
  });

  @override
  _SearchDialogState<T> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems =
          widget.items.where((item) {
            return widget.itemToString(item).toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Escribe para buscar...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(widget.itemToString(item)),
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
    );
  }
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

//   // Diálogo para agregar productos a la factura
//   void _showAddProductDialog() {
//     final productoProvider = Provider.of<ProductoProvider>(
//       context,
//       listen: false,
//     );
//     Producto? selectedProduct;
//     final TextEditingController cantidadController = TextEditingController(
//       text: '1',
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Agregar Producto'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButtonFormField<Producto>(
//                     decoration: const InputDecoration(labelText: 'Producto'),
//                     items:
//                         productoProvider.productos.map((Producto producto) {
//                           return DropdownMenuItem<Producto>(
//                             value: producto,
//                             child: Text(producto.descripcion),
//                           );
//                         }).toList(),
//                     onChanged: (Producto? newValue) {
//                       setState(() {
//                         selectedProduct = newValue;
//                       });
//                     },
//                     value: selectedProduct,
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: cantidadController,
//                     decoration: const InputDecoration(labelText: 'Cantidad'),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Cancelar'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (selectedProduct != null) {
//                       final cantidad =
//                           double.tryParse(cantidadController.text) ?? 1.0;
//                       final totalItem = cantidad * selectedProduct!.precio;
//                       setState(() {
//                         _facturaItems.add(
//                           DetalleVenta(
//                             idVenta: '', // Se asignará al guardar
//                             idProducto: selectedProduct!.idProducto,
//                             descripcion: selectedProduct!.descripcion,
//                             unidad: selectedProduct!.unidad,
//                             cantidad: cantidad,
//                             precio: selectedProduct!.precio,
//                             total: totalItem,
//                             orden: _facturaItems.length.toDouble() + 1,
//                             createdAt: DateTime.now().toIso8601String(),
//                             updatedAt: DateTime.now().toIso8601String(),
//                           ),
//                         );
//                       });
//                       _calculateTotal();
//                       Navigator.of(context).pop();
//                     }
//                   },
//                   child: const Text('Agregar'),
//                 ),
//               ],
//             );
//           },
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
//     final clienteProvider = Provider.of<ClienteProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nueva Factura'),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Selección del cliente
//             const Text(
//               'Cliente',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Consumer<ClienteProvider>(
//               builder: (context, provider, child) {
//                 return DropdownButtonFormField<Cliente>(
//                   decoration: const InputDecoration(
//                     labelText: 'Seleccionar Cliente',
//                     border: OutlineInputBorder(),
//                   ),
//                   value: _selectedClient,
//                   items:
//                       provider.clientes.map((Cliente cliente) {
//                         return DropdownMenuItem<Cliente>(
//                           value: cliente,
//                           child: Text(cliente.mName),
//                         );
//                       }).toList(),
//                   onChanged: (Cliente? newValue) {
//                     setState(() {
//                       _selectedClient = newValue;
//                     });
//                   },
//                 );
//               },
//             ),

//             const SizedBox(height: 20),

//             // Listado de productos a facturar
//             const Text(
//               'Productos',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
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
