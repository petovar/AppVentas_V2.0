import 'package:app_ventas/src/customs/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/factura_provider.dart';
import 'package:share_plus/share_plus.dart';

class VentasSummaryPage extends StatefulWidget {
  const VentasSummaryPage({super.key});

  @override
  State<VentasSummaryPage> createState() => _VentasSummaryPageState();
}

class _VentasSummaryPageState extends State<VentasSummaryPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  // Método para seleccionar una fecha
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? _startDate ?? DateTime.now()
              : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  // Genera un resumen de ventas en formato de texto para compartir
  String _generateSummaryText(Map<String, dynamic> summary) {
    String summaryText = '';
    if (summary.isNotEmpty) {
      final totalVentas = summary['total_ventas'] as double;
      final numFacturas = summary['num_facturas'] as int;
      final salesByCondition =
          summary['sales_by_condition'] as Map<String, dynamic>;
      final paymentsByMethod =
          summary['payments_by_method'] as Map<String, dynamic>;
      final topProducts = summary['top_products'] as List<Map<String, dynamic>>;
      summaryText = '${Constants.nameEmpresa}\n';
      summaryText += '-------------- o ---------------\n\n';
      summaryText += 'Resumen de Ventas:\n\n';
      summaryText += 'Total de Ventas: \$${totalVentas.toStringAsFixed(2)}\n';
      summaryText += 'Facturas Emitidas: $numFacturas\n\n';

      summaryText += 'Ventas por Condición:\n';
      salesByCondition.forEach((key, value) {
        summaryText += '- $key: \$${(value as double).toStringAsFixed(2)}\n';
      });
      summaryText += '\n';

      summaryText += 'Pagos Percibidos:\n';
      paymentsByMethod.forEach((key, value) {
        summaryText += '- $key: \$${(value as double).toStringAsFixed(2)}\n';
      });
      final totalPayments = paymentsByMethod.values.fold(
        0.0,
        (sum, item) => sum + (item as double),
      );
      summaryText += 'Total Pagos: \$${totalPayments.toStringAsFixed(2)}\n\n';

      summaryText += 'Productos Más Vendidos:\n';
      if (topProducts.isEmpty) {
        summaryText += 'No hay productos vendidos aún.';
      } else {
        for (var product in topProducts) {
          summaryText +=
              '- ${product['descripcion']}: ${(product['total_cantidad'] as double).toStringAsFixed(0)}\n';
        }
      }
    }
    return summaryText;
  }

  // Lógica para simular el compartir
  void _shareSummary(BuildContext context, String summaryText) {
    // En un entorno real, usarías un paquete como `share_plus` o `url_launcher`.
    // Por ahora, solo mostraremos un mensaje en la consola.
    if (kDebugMode) {
      print('Simulando compartir el resumen...');
      print('Contenido a compartir:\n$summaryText');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumen listo para compartir.')),
    );

    SharePlus.instance.share(ShareParams(text: summaryText));
  }

  // Lógica para simular la impresión
  // void _printSummary(BuildContext context, String summaryText) {
  //   // En un entorno real, se usaría un paquete de impresión para impresoras térmicas.
  //   // Aquí, solo mostraremos un mensaje en la consola.
  //   if (kDebugMode) {
  //     print('Simulando impresión del resumen...');
  //     print('Contenido a imprimir:\n$summaryText');
  //   }
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Comando de impresión enviado.')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final facturaProvider = Provider.of<FacturaProvider>(
      context,
      listen: false,
    );

    // Convertir el `endDate` a la medianoche para incluir todo el día en el filtro
    final adjustedEndDate =
        _endDate != null
            ? DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              23,
              59,
              59,
            )
            : null;

    return Scaffold(
      backgroundColor: Constants.colorBackgroundScafold,
      appBar: AppBar(
        title: const Text(
          'Resumen de Ventas',
          style: TextStyle(fontSize: 19.0),
        ),
        // backgroundColor: Colors.teal,
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: facturaProvider.getSalesSummary(
              startDate: _startDate,
              endDate: adjustedEndDate,
            ),
            builder: (context, snapshot) {
              final summaryData = snapshot.data ?? {};
              final summaryText = _generateSummaryText(summaryData);
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed:
                        snapshot.connectionState == ConnectionState.done
                            ? () => _shareSummary(context, summaryText)
                            : null,
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.print, color: Colors.white),
                  //   onPressed:
                  //       snapshot.connectionState == ConnectionState.done
                  //           ? () => _printSummary(context, summaryText)
                  //           : null,
                  // ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      'Desde: ${_startDate?.toString().substring(0, 10) ?? 'Seleccionar'}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      'Hasta: ${_endDate?.toString().substring(0, 10) ?? 'Seleccionar'}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: facturaProvider.getSalesSummary(
                startDate: _startDate,
                endDate: adjustedEndDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.isEmpty ||
                    snapshot.data!['total_ventas'] == 0.0) {
                  return const Center(
                    child: Text(
                      'No hay datos de ventas para el período seleccionado.',
                    ),
                  );
                }

                final summary = snapshot.data!;
                final totalVentas = summary['total_ventas'] as double;
                final numFacturas = summary['num_facturas'] as int;
                final salesByCondition =
                    summary['sales_by_condition'] as Map<String, dynamic>;
                final paymentsByMethod =
                    summary['payments_by_method'] as Map<String, dynamic>;
                final topProducts =
                    summary['top_products'] as List<Map<String, dynamic>>;
                final totalPagos = paymentsByMethod.values.fold(
                  0.0,
                  (sum, item) => sum + (item as double),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de Resumen General
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total de Ventas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${totalVentas.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Facturas Emitidas',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '$numFacturas',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tarjeta de Ventas por Condición
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ventas por Condición',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Contado:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '\$${(salesByCondition['Contado'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Crédito:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '\$${(salesByCondition['Crédito'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tarjeta de Pagos Percibidos
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pagos Percibidos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...paymentsByMethod.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${entry.key}:',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '\$${(entry.value as double).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Pagos:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalPagos.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tarjeta de Productos Más Vendidos
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Productos Más Vendidos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (topProducts.isEmpty)
                                const Text('No hay productos vendidos aún.'),
                              ...topProducts.asMap().entries.map((entry) {
                                int index = entry.key;
                                var product = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          product['descripcion'] as String,
                                        ),
                                      ),
                                      Text(
                                        (product['total_cantidad'] as double)
                                            .toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
