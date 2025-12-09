import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/home.dart';
import 'package:portal_bioinsumos_app/stats_service.dart';

void main() {
  runApp(const PortalBioinsumosApp());
}

class PortalBioinsumosApp extends StatelessWidget {
  const PortalBioinsumosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Bioinsumos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        // Definindo as cores da marca no tema
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15803D), // Verde Bio
          primary: const Color(0xFF15803D),
          secondary: const Color(0xFF0C1A2A), // Azul Escuro
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C1A2A),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomePageMobile(),
    );
  }
}



  

