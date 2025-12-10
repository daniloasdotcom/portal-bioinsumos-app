import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegislationPage extends StatelessWidget {
  const LegislationPage({super.key});

  // Definição de Cores baseadas no estilo CSS/Imagem
  static const Color primaryColor = Color(0xFF0D47A1); // Azul escuro dos títulos
  static const Color secondaryColor = Color(0xFF00B0FF); // Azul claro do sublinhado
  static const Color cardBackgroundColor = Colors.white;
  static const Color disclaimerBgColor = Color(0xFFFFF3CD);
  static const Color disclaimerTextColor = Color(0xFF664D03);
  static const Color disclaimerBorderColor = Color(0xFFFFECB5);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Bioinsumos'),
        backgroundColor: const Color(0xFF111827), // Cor escura do header da imagem
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF9FAFB), // Fundo cinza bem claro
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cabeçalho da Página ---
            const Text(
              'Legislação sobre Bioinsumos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consulte as principais leis, decretos, portarias e instruções normativas relacionadas aos bioinsumos no Brasil.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // --- Seção: Leis Federais ---
            _buildSectionHeader('Leis Federais'),
            ..._leisFederais.map((item) => _buildDocumentCard(item)),

            const SizedBox(height: 32),

            // --- Seção: Decretos Federais ---
            _buildSectionHeader('Decretos Federais'),
            ..._decretosFederais.map((item) => _buildDocumentCard(item)),

            const SizedBox(height: 32),

            // --- Seção: Instruções Normativas ---
            _buildSectionHeader('Instruções Normativas e Portarias (MAPA)'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'O Ministério da Agricultura e Pecuária (MAPA) publica diversas instruções normativas (INs) e portarias relacionadas aos bioinsumos. Abaixo, destacam-se algumas das mais relevantes:',
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
            ..._instrucoesNormativas.map((item) => _buildDocumentCard(item)),

            const SizedBox(height: 32),

            // --- Disclaimer (Aviso) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: disclaimerBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: disclaimerBorderColor),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atenção:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: disclaimerTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'As informações aqui apresentadas são para fins de consulta e podem não refletir a versão mais recente ou todas as alterações da legislação. Recomenda-se sempre verificar as fontes oficiais através dos links.',
                    style: TextStyle(
                      fontSize: 13,
                      color: disclaimerTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // O sublinhado azul ciano
          Container(
            height: 3,
            width: 60,
            color: secondaryColor,
          )
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem item) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _launchURL(item.url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor, // Usando a cor de destaque para o link
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dados (Simulando o conteúdo do HTML) ---

  static final List<DocumentItem> _leisFederais = [
    DocumentItem(
      title: 'Lei Nº 14.515, de 29 de dezembro de 2022',
      description: 'Institui os programas de autocontrole dos agentes privados regulados pela defesa agropecuária, estabelecendo diretrizes para a produção e uso de bioinsumos.',
      url: 'https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2022/lei/l14515.htm',
    ),
    DocumentItem(
      title: 'Lei Nº 15.070, de 3 de janeiro de 2024',
      description: 'Estabelece o marco regulatório dos bioinsumos no Brasil, reconhecendo-os como uma categoria própria e definindo normas para produção e registro.',
      url: 'https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2024/lei/l15070.htm',
    ),
  ];

  static final List<DocumentItem> _decretosFederais = [
    DocumentItem(
      title: 'Decreto Nº 10.375, de 26 de maio de 2020',
      description: 'Institui o Programa Nacional de Bioinsumos e o Conselho Estratégico do Programa Nacional de Bioinsumos.',
      url: 'https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2020/decreto/d10375.htm',
    ),
    DocumentItem(
      title: 'Decreto Nº 4.074, de 4 de janeiro de 2002',
      description: 'Regulamenta a Lei nº 7.802/1989 (Lei dos Agrotóxicos), estabelecendo normas para o registro, produção, comercialização e uso de agrotóxicos e afins.',
      url: 'https://www.planalto.gov.br/ccivil_03/decreto/2002/d4074.htm',
    ),
  ];

  static final List<DocumentItem> _instrucoesNormativas = [
    DocumentItem(
      title: 'Instrução Normativa Conjunta SDA/SDC/ANVISA/IBAMA Nº 1, de 2011',
      description: 'Estabelece os procedimentos para o registro de produtos fitossanitários com uso aprovado para a agricultura orgânica.',
      url: 'https://www.gov.br/agricultura/pt-br/assuntos/sustentabilidade/organicos/legislacao/portugues/instrucao-normativa-conjunta-sda-sdc-anvisa-ibama-no-01-de-24-de-maio-de-2011.pdf/view',
    ),
    DocumentItem(
      title: 'Especificações de Referência para Produtos Fitossanitários',
      description: 'Lista as especificações de referência para diversos bioinsumos aprovados para uso na agricultura orgânica, como Trichoderma spp. e Bacillus spp.',
      url: 'https://www.gov.br/agricultura/pt-br/assuntos/insumos-agropecuarios/insumos-agricolas/agrotoxicos/produtos-fitossanitarios/especificacao-de-referencia',
    ),
  ];
}

// Modelo de Dados Simples
class DocumentItem {
  final String title;
  final String description;
  final String url;

  DocumentItem({
    required this.title,
    required this.description,
    required this.url,
  });
}