import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/hero_mobile.dart';
import 'package:portal_bioinsumos_app/stats_mobile.dart';
import 'package:portal_bioinsumos_app/explore_mobile.dart';
import 'package:portal_bioinsumos_app/footer_mobile.dart';


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
            _buildDrawerItem(Icons.home, "Home", true),
            _buildDrawerItem(Icons.list_alt, "Catálogo", false),
            _buildDrawerItem(Icons.bar_chart, "Dashboards", false),
            _buildDrawerItem(Icons.gavel, "Legislação", false),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(), // Scroll mais natural
        child: Column(
          children: const [
            HeroMobile(),
            SizedBox(height: 24),
            StatsMobile(),
            SizedBox(height: 24),
            ExploreMobile(),
            SizedBox(height: 32),
            FooterMobile(),
            SizedBox(height: 16), // Espaço extra para safe area
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected) {
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
      onTap: () {},
    );
  }
}
