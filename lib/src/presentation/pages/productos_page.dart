import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../customs/constants.dart' show Constants;
import '../../models/producto_model.dart' show Producto;
import '../../providers/producto_provider.dart';

// Definimos la página principal de productos como un StatefulWidget
// Definimos la página principal de productos como un StatefulWidget
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // Inicializamos la carga de productos y el listener del campo de búsqueda
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductoProvider>(context, listen: false).loadProductos();
    });
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  // Liberar el controlador de texto cuando el widget se destruye
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Obtiene la lista de productos filtrada
  List<Producto> get _filteredProductos {
    final productoProvider = Provider.of<ProductoProvider>(context);
    final allProductos = productoProvider.productos;
    if (_searchText.isEmpty) {
      // Si el campo de búsqueda está vacío, devuelve todos los productos ordenados
      final sortedProductos = List<Producto>.from(allProductos);
      sortedProductos.sort((a, b) => a.descripcion.compareTo(b.descripcion));
      return sortedProductos;
    } else {
      // Filtra y ordena los productos según el texto de búsqueda
      final filteredList =
          allProductos.where((producto) {
            return producto.descripcion.toLowerCase().contains(_searchText) ||
                producto.categoria.toLowerCase().contains(_searchText);
          }).toList();
      filteredList.sort((a, b) => a.descripcion.compareTo(b.descripcion));
      return filteredList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        // backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchText = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductoProvider>(
              builder: (context, productoProvider, child) {
                final sortedProductos = _filteredProductos;

                // Si la lista de productos está vacía, mostramos un mensaje
                if (sortedProductos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron productos.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // Si hay productos, los mostramos en un ListView
                return ListView.builder(
                  itemCount: sortedProductos.length,
                  itemBuilder: (context, index) {
                    final producto = sortedProductos[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_bag,
                          color: Colors.teal,
                        ),
                        title: Text(
                          producto.descripcion,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Categoría: ${producto.categoria}\nPrecio: \$${producto.precio.toStringAsFixed(2)}\nExistencia: ${producto.existencia.toStringAsFixed(0)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () {
                                _showEditProductoDialog(context, producto);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Lógica para mostrar la confirmación de eliminación
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Confirmar Eliminación',
                                      ),
                                      content: Text(
                                        '¿Estás seguro de que quieres eliminar a ${producto.descripcion}?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Elimina el producto y cierra la ventana de diálogo
                                            Provider.of<ProductoProvider>(
                                              context,
                                              listen: false,
                                            ).deleteProducto(
                                              producto.idProducto,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductoDialog(context);
        },
        // backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Diálogo para agregar un nuevo producto
  void _showAddProductoDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController unidadController = TextEditingController();
    final TextEditingController catController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    final TextEditingController costoController = TextEditingController();
    final TextEditingController existController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Usamos StatefulBuilder para gestionar el estado del diálogo
        return StatefulBuilder(
          builder: (context, setState) {
            bool idExists = Provider.of<ProductoProvider>(
              context,
              listen: false,
            ).productos.any(
              (producto) => producto.idProducto == idController.text,
            );
            String? idErrorText =
                idExists ? 'El ID de producto ya existe.' : null;
            bool isButtonDisabled = idController.text.isEmpty || idExists;

            return AlertDialog(
              title: const Text('Agregar Nuevo Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: 'ID de Producto',
                        errorText: idErrorText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          idExists = Provider.of<ProductoProvider>(
                            context,
                            listen: false,
                          ).productos.any(
                            (producto) => producto.idProducto == value,
                          );
                          idErrorText =
                              idExists ? 'El ID de producto ya existe.' : null;
                          isButtonDisabled = value.isEmpty || idExists;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unidadController,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catController,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Precio'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Costo'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: existController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Existencia',
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
                ElevatedButton(
                  onPressed:
                      isButtonDisabled
                          ? null
                          : () {
                            final nuevoProducto = Producto(
                              idProducto: idController.text,
                              descripcion: descController.text,
                              unidad: unidadController.text,
                              categoria: catController.text,
                              precio:
                                  double.tryParse(precioController.text) ?? 0.0,
                              costo:
                                  double.tryParse(costoController.text) ?? 0.0,
                              existencia:
                                  double.tryParse(existController.text) ?? 0.0,
                              createdAt: DateTime.now().toIso8601String(),
                              updatedAt: DateTime.now().toIso8601String(),
                            );
                            Provider.of<ProductoProvider>(
                              context,
                              listen: false,
                            ).addProducto(nuevoProducto);
                            Navigator.of(context).pop();
                          },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Diálogo para editar un producto existente
  void _showEditProductoDialog(BuildContext context, Producto producto) {
    final TextEditingController idController = TextEditingController(
      text: producto.idProducto,
    );
    final TextEditingController descController = TextEditingController(
      text: producto.descripcion,
    );
    final TextEditingController unidadController = TextEditingController(
      text: producto.unidad,
    );
    final TextEditingController catController = TextEditingController(
      text: producto.categoria,
    );
    final TextEditingController precioController = TextEditingController(
      text: producto.precio.toString(),
    );
    final TextEditingController costoController = TextEditingController(
      text: producto.costo.toString(),
    );
    final TextEditingController existController = TextEditingController(
      text: producto.existencia.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'ID de Producto',
                  ),
                  enabled: false, // El ID no debe ser editable
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unidadController,
                  decoration: const InputDecoration(labelText: 'Unidad'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Precio'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: costoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Costo'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: existController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Existencia'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final productoActualizado = producto.copyWith(
                  descripcion: descController.text,
                  unidad: unidadController.text,
                  categoria: catController.text,
                  precio: double.tryParse(precioController.text) ?? 0.0,
                  costo: double.tryParse(costoController.text) ?? 0.0,
                  existencia: double.tryParse(existController.text) ?? 0.0,
                  updatedAt:
                      DateTime.now().toIso8601String(), // Actualizamos la fecha
                );
                Provider.of<ProductoProvider>(
                  context,
                  listen: false,
                ).updateProducto(productoActualizado);
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}


// class _ProductosPageState extends State<ProductosPage> {
//   // Inicializamos la carga de productos al iniciar el widget
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ProductoProvider>(context, listen: false).loadProductos();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.colorGray,
//       appBar: AppBar(title: const Text('Lista de Productos')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Buscar productos...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchText.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {
//                             _searchText = '';
//                           });
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                 ),
//               ),
//             ),
//           ),

//           Expanded(
//             child: Consumer<ProductoProvider>(
//               builder: (context, productoProvider, child) {
//                 // Obtener una copia de la lista de productos para no modificar la original del provider
//                 final sortedProductos = List<Producto>.from(
//                   productoProvider.productos,
//                 );
            
//                 // Ordenar la lista alfabéticamente por la descripción
//                 sortedProductos.sort(
//                   (a, b) => a.descripcion.compareTo(b.descripcion),
//                 );
            
//                 // Si la lista de productos está vacía, mostramos un mensaje
//                 if (sortedProductos.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No hay productos. Agrega uno nuevo.',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   );
//                 }
            
//                 // Si hay productos, los mostramos en un ListView
//                 return ListView.builder(
//                   itemCount: sortedProductos.length,
//                   itemBuilder: (context, index) {
//                     final producto =
//                         sortedProductos.length > index
//                             ? sortedProductos[index]
//                             : null;
//                     if (producto == null) {
//                       return const SizedBox.shrink(); // Evitar errores si el producto es nulo
//                     }
//                     return Card(
//                       elevation: 4,
//                       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                       child: ListTile(
//                         leading: const Icon(Icons.shopping_bag, color: Colors.teal),
//                         title: Text(
//                           producto.descripcion,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(
//                           'Categoría: ${producto.categoria}\nPrecio: \$${producto.precio.toStringAsFixed(2)}\nExistencia: ${producto.existencia.toStringAsFixed(0)}',
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit, color: Colors.amber),
//                               onPressed: () {
//                                 _showEditProductoDialog(context, producto);
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 // Lógica para mostrar la confirmación de eliminación
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: const Text('Confirmar Eliminación'),
//                                       content: Text(
//                                         '¿Estás seguro de que quieres eliminar a ${producto.descripcion}?',
//                                       ),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed:
//                                               () => Navigator.of(context).pop(),
//                                           child: const Text('Cancelar'),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             // Elimina el producto y cierra la ventana de diálogo
//                                             Provider.of<ProductoProvider>(
//                                               context,
//                                               listen: false,
//                                             ).deleteProducto(producto.idProducto);
//                                             Navigator.of(context).pop();
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red,
//                                           ),
//                                           child: const Text(
//                                             'Eliminar',
//                                             style: TextStyle(color: Colors.white),
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         isThreeLine: true,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddProductoDialog(context);
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   // Diálogo para agregar un nuevo producto
//   void _showAddProductoDialog(BuildContext context) {
//     final TextEditingController idController = TextEditingController();
//     final TextEditingController descController = TextEditingController();
//     final TextEditingController unidadController = TextEditingController();
//     final TextEditingController catController = TextEditingController();
//     final TextEditingController precioController = TextEditingController();
//     final TextEditingController costoController = TextEditingController();
//     final TextEditingController existController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // Usamos StatefulBuilder para gestionar el estado del diálogo
//         return StatefulBuilder(
//           builder: (context, setState) {
//             bool idExists = Provider.of<ProductoProvider>(
//               context,
//               listen: false,
//             ).productos.any(
//               (producto) => producto.idProducto == idController.text,
//             );
//             String? idErrorText =
//                 idExists ? 'El ID de producto ya existe.' : null;
//             bool isButtonDisabled = idController.text.isEmpty || idExists;

//             return AlertDialog(
//               backgroundColor: Constants.colorBackgroundAlertDialog,
//               title: const Text('Agregar Nuevo Producto'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: idController,
//                       decoration: InputDecoration(
//                         labelText: 'ID de Producto',
//                         errorText: idErrorText,
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           idExists = Provider.of<ProductoProvider>(
//                             context,
//                             listen: false,
//                           ).productos.any(
//                             (producto) => producto.idProducto == value,
//                           );
//                           idErrorText =
//                               idExists ? 'El ID de producto ya existe.' : null;
//                           isButtonDisabled = value.isEmpty || idExists;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: descController,
//                       decoration: const InputDecoration(
//                         labelText: 'Descripción',
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: unidadController,
//                       decoration: const InputDecoration(labelText: 'Unidad'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: catController,
//                       decoration: const InputDecoration(labelText: 'Categoría'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: precioController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: const InputDecoration(labelText: 'Precio'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: costoController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: const InputDecoration(labelText: 'Costo'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: existController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: const InputDecoration(
//                         labelText: 'Existencia',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Cancelar'),
//                 ),
//                 ElevatedButton(
//                   onPressed:
//                       isButtonDisabled
//                           ? null
//                           : () {
//                             final nuevoProducto = Producto(
//                               idProducto: idController.text,
//                               descripcion: descController.text,
//                               unidad: unidadController.text,
//                               categoria: catController.text,
//                               precio:
//                                   double.tryParse(precioController.text) ?? 0.0,
//                               costo:
//                                   double.tryParse(costoController.text) ?? 0.0,
//                               existencia:
//                                   double.tryParse(existController.text) ?? 0.0,
//                             );
//                             Provider.of<ProductoProvider>(
//                               context,
//                               listen: false,
//                             ).addProducto(nuevoProducto);
//                             Navigator.of(context).pop();
//                           },
//                   child: const Text('Guardar'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Diálogo para editar un producto existente
//   void _showEditProductoDialog(BuildContext context, Producto producto) {
//     final TextEditingController idController = TextEditingController(
//       text: producto.idProducto,
//     );
//     final TextEditingController descController = TextEditingController(
//       text: producto.descripcion,
//     );
//     final TextEditingController unidadController = TextEditingController(
//       text: producto.unidad,
//     );
//     final TextEditingController catController = TextEditingController(
//       text: producto.categoria,
//     );
//     final TextEditingController precioController = TextEditingController(
//       text: producto.precio.toString(),
//     );
//     final TextEditingController costoController = TextEditingController(
//       text: producto.costo.toString(),
//     );
//     final TextEditingController existController = TextEditingController(
//       text: producto.existencia.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Constants.colorBackgroundAlertDialog,
//           title: const Text('Editar Producto'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: idController,
//                   decoration: const InputDecoration(
//                     labelText: 'ID de Producto',
//                   ),
//                   enabled: false, // El ID no debe ser editable
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: descController,
//                   decoration: const InputDecoration(labelText: 'Descripción'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: unidadController,
//                   decoration: const InputDecoration(labelText: 'Unidad'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: catController,
//                   decoration: const InputDecoration(labelText: 'Categoría'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: precioController,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   decoration: const InputDecoration(labelText: 'Precio'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: costoController,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   decoration: const InputDecoration(labelText: 'Costo'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: existController,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   decoration: const InputDecoration(labelText: 'Existencia'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final productoActualizado = producto.copyWith(
//                   descripcion: descController.text,
//                   unidad: unidadController.text,
//                   categoria: catController.text,
//                   precio: double.tryParse(precioController.text) ?? 0.0,
//                   costo: double.tryParse(costoController.text) ?? 0.0,
//                   existencia: double.tryParse(existController.text) ?? 0.0,
//                   updatedAt:
//                       DateTime.now().toIso8601String(), // Actualizamos la fecha
//                 );
//                 Provider.of<ProductoProvider>(
//                   context,
//                   listen: false,
//                 ).updateProducto(productoActualizado);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Guardar Cambios'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
