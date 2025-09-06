import 'package:flutter/material.dart';
import 'src/app.dart';

Future<void> main() async {
  // esto requiere para la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}
