import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bioinsumo_model.dart';

class BioinsumoCard extends StatelessWidget {
  final BioinsumoDisplay bio;
  final VoidCallback onToggle;

  // Cores do seu SCSS
  static const primaryBrand = Color(0xFF091C2B);
  static const themeColor = Color(0xFF0D6EFD);
  static const themeLight = Color(0xFFE7F1FF); // Aproximado do rgba
  static const organicColor = Color(0xFF198754);
  static const organicBg = Color(0xFFD1E7DD);
  static const toxicText = Color(0xFF842029);
  static const toxicBg = Color(0xFFF8D7DA);
  static const envText = Color(0xFF0F5132);
  static const envBg = Color(0xFFD1E7DD);
  static const textMuted = Color(0xFF6C757D);

  const BioinsumoCard({super.key, required this.bio, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final api = bio.originalData;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          if (bio.expandido)
             BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Borda colorida esquerda (SCSS: border-left-color on hover/expanded)
              Container(
                width: 5,
                color: bio.expandido ? themeColor : Colors.transparent,
              ),
              Expanded(
                child: Column(
                  children: [
                    // --- HEADER DO CARD (Clicável) ---
                    InkWell(
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges Topo
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                ...bio.categorias.map((c) => _buildBadge(c, themeLight, themeColor)),
                                if (api.produtoOrganico == true)
                                  _buildBadge('Orgânico', organicBg, organicColor, icon: Icons.eco),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Título e Ícone
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bio.nome,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryBrand,
                                        ),
                                      ),
                                      if (api.titularRegistro != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.business, size: 14, color: textMuted),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  api.titularRegistro!,
                                                  style: const TextStyle(color: textMuted, fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  bio.expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: bio.expandido ? themeColor : Colors.grey[300],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- DETALHES EXPANDIDOS ---
                    if (bio.expandido)
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFFAFBFC), // bg-light do SCSS
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Box Destaque (Indicações)
                            if (bio.cultura != 'Não especificada' || bio.alvo != 'Não especificado')
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRichText('Culturas:', bio.cultura),
                                    const SizedBox(height: 8),
                                    _buildRichText('Alvo Biológico:', bio.alvo),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: 16),

                            // Ingredientes
                            if (api.ingredientes != null && api.ingredientes!.isNotEmpty) ...[
                              _buildLabel('Ingredientes Ativos'),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: api.ingredientes!.map((ing) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: primaryBrand, fontSize: 12),
                                        children: [
                                          TextSpan(text: ing.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          if (ing.concentracao != null)
                                            TextSpan(text: '  ${ing.concentracao} ${ing.unidade ?? ""}', style: const TextStyle(color: textMuted)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Classificação de Risco (Badges grandes)
                            _buildLabel('Classificação de Risco'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (api.classificacaoToxicologica != null)
                                  _buildRiskTag('Toxicidade:', api.classificacaoToxicologica!, toxicBg, toxicText, Icons.warning_amber_rounded),
                                if (api.classificacaoAmbiental != null)
                                  _buildRiskTag('Ambiental:', api.classificacaoAmbiental!, envBg, envText, Icons.eco_outlined),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Dados Registro
                            _buildLabel('Dados de Registro'),
                            _buildListText('Reg. MAPA:', api.numeroRegistro),
                            if (api.modoAcao != null) _buildListText('Modo de Ação:', api.modoAcao!.join(", ")),
                            
                            const SizedBox(height: 20),
                            
                            // Botão Agrofit
                            if (api.urlAgrofit != null)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Consultar Ficha no Agrofit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () => launchUrl(Uri.parse(api.urlAgrofit!), mode: LaunchMode.externalApplication),
                                ),
                              ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers Visuais ---

  Widget _buildBadge(String text, Color bg, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFADB5BD)));
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF343A40), fontSize: 14, height: 1.4),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildListText(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF343A40), fontSize: 13),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTag(String label, String value, Color bg, Color text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: bg.withOpacity(0.5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: text, fontSize: 12),
                children: [
                  TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}