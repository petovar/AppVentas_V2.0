import 'package:intl/intl.dart';

import '../models/detalleventa_model.dart';
import '../models/pagoventa_model.dart';
import '../models/venta_model.dart';
import 'constants.dart';

class Libreria {
  static String generateReceiptContent(
    Venta venta,
    List<DetalleVenta> detalles,
    PagoVenta? pago,
  ) {
    final format = NumberFormat.currency(locale: 'es_VE', symbol: '\$');
    const int lineWidth = 32;
    // final format = NumberFormat.currency(locale: 'es_VE', symbol: '\$');
    // Para alinear, usamos un formato sin símbolo para calcular el espacio.
    final formatPlain = NumberFormat.currency(locale: 'es_VE', symbol: '');
    // final now = DateTime.now();

    String content = '${Constants.nameEmpresa}\n';
    content += '${Constants.dirEmpresa.padLeft((lineWidth - 22) ~/ 2 + 22)}\n';
    content += '-------------- o ---------------\n';

    content += '${'TICKET DE VENTA'.padLeft((lineWidth - 13) ~/ 2 + 13)}\n';
    content += '-------------- o ---------------\n'.padLeft(
      (lineWidth - 30) ~/ 2 + 30,
    );
    final espacios =
        lineWidth - 'TICKET No. ${venta.idVenta.substring(0, 8)}'.length;
    final separacion = ' ' * espacios;

    content += 'TICKET No. $separacion${venta.idVenta.substring(0, 8)}\n';

    // content += '--------------------------------\n';
    content += 'Cliente: ${venta.nombre}\n';
    content += 'Condición: ${venta.condicion}\n';
    content +=
        'Fecha: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(venta.fecha))}';
    content +=
        ' Hora: ${DateFormat('hh:mm a').format(DateTime.parse(venta.fecha))}\n';
    content += '--------------------------------\n';
    content += '${'PRODUCTOS'.padLeft((lineWidth - 7) ~/ 2 + 7)}\n';
    content += '--------------------------------\n';

    double subtotal = 0.0;
    for (var detalle in detalles) {
      // Formateamos el total y lo alineamos a la derecha.
      final totalFormatted = format.format(detalle.total);
      final totalPlain = formatPlain.format(detalle.total);

      final String precioFormatted = format.format(detalle.precio);
      final String quantityAndPrice =
          '${detalle.cantidad.toStringAsFixed(2)} (${detalle.unidad}) x $precioFormatted';
      final String productLine = detalle.descripcion;

      // Calculamos los espacios para alinear el total.
      final spacesBetween = lineWidth - productLine.length - totalPlain.length;
      final padding = '.' * spacesBetween;

      content += '$quantityAndPrice\n';
      content += '$productLine$padding$totalFormatted\n';

      subtotal += detalle.total;
    }

    content += '--------------------------------\n';

    final subtotalFormatted = format.format(subtotal);
    final totalFormatted = format.format(subtotal);

    // Alineamos el subtotal a la derecha.
    final subtotalPlain = formatPlain.format(subtotal);
    final subtotalSpaces =
        lineWidth - 'SUBTOTAL:'.length - subtotalPlain.length;
    content += 'SUBTOTAL:${' ' * subtotalSpaces}$subtotalFormatted\n';

    // Alineamos el total a la derecha.
    final totalPlainTotal = formatPlain.format(subtotal);
    final totalSpaces = lineWidth - 'TOTAL:'.length - totalPlainTotal.length;
    content += 'TOTAL:${' ' * totalSpaces}$totalFormatted\n';

    content += '--------------------------------\n';
    if (pago != null) {
      content += 'Método de Pago: ${pago.metodoPago}\n';
      final spacesBetween =
          lineWidth - 'Monto Pagado: ${format.format(subtotal)}'.length;
      final padding = ' ' * spacesBetween;
      content += 'Monto Pagado: $padding ${format.format(pago.montoPago)}\n';
    } else {
      final spacesBetween =
          lineWidth - 'Monto a Pagar: ${format.format(subtotal)}'.length;
      final padding = ' ' * spacesBetween;

      content += 'Monto a Pagar: $padding ${format.format(subtotal)}\n';
    }
    content += '--------------------------------\n';
    content +=
        '${'¡GRACIAS POR SU COMPRA!'.padLeft((lineWidth - 22) ~/ 2 + 22)}\n';
    content += '--------------------------------\n';

    return content;
  }
}
