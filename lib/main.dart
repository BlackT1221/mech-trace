import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart'; // Importamos la nueva pantalla

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MechTraceApp());
}

class MechTraceApp extends StatelessWidget {
  const MechTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Fondo gris muy claro para resaltar las tarjetas blancas
        scaffoldBackgroundColor: const Color(0xFFF5F6F8), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE50000), // Rojo Deportivo
          secondary: Colors.black,    // Acentos negros
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE50000),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: MainScreen(), // Aquí integramos la pantalla principal
    );
  }
}