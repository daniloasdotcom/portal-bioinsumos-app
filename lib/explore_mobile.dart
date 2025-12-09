import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/catalogos_page.dart';

class ExploreMobile extends StatelessWidget {
  const ExploreMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "O que você procura?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        _ExploreCard(
          title: "Catálogo Completo",
          description:
              "Busque por produtos, pragas-alvo e culturas específicas.",
          action: "Acessar Catálogo",
          icon: Icons.search,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatalogosPage()),
            );
          },
        ),

        const SizedBox(height: 14),
        const _ExploreCard(
          title: "Dashboards & Gráficos",
          description:
              "Visualize distribuição por categoria, ingredientes e espécies.",
          action: "Ver Dashboards",
          icon: Icons.pie_chart_outline,
        ),
        const SizedBox(height: 14),
        const _ExploreCard(
          title: "Legislação",
          description:
              "Leis, decretos e normas atualizadas que regulamentam o setor.",
          action: "Consultar Normas",
          icon: Icons.article_outlined,
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final String description;
  final String action;
  final IconData icon;
  final VoidCallback? onTap;

  const _ExploreCard({
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF1F2937),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      action,
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF15803D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
