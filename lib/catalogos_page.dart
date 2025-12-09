import 'package:flutter/material.dart';

class CatalogosPage extends StatelessWidget {
  const CatalogosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Insumos"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            // -------- TÍTULO E SUBTÍTULO ----------
            //
            const Text(
              "Catálogo de Insumos",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Selecione a categoria ou utilize a ferramenta de diagnóstico.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),

            //
            // -------- CARDS ----------
            //
            _CatalogoCard(
              title: "Biodefensivos",
              description:
                  "Soluções para proteção de cultivos. Inclui fungicidas, inseticidas e agentes de controle biológico.",
              buttonLabel: "Listar Biodefensivos",
              buttonColor: const Color(0xFF0C1A2A),
              icon: Icons.bug_report,
              iconColor: Colors.orange,
              onTap: () {
                // ação
              },
            ),
            const SizedBox(height: 16),

            _CatalogoCard(
              title: "Bioestimulantes",
              description:
                  "Tecnologias para nutrição e fisiologia. Inclui fixadores de nitrogênio e promotores de crescimento.",
              buttonLabel: "Listar Bioestimulantes",
              buttonColor: const Color(0xFF15803D),
              icon: Icons.spa,
              iconColor: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            _CatalogoCard(
              title: "Busca Guiada",
              description:
                  "Não sabe qual produto usar? Filtre passo a passo por cultura e praga para encontrar a solução ideal.",
              buttonLabel: "Iniciar Diagnóstico",
              buttonColor: const Color(0xFF7C3AED),
              icon: Icons.psychology_alt_outlined,
              iconColor: Colors.purple,
              onTap: () {},
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

//
// ----------------------- CARD COMPONENT -----------------------
//

class _CatalogoCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CatalogoCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            // ÍCONE SUPERIOR
            //
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),

            const SizedBox(height: 18),

            //
            // TÍTULO
            //
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 6),

            //
            // DESCRIÇÃO
            //
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 18),

            //
            // BOTÃO
            //
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
