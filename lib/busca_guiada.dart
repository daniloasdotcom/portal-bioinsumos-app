import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para rootBundle e Clipboard
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==========================================
// 1. MODELOS DE DADOS
// ==========================================

class Bioinsumo {
  final String numeroRegistro;
  final List<String> marcaComercial;
  final String titularRegistro;
  final List<String> classeCategoria;
  final bool produtoOrganico;
  final List<IndicacaoUso> indicacaoUso;
  final List<IngredienteDetalhado> ingredientes;
  final String classificacaoToxicologica;
  final String classificacaoAmbiental;
  final List<Documento> documentos;

  bool expandido;

  Bioinsumo({
    required this.numeroRegistro,
    required this.marcaComercial,
    required this.titularRegistro,
    required this.classeCategoria,
    required this.produtoOrganico,
    required this.indicacaoUso,
    required this.ingredientes,
    required this.classificacaoToxicologica,
    required this.classificacaoAmbiental,
    required this.documentos,
    this.expandido = false,
  });

  String get nomePrincipal =>
      marcaComercial.isNotEmpty ? marcaComercial.first : 'Sem Nome';

  String? get urlAgrofit {
    if (documentos.isEmpty) return null;
    try {
      final doc = documentos.firstWhere(
        (d) =>
            d.tipoDocumento.contains('Bula') ||
            d.tipoDocumento.contains('Rótulo'),
        orElse: () => documentos.first,
      );
      return doc.url;
    } catch (e) {
      return null;
    }
  }

  String get culturasFormatadas {
    final culturas = indicacaoUso.map((e) => e.cultura).toSet().toList();

    if (culturas.isEmpty) return "Geral";
    if (culturas.contains("Todas as culturas")) return "Todas as Culturas";

    return culturas.join(", ");
  }

  String get alvosFormatados {
    final alvos = <String>{};
    for (var uso in indicacaoUso) {
      alvos.addAll(uso.nomesComuns);
      if (uso.nomeCientifico != null) alvos.add(uso.nomeCientifico!);
    }
    return alvos.take(3).join(", ") + (alvos.length > 3 ? "..." : "");
  }

  factory Bioinsumo.fromJson(Map<String, dynamic> json) {
    return Bioinsumo(
      numeroRegistro: json['numero_registro'] ?? '',
      marcaComercial: List<String>.from(json['marca_comercial'] ?? []),
      titularRegistro: json['titular_registro'] ?? '',
      classeCategoria: List<String>.from(
        json['classe_categoria_agronomica'] ?? [],
      ),
      produtoOrganico:
          json['produto_agricultura_organica'] == true ||
          json['produto_biologico'] == true,
      indicacaoUso:
          (json['indicacao_uso'] as List?)
              ?.map((e) => IndicacaoUso.fromJson(e))
              .toList() ??
          [],
      ingredientes:
          (json['ingrediente_ativo_detalhado'] as List?)
              ?.map((e) => IngredienteDetalhado.fromJson(e))
              .toList() ??
          [],
      classificacaoToxicologica:
          json['classificacao_toxicologica'] ?? 'Não inf.',
      classificacaoAmbiental: json['classificacao_ambiental'] ?? 'Não inf.',
      documentos:
          (json['documento_cadastrado'] as List?)
              ?.map((e) => Documento.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class IndicacaoUso {
  final String cultura;
  final String? nomeCientifico;
  final List<String> nomesComuns;

  IndicacaoUso({
    required this.cultura,
    this.nomeCientifico,
    required this.nomesComuns,
  });

  factory IndicacaoUso.fromJson(Map<String, dynamic> json) {
    List<String> comuns = [];
    if (json['praga_nome_comum'] is List) {
      comuns = List<String>.from(json['praga_nome_comum']);
    } else if (json['praga_nome_comum'] is String) {
      comuns = [json['praga_nome_comum']];
    }

    return IndicacaoUso(
      cultura: json['cultura'] ?? 'Todas as culturas',
      nomeCientifico: json['praga_nome_cientifico'],
      nomesComuns: comuns,
    );
  }
}

class IngredienteDetalhado {
  final String nome;
  final String concentracao;
  final String unidade;

  IngredienteDetalhado({
    required this.nome,
    required this.concentracao,
    required this.unidade,
  });

  factory IngredienteDetalhado.fromJson(Map<String, dynamic> json) {
    return IngredienteDetalhado(
      nome: json['ingrediente_ativo'] ?? '',
      concentracao: json['concentracao'] ?? '',
      unidade: json['unidade_medida'] ?? '',
    );
  }
}

class Documento {
  final String tipoDocumento;
  final String url;

  Documento({required this.tipoDocumento, required this.url});

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      tipoDocumento: json['tipo_documento'] ?? 'Documento',
      url: json['url'] ?? '',
    );
  }
}

class PragaDisplay {
  final String nome;
  final String cientifico;
  PragaDisplay(this.nome, this.cientifico);
}

// ==========================================
// 2. PÁGINA PRINCIPAL
// ==========================================

class BioinsumosPage extends StatefulWidget {
  const BioinsumosPage({super.key});

  @override
  State<BioinsumosPage> createState() => _BioinsumosPageState();
}

class _BioinsumosPageState extends State<BioinsumosPage> {
  // Cores
  final Color colRoxo = const Color(0xFF6610f2);
  final Color colRoxoClaro = const Color(0xFF6610f2).withOpacity(0.1);
  final Color colVerde = const Color(0xFF198754);
  final Color colTexto = const Color(0xFF343a40);
  final Color colCinza = const Color(0xFF6c757d);

  // Dados e Estado
  List<Bioinsumo> todosProdutos = [];
  List<String> culturasDisponiveis = [];
  bool isLoading = true;
  int passoAtual = 1;
  String textoBusca = "";

  // Seleções
  String culturaSelecionada = "";
  String pragaSelecionada = "";
  List<PragaDisplay> pragasEspecificas = [];
  List<PragaDisplay> pragasGerais = [];
  List<Bioinsumo> produtosResultadosEspecificos = [];
  List<Bioinsumo> produtosResultadosGerais = [];

  // Controle de UI
  bool showEspecificos = true;
  bool showGerais = false;

  // NOVO: Controlador de Scroll e estado do botão topo
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    carregarDadosJson();

    // NOVO: Listener para mostrar/ocultar botão de topo
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 300 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Importante limpar o controlador
    super.dispose();
  }

  Future<void> carregarDadosJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/todos_bioinsumos.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        todosProdutos = data.map((json) => Bioinsumo.fromJson(json)).toList();
        _extrairCulturas();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar JSON: $e");
      setState(() => isLoading = false);
    }
  }

  void _extrairCulturas() {
    final Set<String> temp = {};
    for (var p in todosProdutos) {
      for (var uso in p.indicacaoUso) {
        if (uso.cultura.toLowerCase() != 'todas as culturas' &&
            uso.cultura.isNotEmpty) {
          temp.add(uso.cultura);
        }
      }
    }
    culturasDisponiveis = temp.toList()..sort();
  }

  void _escolherCultura(String cultura) {
    setState(() {
      culturaSelecionada = cultura;
      passoAtual = 2;
      textoBusca = "";
      _processarPragasDaCultura(cultura);
      showEspecificos = true;
      showGerais = false;
    });
    // Reseta scroll ao mudar de passo
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _processarPragasDaCultura(String culturaAlvo) {
    final Map<String, String> mapEsp = {};
    final Map<String, String> mapGer = {};
    final culturaNorm = culturaAlvo.toLowerCase().trim();

    for (var p in todosProdutos) {
      for (var uso in p.indicacaoUso) {
        final culturaUso = uso.cultura.toLowerCase().trim();
        final bool ehEsp = culturaUso == culturaNorm;
        final bool ehGer = culturaUso == 'todas as culturas';

        if (ehEsp || ehGer) {
          for (var nomePraga in uso.nomesComuns) {
            final cientifico = uso.nomeCientifico ?? '';
            if (ehEsp)
              mapEsp[nomePraga] = cientifico;
            else
              mapGer[nomePraga] = cientifico;
          }
        }
      }
    }
    pragasEspecificas =
        mapEsp.entries.map((e) => PragaDisplay(e.key, e.value)).toList()
          ..sort((a, b) => a.nome.compareTo(b.nome));
    pragasGerais =
        mapGer.entries.map((e) => PragaDisplay(e.key, e.value)).toList()
          ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  void _escolherPraga(String praga) {
    setState(() {
      pragaSelecionada = praga;
      passoAtual = 3;
      _filtrarResultadosFinais();
    });
    // Reseta scroll ao mudar de passo
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _filtrarResultadosFinais() {
    produtosResultadosEspecificos = [];
    produtosResultadosGerais = [];
    final culturaNorm = culturaSelecionada.toLowerCase().trim();

    for (var p in todosProdutos) {
      bool ehEspecifico = false;
      bool ehGeral = false;
      for (var uso in p.indicacaoUso) {
        if (uso.nomesComuns.contains(pragaSelecionada)) {
          final c = uso.cultura.toLowerCase().trim();
          if (c == culturaNorm) ehEspecifico = true;
          if (c == 'todas as culturas') ehGeral = true;
        }
      }
      if (ehEspecifico)
        produtosResultadosEspecificos.add(p);
      else if (ehGeral)
        produtosResultadosGerais.add(p);
    }
  }

  void _navegarVoltar() {
    if (passoAtual > 1) {
      setState(() {
        passoAtual--;
        textoBusca = "";
      });
      // Reseta scroll ao voltar
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _reiniciar() {
    setState(() {
      passoAtual = 1;
      culturaSelecionada = "";
      pragaSelecionada = "";
      textoBusca = "";
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  // NOVO: Função para rolar ao topo
  void _rolarParaTopo() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // ==========================================
  // 3. UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navegarVoltar();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          // AppBar sem cor de fundo explícita (usa default/surface)
          appBar: AppBar(
            title: const Text(
              "Assistente de Bioinsumos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            foregroundColor: colTexto,

            scrolledUnderElevation: 0,
            elevation: 0,
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _navegarVoltar,
            ),
          ),

          // NOVO: Botão Flutuante Condicional
          floatingActionButton: _showBackToTop
              ? FloatingActionButton(
                  onPressed: _rolarParaTopo,
                  backgroundColor: colRoxo,
                  mini: true, // Tamanho menor e mais discreto
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                )
              : null,

          body: isLoading
              ? Center(child: CircularProgressIndicator(color: colRoxo))
              : Column(
                  children: [
                    _buildStepper(),
                    Expanded(
                      child: ListView(
                        controller:
                            _scrollController, // NOVO: Attach Controller
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (passoAtual == 1) _buildPasso1Cultura(),
                          if (passoAtual == 2) _buildPasso2Praga(),
                          if (passoAtual == 3) _buildPasso3Resultados(),
                          const SizedBox(
                            height: 60,
                          ), // Espaço extra para o FAB não cobrir conteúdo
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltarInternal() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextButton.icon(
          onPressed: _navegarVoltar,
          icon: Icon(Icons.arrow_back, size: 16, color: colCinza),
          label: Text(
            "Voltar",
            style: TextStyle(color: colCinza, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  // --- STEPPER ---
  Widget _buildStepper() {
    return Container(
      width: double.infinity,
      color: Colors.white, // Mantido branco para consistência do header
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem(1, "Cultura"),
          _buildStepLine(1),
          _buildStepItem(2, "Praga/Doença"),
          _buildStepLine(2),
          _buildStepItem(3, "Soluções"),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label) {
    bool isActive = passoAtual >= step;
    bool isCompleted = passoAtual > step;
    Color bg = isActive
        ? (isCompleted ? colVerde : colRoxo)
        : Colors.grey[200]!;
    Color txt = isActive ? Colors.white : Colors.grey[600]!;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 35,
          height: 35,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            "$step",
            style: TextStyle(color: txt, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? (isCompleted ? colVerde : colRoxo) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepAfter) {
    return Container(
      width: 40,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      color: passoAtual > stepAfter ? colVerde : Colors.grey[200],
    );
  }

  // --- PASSO 1 ---
  Widget _buildPasso1Cultura() {
    final filtradas = culturasDisponiveis
        .where((c) => c.toLowerCase().contains(textoBusca.toLowerCase()))
        .toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 32 - 15) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "O que você vai cultivar?",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colTexto,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildSearchInput("Ex: Soja, Milho, Tomate..."),
        const SizedBox(height: 20),

        if (filtradas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Nenhuma cultura encontrada.",
              textAlign: TextAlign.center,
            ),
          ),

        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: filtradas
              .map(
                (c) => InkWell(
                  onTap: () => _escolherCultura(c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: cardWidth,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.seedling,
                          size: 30,
                          color: colVerde,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            c,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colTexto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // --- PASSO 2 ---
  Widget _buildPasso2Praga() {
    final espFilt = pragasEspecificas
        .where((p) => p.nome.toLowerCase().contains(textoBusca.toLowerCase()))
        .toList();
    final gerFilt = pragasGerais
        .where((p) => p.nome.toLowerCase().contains(textoBusca.toLowerCase()))
        .toList();

    if (textoBusca.isNotEmpty) {
      showEspecificos = true;
      showGerais = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBotaoVoltarInternal(),
        Text(
          "Qual é o alvo ou problema?",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colTexto,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildSearchInput("Filtrar praga..."),
        const SizedBox(height: 20),

        if (espFilt.isNotEmpty)
          _buildAccordion(
            titulo: "Específicos para $culturaSelecionada",
            subtitulo: "Pragas cadastradas para esta cultura",
            icon: FontAwesomeIcons.bullseye,
            cor: colRoxo,
            isOpen: showEspecificos,
            onTapHeader: () =>
                setState(() => showEspecificos = !showEspecificos),
            listaPragas: espFilt,
          ),

        if (espFilt.isNotEmpty) const SizedBox(height: 15),

        if (gerFilt.isNotEmpty)
          _buildAccordion(
            titulo: "Multiculturas",
            subtitulo: "Pragas de produtos para 'Todas as Culturas'",
            icon: FontAwesomeIcons.earthAmericas,
            cor: colVerde,
            isOpen: showGerais,
            onTapHeader: () => setState(() => showGerais = !showGerais),
            listaPragas: gerFilt,
          ),
      ],
    );
  }

  Widget _buildAccordion({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required Color cor,
    required bool isOpen,
    required VoidCallback onTapHeader,
    required List<PragaDisplay> listaPragas,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen ? Colors.grey.shade300 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(isOpen ? 0 : 12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: cor, width: 5)),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(isOpen ? 0 : 12),
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: cor),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colTexto,
                          ),
                        ),
                        Text(
                          subtitulo,
                          style: TextStyle(fontSize: 12, color: colCinza),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colCinza,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: listaPragas
                    .map(
                      (p) => InkWell(
                        onTap: () => _escolherPraga(p.nome),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cor == colVerde
                                ? Colors.grey[50]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nome,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: colTexto,
                                      ),
                                    ),
                                    if (p.cientifico.isNotEmpty)
                                      Text(
                                        p.cientifico,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(icon, color: cor.withOpacity(0.2), size: 24),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // --- PASSO 3 ---
  Widget _buildPasso3Resultados() {
    int total =
        produtosResultadosEspecificos.length + produtosResultadosGerais.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _navegarVoltar,
              icon: Icon(Icons.arrow_back, size: 16, color: colCinza),
              label: Text("Voltar", style: TextStyle(color: colCinza)),
            ),
            TextButton(onPressed: _reiniciar, child: const Text("Nova Busca")),
          ],
        ),

        const SizedBox(height: 10),
        Text(
          "$total Soluções Encontradas",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colTexto,
          ),
        ),
        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(FontAwesomeIcons.fileLines, size: 16),
            label: const Text("Copiar Relatório"),
            onPressed: _copiarRelatorio,
            style: OutlinedButton.styleFrom(
              foregroundColor: colRoxo,
              side: BorderSide(color: colRoxo),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 25),

        if (produtosResultadosEspecificos.isNotEmpty) ...[
          _buildHeaderSecao(
            "Específicos para $culturaSelecionada",
            produtosResultadosEspecificos.length,
            colRoxo,
            FontAwesomeIcons.bullseye,
          ),
          ...produtosResultadosEspecificos.map((p) => _buildCardProduto(p)),
          const Divider(height: 40),
        ],

        if (produtosResultadosGerais.isNotEmpty) ...[
          _buildHeaderSecao(
            "Multiculturas",
            produtosResultadosGerais.length,
            Colors.blueGrey,
            FontAwesomeIcons.earthAmericas,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              "Produtos registrados para este alvo em qualquer cultura.",
              style: TextStyle(color: colCinza, fontSize: 12),
            ),
          ),
          ...produtosResultadosGerais.map((p) => _buildCardProduto(p)),
        ],

        if (total == 0)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(
                  FontAwesomeIcons.magnifyingGlassMinus,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Não encontramos produtos.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSecao(String titulo, int count, Color cor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cor,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colCinza,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardProduto(Bioinsumo p) {
    Color corBorda = p.expandido ? colRoxo : Colors.grey.shade300;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: corBorda, width: 5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => p.expandido = !p.expandido),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(p.expandido ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 5,
                          children: [
                            ...p.classeCategoria
                                .take(2)
                                .map(
                                  (c) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colRoxoClaro,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.toUpperCase(),
                                      style: TextStyle(
                                        color: colRoxo,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            if (p.produtoOrganico)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1E7DD),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      size: 10,
                                      color: Color(0xFF198754),
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      "ORGÂNICO",
                                      style: TextStyle(
                                        color: Color(0xFF198754),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.nomePrincipal,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colTexto,
                          ),
                        ),
                        if (p.titularRegistro.isNotEmpty)
                          Text(
                            p.titularRegistro,
                            style: TextStyle(color: colCinza, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    p.expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: p.expandido ? colRoxo : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (p.expandido)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F3F5))),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailBox(
                    "Indicações Principais",
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: colTexto, fontSize: 14),
                        children: [
                          const TextSpan(
                            text: "Culturas: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "${p.culturasFormatadas}\n"),
                          const TextSpan(
                            text: "Alvo Biológico: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: p.alvosFormatados),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (p.ingredientes.isNotEmpty) ...[
                    Text(
                      "INGREDIENTES ATIVOS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.ingredientes
                          .map(
                            (ing) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${ing.nome} (${ing.concentracao} ${ing.unidade})",
                                style: TextStyle(fontSize: 12, color: colTexto),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 15),
                  ],
                  _buildDetailBox(
                    "Classificação",
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Toxicidade: ${p.classificacaoToxicologica}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ambiental: ${p.classificacaoAmbiental}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (p.urlAgrofit != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _abrirUrl(p.urlAgrofit!),
                        icon: const Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Consultar Ficha / Bula no Agrofit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailBox(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildSearchInput(String hint) {
    return TextField(
      onChanged: (val) => setState(() => textoBusca = val),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colRoxo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
    );
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o link.")),
      );
  }

  void _copiarRelatorio() {
    StringBuffer sb = StringBuffer();
    sb.writeln("RELATÓRIO DE BIOINSUMOS");
    sb.writeln("Cultura: $culturaSelecionada | Praga: $pragaSelecionada");
    sb.writeln("-----------------------------------");
    void addList(String titulo, List<Bioinsumo> lista) {
      if (lista.isEmpty) return;
      sb.writeln("\n>>> $titulo");
      for (var p in lista) {
        sb.writeln("- ${p.nomePrincipal} (${p.numeroRegistro})");
      }
    }

    addList("Específicos", produtosResultadosEspecificos);
    addList("Gerais", produtosResultadosGerais);
    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Relatório copiado!")));
  }
}
