import 'dart:convert'; // Para jsonDecode
import 'package:flutter/services.dart'; // Para rootBundle

class StatsService {
  // Retorna um Map com os dados processados
  Future<Map<String, int>> loadStats() async {
    try {
      // 1. Ler os arquivos JSON como String
      final String bioString = await rootBundle.loadString('assets/todos_bioinsumos.json');
      final String inocString = await rootBundle.loadString('assets/todos_inoculantes.json');

      // 2. Converter String para Listas (JSON Decode)
      final List<dynamic> bioList = json.decode(bioString);
      final List<dynamic> inocList = json.decode(inocString);

      // 3. Retornar os totais
      return {
        'totalBioinsumos': bioList.length,
        'totalInoculantes': inocList.length,
      };
    } catch (e) {
      print("Erro ao carregar dados: $e");
      // Retorna zeros em caso de erro para não quebrar o app
      return {
        'totalBioinsumos': 0,
        'totalInoculantes': 0,
      };
    }
  }
}