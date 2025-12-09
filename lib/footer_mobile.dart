import 'package:flutter/material.dart';

class FooterMobile extends StatelessWidget {
  const FooterMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 12),
        const Text(
          "© 2025 Portal de Bioinsumos",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        const Text(
          "Desenvolvido por Danilo Andrade Santos",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.black45),
        ),
      ],
    );
  }
}