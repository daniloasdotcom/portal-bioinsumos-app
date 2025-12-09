import 'package:flutter/material.dart';
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
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            _HeroMobile(),
            SizedBox(height: 24),
            _StatsMobile(),
            SizedBox(height: 24),
            _ExploreMobile(),
            SizedBox(height: 32),
            _FooterMobile(),
            SizedBox(height: 16), // Espaço extra para safe area
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF15803D) : Colors.grey[700]),
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

//
// ----------------------- HERO -----------------------
//

class _HeroMobile extends StatelessWidget {
  const _HeroMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF14532D)], // Gradiente mais profundo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bem-vindo(a)',
                style: TextStyle(
                  color: Color(0xFFBBF7D0),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Portal de Bioinsumos',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tecnologia e sustentabilidade para impulsionar o agro brasileiro com dados confiáveis.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.explore, size: 18),
                  label: const Text("Explorar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF15803D),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.insights, size: 18),
                  label: const Text("Gráficos"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ----------------------- STATS -----------------------
//

class _StatsMobile extends StatelessWidget {
  const _StatsMobile();

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
            _StatCardMobile(
              value: data['totalBioinsumos'].toString(), // Usa o dado real
              title: "Biodefensivos e Controle",
              icon: Icons.bug_report_outlined,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _StatCardMobile(
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

class _StatCardMobile extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final MaterialColor color;

  const _StatCardMobile({
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

//
// ----------------------- EXPLORE -----------------------
//

//
// ----------------------- EXPLORE -----------------------
//

class _ExploreMobile extends StatelessWidget {
  const _ExploreMobile();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "O que você procura?",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1F2937)
            ),
          ),
        ),
        _ExploreCard(
          title: "Catálogo Completo",
          description: "Busque por produtos, pragas-alvo e culturas específicas.",
          action: "Acessar Catálogo",
          icon: Icons.search,
        ),
        SizedBox(height: 14),
        _ExploreCard(
          title: "Dashboards & Gráficos",
          description: "Visualize distribuição por categoria, ingredientes e espécies.",
          action: "Ver Dashboards",
          icon: Icons.pie_chart_outline,
        ),
        SizedBox(height: 14),
        _ExploreCard(
          title: "Legislação",
          description: "Leis, decretos e normas atualizadas que regulamentam o setor.",
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
  // Removido o campo 'highlight'

  const _ExploreCard({
    super.key,
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Borda sutil em TODOS os cards para delimitar a área clicável
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Ação do clique aqui
            print("Clicou em $title");
          },
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
                      child: Icon(icon, color: const Color(0xFF1F2937), size: 22),
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
                              color: Color(0xFF111827)
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFF6B7280), 
                              height: 1.4, 
                              fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Linha de ação inferior
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Joga a ação para a direita (opcional)
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
                    const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF15803D)),
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

//
// ----------------------- FOOTER -----------------------
//

class _FooterMobile extends StatelessWidget {
  const _FooterMobile();

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