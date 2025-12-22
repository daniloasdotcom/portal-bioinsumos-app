import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart'; // Para exportar TXT
import 'bioinsumo_model.dart';

class BioinsumoController extends ChangeNotifier {
  // Dados
  List<BioinsumoDisplay> _todos = [];
  List<BioinsumoDisplay> filtradosPrincipal = []; // Lista pós-filtro
  List<BioinsumoDisplay> paraExibir = []; // Lista paginada

  // Filtros (Model do Angular)
  String termoBusca = '';
  String? filtroCategoria;
  String? filtroPragaCientifica;
  String? filtroPragaComum;
  bool filtroApenasOrganicos = false;

  // Listas para Dropdowns
  List<String> categoriasUnicas = [];
  List<String> pragasCientificasUnicas = [];
  List<String> pragasComunsUnicas = [];

  // Paginação
  int paginaAtual = 1;
  int itensPorPagina = 50;
  int totalPaginasCalculado = 0;

  // Estados
  bool isLoading = true;
  String? erroApi;
  bool primeiraBuscaRealizada = false;
  Timer? _debounce;

  // --- CARREGAMENTO ---
  Future<void> carregarDados() async {
    isLoading = true;
    erroApi = null;
    notifyListeners();

    try {
      final jsonStr = await rootBundle.loadString('assets/todos_bioinsumos.json');
      final List list = json.decode(jsonStr);

      _todos = list.map((e) {
        final api = ApiBioinsumo.fromJson(e);
        return mapearParaDisplay(api);
      }).toList();

      extrairFiltrosUnicos();
      
      // Inicializa exibindo tudo
      aplicarFiltrosEPopularPagina();
    } catch (e) {
      erroApi = 'Falha ao carregar catálogo: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- LÓGICA DE MAPEAR (Portada do TS) ---
  BioinsumoDisplay mapearParaDisplay(ApiBioinsumo api) {
    final nome = (api.marcaComercial?.isNotEmpty ?? false) 
        ? api.marcaComercial!.first 
        : 'Nome Indisponível';
    
    final cats = (api.categorias?.isNotEmpty ?? false)
        ? api.categorias!
        : ['Categoria Indisponível'];

    // Lógica de join culturas
    final culturasSet = <String>{};
    api.indicacoes?.forEach((i) { if(i.cultura != null) culturasSet.add(i.cultura!); });
    final culturaStr = culturasSet.isEmpty ? 'Não especificada' : culturasSet.join(', ');

    // Lógica de join alvos
    final alvosSet = <String>{};
    api.indicacoes?.forEach((i) {
      if(i.pragaNomeCientifico != null) alvosSet.add(i.pragaNomeCientifico!);
      for (var comum in i.pragaNomeComum) {
        alvosSet.add(comum);
      }
    });
    final alvoStr = alvosSet.isEmpty ? 'Não especificado' : alvosSet.join(', ');

    return BioinsumoDisplay(
      nome: nome,
      categorias: cats,
      cultura: culturaStr,
      alvo: alvoStr,
      originalData: api,
    );
  }

  // --- EXTRAÇÃO DE FILTROS (Portada do TS) ---
  void extrairFiltrosUnicos() {
    final catsSet = <String>{};
    final pragasCientSet = <String>{};
    final pragasComumSet = <String>{};

    for (var bio in _todos) {
      for (var c in bio.categorias) {
        if(c != 'Categoria Indisponível') catsSet.add(c);
      }
      if (bio.originalData.indicacoes != null) {
        for (var ind in bio.originalData.indicacoes!) {
          if (ind.pragaNomeCientifico != null) pragasCientSet.add(ind.pragaNomeCientifico!);
          for (var comum in ind.pragaNomeComum) {
            pragasComumSet.add(comum);
          }
        }
      }
    }

    categoriasUnicas = catsSet.toList()..sort();
    pragasCientificasUnicas = pragasCientSet.toList()..sort();
    pragasComunsUnicas = pragasComumSet.toList()..sort();
  }

  // --- FILTRAGEM ---
  void onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      termoBusca = val;
      onFiltroChange();
    });
  }

  void onFiltroChange() {
    primeiraBuscaRealizada = true;
    paginaAtual = 1;
    aplicarFiltrosEPopularPagina();
  }

  void aplicarFiltrosEPopularPagina() {
    final termo = termoBusca.toLowerCase().trim();

    if (termo.isEmpty && 
        filtroCategoria == null && 
        filtroPragaCientifica == null && 
        filtroPragaComum == null && 
        !filtroApenasOrganicos) {
      filtradosPrincipal = List.from(_todos);
    } else {
      filtradosPrincipal = _todos.where((bio) {
        final api = bio.originalData;

        // 1. Busca Geral
        bool matchBusca = true;
        if (termo.isNotEmpty) {
           matchBusca = bio.nome.toLowerCase().contains(termo) ||
              bio.cultura.toLowerCase().contains(termo) ||
              bio.alvo.toLowerCase().contains(termo) ||
              (api.titularRegistro?.toLowerCase().contains(termo) ?? false);
        }

        // 2. Categoria
        bool matchCat = true;
        if (filtroCategoria != null) {
          matchCat = bio.categorias.contains(filtroCategoria);
        }

        // 3. Pragas
        bool matchPCient = true;
        if (filtroPragaCientifica != null) {
          matchPCient = api.indicacoes?.any((i) => i.pragaNomeCientifico == filtroPragaCientifica) ?? false;
        }

        bool matchPComum = true;
        if (filtroPragaComum != null) {
          matchPComum = api.indicacoes?.any((i) => i.pragaNomeComum.contains(filtroPragaComum)) ?? false;
        }

        // 4. Orgânico
        bool matchOrg = true;
        if (filtroApenasOrganicos) {
          matchOrg = api.produtoOrganico == true;
        }

        return matchBusca && matchCat && matchPCient && matchPComum && matchOrg;
      }).toList();
    }

    totalPaginasCalculado = (filtradosPrincipal.length / itensPorPagina).ceil();
    if (totalPaginasCalculado == 0) totalPaginasCalculado = 1;
    atualizarPaginaParaExibicao();
    notifyListeners();
  }

  void atualizarPaginaParaExibicao() {
    final startIndex = (paginaAtual - 1) * itensPorPagina;
    final endIndex = (startIndex + itensPorPagina < filtradosPrincipal.length) 
        ? startIndex + itensPorPagina 
        : filtradosPrincipal.length;
    
    if (startIndex >= filtradosPrincipal.length) {
        paraExibir = [];
    } else {
        paraExibir = filtradosPrincipal.sublist(startIndex, endIndex);
    }
  }

  void mudarPagina(int novaPagina) {
    if (novaPagina >= 1 && novaPagina <= totalPaginasCalculado) {
      paginaAtual = novaPagina;
      atualizarPaginaParaExibicao();
      notifyListeners();
    }
  }

  void limparFiltros() {
    termoBusca = '';
    filtroCategoria = null;
    filtroPragaCientifica = null;
    filtroPragaComum = null;
    filtroApenasOrganicos = false;
    onFiltroChange();
  }

  void toggleExpandir(BioinsumoDisplay item) {
    item.expandido = !item.expandido;
    notifyListeners();
  }

  // --- GERAR RELATÓRIO TXT ---
  Future<void> compartilharRelatorioTXT() async {
    if (filtradosPrincipal.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('Relatório de Produtos Biológicos Filtrados');
    buffer.writeln('Total: ${filtradosPrincipal.length}');
    buffer.writeln('Data: ${DateTime.now().toString()}');
    buffer.writeln('==========================================\n');

    for (int i = 0; i < filtradosPrincipal.length; i++) {
      final bio = filtradosPrincipal[i];
      final api = bio.originalData;
      
      buffer.writeln('Produto ${i+1}: ${bio.nome}');
      buffer.writeln('  Categoria: ${bio.categorias.join(", ")}');
      if (api.numeroRegistro != null) buffer.writeln('  Reg. MAPA: ${api.numeroRegistro}');
      if (api.titularRegistro != null) buffer.writeln('  Empresa: ${api.titularRegistro}');
      buffer.writeln('  Orgânico: ${api.produtoOrganico == true ? "Sim" : "Não"}');
      buffer.writeln('------------------------------------------\n');
    }

    // No mobile usamos share_plus ao invés de baixar arquivo
    await Share.share(buffer.toString(), subject: 'Relatório Bioinsumos');
  }
}