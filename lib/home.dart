import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/catalogos_page.dart';
import 'package:portal_bioinsumos_app/hero_mobile.dart';
import 'package:portal_bioinsumos_app/stats_mobile.dart';
import 'package:portal_bioinsumos_app/explore_mobile.dart';
import 'package:portal_bioinsumos_app/footer_mobile.dart';

// Importe a página de legislação criada anteriormente
// Certifique-se de que o arquivo legislation_page.dart está na pasta correta
import 'package:portal_bioinsumos_app/legislation_page.dart'; 

class HomePageMobile extends StatelessWidget {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portal Bioinsumos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0C1A2A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.eco, color: Colors.greenAccent, size: 32),
                  SizedBox(height: 12),
                  Text(
                    "Portal Bioinsumos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "v1.0.0",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Item: HOME
            _buildDrawerItem(
              context: context,
              icon: Icons.home,
              title: "Home",
              isSelected: true,
              onTap: () {
                // Já estamos na Home, então apenas fecha o drawer
                Navigator.pop(context);
              },
            ),
            // Item: CATÁLOGO
            _buildDrawerItem(
              context: context,
              icon: Icons.list_alt,
              title: "Catálogo",
              isSelected: false,
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatalogosPage()),
                );
              },
            ),
            // Item: DASHBOARDS
            _buildDrawerItem(
              context: context,
              icon: Icons.bar_chart,
              title: "Dashboards",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPagePlaceholder()),
                );
              },
            ),
            // Item: LEGISLAÇÃO
            _buildDrawerItem(
              context: context,
              icon: Icons.gavel,
              title: "Legislação",
              isSelected: false,
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer primeiro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LegislationPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: const [
            HeroMobile(),
            SizedBox(height: 24),
            StatsMobile(),
            SizedBox(height: 24),
            ExploreMobile(),
            SizedBox(height: 32),
            FooterMobile(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Atualizei o método para receber o 'context' e o 'onTap'
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF15803D) : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF15803D) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap, // Executa a função passada
    );
  }
}

class DashboardPagePlaceholder extends StatelessWidget {
  const DashboardPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboards")),
      body: const Center(child: Text("Página de Dashboards em construção")),
    );
  }
}