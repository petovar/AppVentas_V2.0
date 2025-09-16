// import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';

import '../models/detalleventa_model.dart';
import '../models/pagoventa_model.dart';
import '../models/venta_model.dart';
import 'constants.dart';
import 'loading.dart';
import 'overlay_progress_loading.dart' show OverlayLoadingProgress;

String mGenerateUniqueId() {
  // Generar UUID
  String mUniqueId = const Uuid().v4();

  return mUniqueId;
}

// para convertir un color hexadecimal en un color de flutter
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[900],
          content: Text(message),
          duration: Duration(milliseconds: 1000),
        ),
      )
      .closed
      .then(
        (value) => Future.delayed(Duration(milliseconds: 3000), () {
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        }),
      );
}

abstract class ProgressDialog {
  static show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          ),
          //onWillPop: () async => false,
        );
      },
    );
  }

  static dissmiss(BuildContext context) {
    Navigator.pop(context);
  }
}

progressDialogShow(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
  OverlayLoadingProgress.start(
    context,
    barrierDismissible: false,
    widget: Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        padding: const EdgeInsets.only(top: 30),
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 10),
              blurRadius: 50,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Consultando...", style: Constants.textStyleBlackBold),
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Loading(
                mColor: HexColor.fromHex('#000000'),
                mIndicator: Indicator.ballBeat,
                mSize: 5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

dialogDismiss() {
  OverlayLoadingProgress.stop();
}
