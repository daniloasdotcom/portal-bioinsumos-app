import 'package:flutter/material.dart';
import 'bioinsumo_controller.dart';
import 'bioinsumo_card.dart';

class BioestimulantePage extends StatefulWidget {
  const BioestimulantePage({super.key});

  @override
  State<BioestimulantePage> createState() => _BioestimulantePageState();
}

class _BioestimulantePageState extends State<BioestimulantePage> {
  final controller = BioinsumoController();

  @override
  void initState() {
    super.initState();
    controller.carregarDados();
  }

  // --- MODAL DE FILTROS ---
  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                // Header Modal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filtrar Produtos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BioinsumoCard.primaryBrand)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Form
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Busca Geral
                      _buildFilterLabel('Busca Geral'),
                      TextField(
                        controller: TextEditingController(text: controller.termoBusca),
                        decoration: InputDecoration(
                          hintText: 'Nome, alvo, cultura...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        onChanged: (v) => controller.termoBusca = v, // Só atualiza var, aplica no botão
                      ),
                      const SizedBox(height: 20),

                      // Categoria
                      _buildFilterLabel('Categoria'),
                      DropdownButtonFormField<String>(
                        value: controller.filtroCategoria,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas as Categorias')),
                          ...controller.categoriasUnicas.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setModalState(() => controller.filtroCategoria = v),
                      ),
                      const SizedBox(height: 20),

                      // Praga Científica
                      _buildFilterLabel('Praga (Científico)'),
                      DropdownButtonFormField<String>(
                        value: controller.filtroPragaCientifica,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os Nomes Científicos')),
                          ...controller.pragasCientificasUnicas.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setModalState(() => controller.filtroPragaCientifica = v),
                      ),
                      const SizedBox(height: 20),

                      // Praga Comum
                      _buildFilterLabel('Praga (Nome Comum)'),
                      DropdownButtonFormField<String>(
                        value: controller.filtroPragaComum,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os Nomes Comuns')),
                          ...controller.pragasComunsUnicas.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setModalState(() => controller.filtroPragaComum = v),
                      ),
                      const SizedBox(height: 20),

                      // Checkbox Orgânico (Estilizado)
                      InkWell(
                        onTap: () => setModalState(() => controller.filtroApenasOrganicos = !controller.filtroApenasOrganicos),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: controller.filtroApenasOrganicos ? BioinsumoCard.organicColor : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: controller.filtroApenasOrganicos ? BioinsumoCard.organicBg : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.filtroApenasOrganicos ? Icons.check_box : Icons.check_box_outline_blank,
                                color: controller.filtroApenasOrganicos ? BioinsumoCard.organicColor : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              const Text('Apenas Orgânicos', style: TextStyle(fontWeight: FontWeight.bold, color: BioinsumoCard.primaryBrand)),
                              const Spacer(),
                              const Icon(Icons.eco, color: BioinsumoCard.organicColor),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Botões Ação
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.cleaning_services),
                              label: const Text('Limpar'),
                              onPressed: () {
                                controller.limparFiltros();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Aplicar Filtros'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BioinsumoCard.themeColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                controller.onFiltroChange(); // Aplica a lógica
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9), // --bg-page
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catálogo de Biodefensivos', style: TextStyle(color: BioinsumoCard.primaryBrand, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Soluções biológicas Embrapa', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_alt, color: BioinsumoCard.themeColor),
                onPressed: _abrirFiltros,
              ),
            ],
          ),
          body: controller.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Barra de Resultados e Download (Estilo Web)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${controller.filtradosPrincipal.length} produtos', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          if (controller.filtradosPrincipal.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('TXT', style: TextStyle(fontSize: 12)),
                              onPressed: controller.compartilharRelatorioTXT,
                              style: TextButton.styleFrom(foregroundColor: BioinsumoCard.themeColor),
                            )
                        ],
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: controller.paraExibir.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.paraExibir.length,
                              itemBuilder: (_, i) => BioinsumoCard(
                                bio: controller.paraExibir[i],
                                onToggle: () => controller.toggleExpandir(controller.paraExibir[i]),
                              ),
                            ),
                    ),

                    // Paginação (Estilo Web)
                    if (controller.totalPaginasCalculado > 1)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: controller.paginaAtual > 1 ? () => controller.mudarPagina(controller.paginaAtual - 1) : null,
                            ),
                            Text('Página ${controller.paginaAtual} de ${controller.totalPaginasCalculado}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: controller.paginaAtual < controller.totalPaginasCalculado ? () => controller.mudarPagina(controller.paginaAtual + 1) : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pest_control, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Nenhum produto encontrado', style: TextStyle(color: Colors.grey, fontSize: 16)),
          TextButton(onPressed: controller.limparFiltros, child: const Text('Limpar Filtros'))
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    );
  }
}