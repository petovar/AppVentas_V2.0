import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
// import '../../customs/constants.dart';
import '../../models/cliente_model.dart';
import '../../providers/cliente_provider.dart';
// import 'cliente_provider.dart';
// import 'cliente.dart';

// Definimos la página principal de clientes como un StatefulWidget
class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClienteProvider>(context, listen: false).loadClientes();
    });
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Cliente> get _filteredClientes {
    final clienteProvider = Provider.of<ClienteProvider>(context);
    final allClientes = clienteProvider.clientes;
    if (_searchText.isEmpty) {
      final sortedClientes = List<Cliente>.from(allClientes);
      sortedClientes.sort((a, b) => a.mName.compareTo(b.mName));
      return sortedClientes;
    } else {
      final filteredList =
          allClientes.where((cliente) {
            return cliente.mName.toLowerCase().contains(_searchText) ||
                cliente.mAlias.toLowerCase().contains(_searchText);
          }).toList();
      filteredList.sort((a, b) => a.mName.compareTo(b.mName));
      return filteredList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
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
            child: Consumer<ClienteProvider>(
              builder: (context, clienteProvider, child) {
                final sortedClientes = _filteredClientes;
                if (sortedClientes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron clientes.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: sortedClientes.length,
                  itemBuilder: (context, index) {
                    final cliente = sortedClientes[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.teal),
                        title: Text(
                          cliente.mName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Alias: ${cliente.mAlias}\nTeléfono: ${cliente.mTelefono}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () {
                                _showEditClienteDialog(context, cliente);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Confirmar Eliminación',
                                      ),
                                      content: Text(
                                        '¿Estás seguro de que quieres eliminar a ${cliente.mName}?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            clienteProvider.deleteCliente(
                                              cliente.mIdx,
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
          _showAddClienteDialog(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddClienteDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController aliasController = TextEditingController();
    final TextEditingController telController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController dirController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: aliasController,
                  decoration: const InputDecoration(labelText: 'Alias'),
                ),
                TextField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: dirController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
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
                final newCliente = Cliente(
                  mIdx: const Uuid().v4(),
                  mName: nameController.text,
                  mAlias: aliasController.text,
                  mTelefono: telController.text,
                  mEmail: emailController.text,
                  mDireccion: dirController.text,
                  mCreatedAt: DateTime.now().toIso8601String(),
                  mUpdatedAt: DateTime.now().toIso8601String(),
                );
                Provider.of<ClienteProvider>(
                  context,
                  listen: false,
                ).addCliente(newCliente);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditClienteDialog(BuildContext context, Cliente cliente) {
    final TextEditingController nameController = TextEditingController(
      text: cliente.mName,
    );
    final TextEditingController aliasController = TextEditingController(
      text: cliente.mAlias,
    );
    final TextEditingController telController = TextEditingController(
      text: cliente.mTelefono,
    );
    final TextEditingController emailController = TextEditingController(
      text: cliente.mEmail,
    );
    final TextEditingController dirController = TextEditingController(
      text: cliente.mDireccion,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: aliasController,
                  decoration: const InputDecoration(labelText: 'Alias'),
                ),
                TextField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: dirController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
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
                final updatedCliente = cliente.copyWith(
                  mName: nameController.text,
                  mAlias: aliasController.text,
                  mTelefono: telController.text,
                  mEmail: emailController.text,
                  mDireccion: dirController.text,
                  mUpdatedAt: DateTime.now().toIso8601String(),
                );
                Provider.of<ClienteProvider>(
                  context,
                  listen: false,
                ).updateCliente(updatedCliente);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }
}

// class _ClientesPageState extends State<ClientesPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchText = '';

//   // Inicializamos la carga de clientes y el listener al iniciar el widget
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ClienteProvider>(context, listen: false).loadClientes();
//     });
//     _searchController.addListener(() {
//       setState(() {
//         _searchText = _searchController.text.toLowerCase();
//       });
//     });
//   }

//   // Liberar el controlador de texto cuando el widget se destruye
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // Obtiene la lista de productos filtrada
//   List<Cliente> get _filteredClientes {
//     final clienteProvider = Provider.of<ClienteProvider>(context);
//     final allClientes = clienteProvider.clientes;
//     if (_searchText.isEmpty) {
//       // Si el campo de búsqueda está vacío, devuelve todos los productos ordenados
//       final sortedClientes = List<Cliente>.from(allClientes);
//       sortedClientes.sort((a, b) => a.mName.compareTo(b.mName));
//       return sortedClientes;
//     } else {
//       // Filtra y ordena los productos según el texto de búsqueda
//       final filteredList =
//           allClientes.where((cliente) {
//             return cliente.mName.toLowerCase().contains(_searchText) ||
//                 cliente.mAlias.toLowerCase().contains(_searchText);
//           }).toList();
//       filteredList.sort((a, b) => a.mName.compareTo(b.mName));
//       return filteredList;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.colorGray,
//       appBar: AppBar(title: const Text('Lista de Clientes')),
//       body: Consumer<ClienteProvider>(
//         builder: (context, clienteProvider, child) {
//           // Si la lista de clientes está vacía, mostramos un mensaje
//           if (clienteProvider.clientes.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No hay clientes. Agrega uno nuevo.',
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }

//           // Si hay clientes, los mostramos en un ListView
//           return ListView.builder(
//             itemCount: clienteProvider.clientes.length,
//             itemBuilder: (context, index) {
//               final cliente = clienteProvider.clientes[index];
//               return Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blueGrey,
//                     child: Text(
//                       cliente.mName!.isNotEmpty ? cliente.mName![0] : '?',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   title: Text(
//                     cliente.mName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     'Alias: ${cliente.mAlias}\nTeléfono: ${cliente.mTelefono}',
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.amber),
//                         onPressed: () {
//                           // TODO: Implementar la lógica para editar
//                           _showEditClienteDialog(context, cliente);
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           // Lógica para eliminar el cliente
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text('Confirmar Eliminación'),
//                                 content: Text(
//                                   '¿Estás seguro de que quieres eliminar a ${cliente.mName}?',
//                                 ),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed:
//                                         () => Navigator.of(context).pop(),
//                                     child: const Text('Cancelar'),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       // Elimina el cliente y cierra la ventana de diálogo
//                                       Provider.of<ClienteProvider>(
//                                         context,
//                                         listen: false,
//                                       ).deleteCliente(cliente.mIdx!);
//                                       Navigator.of(context).pop();
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red,
//                                     ),
//                                     child: const Text(
//                                       'Eliminar',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                           // Provider.of<ClienteProvider>(
//                           //   context,
//                           //   listen: false,
//                           // ).deleteCliente(cliente.mIdx!);
//                         },
//                       ),
//                     ],
//                   ),
//                   isThreeLine: true,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Mostramos un diálogo para agregar un nuevo cliente
//           _showAddClienteDialog(context);
//         },
//         //backgroundColor: Colors.blueAccent,
//         child: const Icon(
//           Icons.person_add,
//           color: Colors.white,
//         ), //Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   // Diálogo para agregar un nuevo cliente
//   void _showAddClienteDialog(BuildContext context) {
//     final TextEditingController nameController = TextEditingController();
//     final TextEditingController aliasController = TextEditingController();
//     final TextEditingController telController = TextEditingController();
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController dirController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Constants.colorBackgroundAlertDialog,
//           title: const Text('Agregar Nuevo Cliente'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: 'Nombre'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: aliasController,
//                   decoration: const InputDecoration(labelText: 'Alias'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: telController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(labelText: 'Teléfono'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: dirController,
//                   decoration: const InputDecoration(labelText: 'Dirección'),
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
//                 final nuevoCliente = Cliente(
//                   mName: nameController.text,
//                   mAlias: aliasController.text,
//                   mTelefono: telController.text,
//                   mEmail: emailController.text,
//                   mDireccion: dirController.text,
//                 );
//                 Provider.of<ClienteProvider>(
//                   context,
//                   listen: false,
//                 ).addCliente(nuevoCliente);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Guardar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Diálogo para editar un cliente existente
//   void _showEditClienteDialog(BuildContext context, Cliente cliente) {
//     final TextEditingController nameController = TextEditingController(
//       text: cliente.mName,
//     );
//     final TextEditingController aliasController = TextEditingController(
//       text: cliente.mAlias,
//     );
//     final TextEditingController telController = TextEditingController(
//       text: cliente.mTelefono,
//     );
//     final TextEditingController emailController = TextEditingController(
//       text: cliente.mEmail,
//     );
//     final TextEditingController dirController = TextEditingController(
//       text: cliente.mDireccion,
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Constants.colorBackgroundAlertDialog,
//           title: const Text('Editar Cliente'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: 'Nombre'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: aliasController,
//                   decoration: const InputDecoration(labelText: 'Alias'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: telController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(labelText: 'Teléfono'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                 ),
//                 SizedBox(height: 10.0),
//                 TextField(
//                   controller: dirController,
//                   decoration: const InputDecoration(labelText: 'Dirección'),
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
//                 final clienteActualizado = cliente.copyWith(
//                   mName: nameController.text,
//                   mAlias: aliasController.text,
//                   mTelefono: telController.text,
//                   mEmail: emailController.text,
//                   mDireccion: dirController.text,
//                   mUpdatedAt:
//                       DateTime.now().toIso8601String(), // Actualizamos la fecha
//                 );
//                 Provider.of<ClienteProvider>(
//                   context,
//                   listen: false,
//                 ).updateCliente(clienteActualizado);
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

// // import 'package:app_ventas/src/handlers/dabase_helper.dart';
// // import 'package:app_ventas/src/models/cliente_model.dart';
// // import 'package:flutter/material.dart';

// // import '../../customs/library.dart';
// // // import '../../handlers/sqlite_handler.dart' show SqliteHandler;

// // // import '../../handlers/sqlite_handler.dart';
// // // import '../custom/library.dart';

// // class ClientesPage extends StatelessWidget {
// //   const ClientesPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     Clientes mClientes = Clientes();
// //     //SqliteHandler mSqliteHandler = SqliteHandler();
// //     int num_clts = DatabaseHelper.instance.queryRowCount("Clientes") as int;
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Clientes")),
// //       floatingActionButton: FloatingActionButton(
// //         child: Icon(Icons.person_add),
// //         onPressed: () {
// //           //
// //           //
// //           showDialogo(context);
// //         },
// //       ),
// //       body: Center(child: Text(num_clts.toString())),
// //     );
// //   }

// //   Future<dynamic> showDialogo(BuildContext context) {
// //     final formKey = GlobalKey<FormState>();
// //     final TextEditingController nombreController = TextEditingController();
// //     final TextEditingController aliasController = TextEditingController();
// //     final TextEditingController telefonoController = TextEditingController();
// //     final TextEditingController emailController = TextEditingController();
// //     final TextEditingController direccionController = TextEditingController();
// //     //SqliteHandler mSqliteHandler = SqliteHandler();

// //     return showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(5.0),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: <Widget>[
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'Agregar Cliente',
// //                         style: TextStyle(
// //                           fontSize: 20.0,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       MaterialButton(
// //                         onPressed: () async {
// //                           if (formKey.currentState!.validate()) {
// //                             // Procesar los datos aquí
// //                             String nombre = nombreController.text;
// //                             String alias = aliasController.text;
// //                             String telefono = telefonoController.text;
// //                             String email = emailController.text;
// //                             String direccion = direccionController.text;

// //                             //ProgressDialog.show(context);
// //                             //progressDialogShow(context);
// //                             DatabaseHelper.instance.insert({
// //                               'idx': mGenerateUniqueId(),
// //                               'name': nombreController.text,
// //                               'alias': aliasController.text,
// //                               'telefono': telefonoController.text,
// //                               'email': emailController.text,
// //                               'direccion': direccionController.text,
// //                             }, 'clientes');
// //                             Future.delayed(const Duration(milliseconds: 2000));
// //                             //dialogDismiss();
// //                             //ProgressDialog.dissmiss(context);
// //                             showSnackBar(
// //                               context,
// //                               "Cliente guardado con éxito !!!",
// //                             );
// //                             // var db = await mSqliteHandler.getDb();
// //                             // await db.insert('clientes', {
// //                             //   'idx': mGenerateUniqueId(),
// //                             //   'name': nombreController.text,
// //                             //   'alias': aliasController.text,
// //                             //   'telefono': telefonoController.text,
// //                             //   'email': emailController.text,
// //                             //   'direccion': direccionController.text,
// //                             // });
// //                             // dialogDismiss();

// //                             // customShowToast(
// //                             //   context,
// //                             //   'Cliente creado exitosamente',
// //                             // );

// //                             // Imprimir los datos en la consola
// //                             print('Nombre: $nombre');
// //                             print('Apellido: $alias');
// //                             print('Teléfono: $telefono');
// //                             print('Email: $email');
// //                             print('Dirección: $direccion');

// //                             // Puedes agregar lógica para guardar los datos en una base de datos, etc.
// //                           }
// //                           if (context.mounted) Navigator.of(context).pop(true);
// //                         },
// //                         color: const Color.fromARGB(255, 18, 18, 19),
// //                         textColor: Colors.white,
// //                         padding: EdgeInsets.all(16),
// //                         shape: CircleBorder(),
// //                         child: Icon(Icons.check_rounded, size: 24),
// //                       ),
// //                       // IconButton(
// //                       //   onPressed: () {},
// //                       //   icon: Icon(Icons.check_rounded),
// //                       // ),
// //                     ],
// //                   ),
// //                   SizedBox(height: 20.0),
// //                   Form(
// //                     key: formKey,
// //                     child: Column(
// //                       children: [
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                             top: 10.0,
// //                             bottom: 10.0,
// //                           ),
// //                           child: TextFormField(
// //                             controller: nombreController,
// //                             decoration: InputDecoration(labelText: 'Nombre'),
// //                             validator: (value) {
// //                               if (value == null || value.isEmpty) {
// //                                 return 'Por favor, ingresa el nombre';
// //                               }
// //                               return null;
// //                             },
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                             top: 10.0,
// //                             bottom: 10.0,
// //                           ),
// //                           child: TextFormField(
// //                             controller: aliasController,
// //                             decoration: InputDecoration(labelText: 'Alias'),
// //                             validator: (value) {
// //                               if (value == null || value.isEmpty) {
// //                                 return 'Por favor, ingresa el alias';
// //                               }
// //                               return null;
// //                             },
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                             top: 10.0,
// //                             bottom: 10.0,
// //                           ),
// //                           child: TextFormField(
// //                             controller: telefonoController,
// //                             decoration: InputDecoration(labelText: 'Teléfono'),
// //                             keyboardType: TextInputType.phone,
// //                             validator: (value) {
// //                               if (value == null || value.isEmpty) {
// //                                 return 'Por favor, ingresa el teléfono';
// //                               }
// //                               return null;
// //                             },
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                             top: 10.0,
// //                             bottom: 10.0,
// //                           ),
// //                           child: TextFormField(
// //                             controller: emailController,
// //                             decoration: InputDecoration(labelText: 'Email'),
// //                             keyboardType: TextInputType.emailAddress,
// //                             validator: (value) {
// //                               if (value == null || value.isEmpty) {
// //                                 return 'Por favor, ingresa el email';
// //                               }
// //                               return null;
// //                             },
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                             top: 10.0,
// //                             bottom: 10.0,
// //                           ),
// //                           child: TextFormField(
// //                             controller: direccionController,
// //                             decoration: InputDecoration(labelText: 'Dirección'),
// //                             validator: (value) {
// //                               if (value == null || value.isEmpty) {
// //                                 return 'Por favor, ingresa la dirección';
// //                               }
// //                               return null;
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 20.0),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
