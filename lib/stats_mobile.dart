import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/stats_service.dart';

class StatCardMobile extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final MaterialColor color;

  const StatCardMobile({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material( // Material widget para permitir o InkWell
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color.shade700, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatsMobile extends StatelessWidget {
  const StatsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos o serviço
    final statsService = StatsService();

    return FutureBuilder<Map<String, int>>(
      future: statsService.loadStats(), // Chama a função que lê os JSONs
      builder: (context, snapshot) {
        
        // 1. Estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Estado de Erro
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar dados"));
        }

        // 3. Estado de Sucesso (Dados prontos)
        final data = snapshot.data ?? {'totalBioinsumos': 0, 'totalInoculantes': 0};

        return Column(
          children: [
            StatCardMobile(
              value: data['totalBioinsumos'].toString(), // Usa o dado real
              title: "Biodefensivos e Controle",
              icon: Icons.bug_report_outlined,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            StatCardMobile(
              value: data['totalInoculantes'].toString(), // Usa o dado real
              title: "Bioestimulantes e Inoculantes",
              icon: Icons.spa_outlined,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}