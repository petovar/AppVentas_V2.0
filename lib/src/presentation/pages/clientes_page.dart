import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/cliente_model.dart';
import '../../providers/cliente_provider.dart';

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
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(title: const Text('Lista de Clientes')),
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

        child: const Icon(Icons.person_add, color: Colors.white),
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
          title: Text('Agregar Cliente', style: TextStyle(fontSize: 22.0)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: aliasController,
                  decoration: const InputDecoration(labelText: 'Alias'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dirController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: aliasController,
                  decoration: const InputDecoration(labelText: 'Alias'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dirController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                const SizedBox(height: 20),
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
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
