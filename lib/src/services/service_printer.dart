// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/foundation.dart';

// // Este es solo un ejemplo de cómo sería el servicio de impresión.
// // No está integrado directamente en la página de facturación.

// class PrintService {
//   BlueThermalPrinter printer = BlueThermalPrinter.instance;

//   Future<void> printReceipt(String receiptContent) async {
//     // 1. Verificar el estado del Bluetooth
//     bool? isConnected = await printer.isConnected;
//     if (isConnected == true) {
//       // 2. Si ya está conectado, simplemente imprimir
//       await _print(receiptContent);
//     } else {
//       // 3. Si no está conectado, buscar y conectar
//       await _connectAndPrint(receiptContent);
//     }
//   }

//   Future<void> _connectAndPrint(String receiptContent) async {
//     try {
//       List<BluetoothDevice> devices = await printer.getBondedDevices();
//       if (devices.isNotEmpty) {
//         // En un entorno real, el usuario seleccionaría el dispositivo de una lista.
//         // Aquí, conectamos al primer dispositivo por simplicidad.
//         BluetoothDevice device = devices.first;
//         await printer.connect(device);
//         await Future.delayed(Duration(seconds: 2)); // Esperar la conexión
//         await _print(receiptContent);
//         await printer.disconnect();
//       } else {
//         if (kDebugMode) {
//           print('No se encontraron dispositivos Bluetooth emparejados.');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error al conectar o imprimir: $e');
//       }
//     }
//   }

//   Future<void> _print(String receiptContent) async {
//     printer.printNewLine();
//     printer.printCustom(receiptContent, 1, 1);
//     printer.printNewLine();
//     printer.paperCut();
//   }
// }
