import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'bio_insumo_page.dart'; 
import 'bio_model.dart';

class BioService {
  
  // Método principal para carregar e unificar os dados
  Future<List<BioInsumoItem>> carregarDados() async {
    try {
      // 1. Carrega os arquivos JSON textuais da pasta assets
      final String jsonBio = await rootBundle.loadString('assets/todos_bioinsumos.json');
      final String jsonInoc = await rootBundle.loadString('assets/todos_inoculantes.json');

      // 2. Decodifica para Listas do Dart (List<dynamic>)
      final List<dynamic> listaBio = jsonDecode(jsonBio);
      final List<dynamic> listaInoc = jsonDecode(jsonInoc);

      List<BioInsumoItem> todosItens = [];

      // 3. Mapeia BIOINSUMOS para BioInsumoItem
      // Nota: Ajuste as chaves ['chave'] conforme o nome real no seu JSON
      for (var item in listaBio) {
        todosItens.add(BioInsumoItem(
          cultura: item['cultura'] ?? 'Outros', 
          tipo: _tratarTipo(item['classe_categoria_agronomica']), // Baseado no seu código Angular
          especie: item['ingrediente_ativo'] ?? item['especie'] ?? [], // Tenta achar a espécie ou ingrediente
        ));
      }

      // 4. Mapeia INOCULANTES para BioInsumoItem
      for (var item in listaInoc) {
        todosItens.add(BioInsumoItem(
          cultura: item['cultura'] ?? 'Outros',
          tipo: item['tipo'] ?? 'OUTROS',
          especie: item['especie'] ?? [],
        ));
      }

      return todosItens;

    } catch (e) {
      print("Erro ao carregar JSONs: $e");
      return []; // Retorna lista vazia em caso de erro
    }
  }

  // Pequeno auxiliar para garantir que o tipo seja string
  String? _tratarTipo(dynamic valor) {
    if (valor is List) return valor.isNotEmpty ? valor.first.toString() : null;
    return valor?.toString();
  }
}