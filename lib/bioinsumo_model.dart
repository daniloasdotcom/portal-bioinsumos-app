import 'package:flutter/material.dart';

class ApiBioinsumo {
  final List<String>? marcaComercial;
  final List<String>? categorias;
  final String? titularRegistro;
  final String? numeroRegistro;
  final bool? produtoOrganico;
  final String? classificacaoToxicologica;
  final String? classificacaoAmbiental;
  final String? urlAgrofit;
  final List<String>? modoAcao;
  final bool? inflamavel;
  final List<ApiIndicacao>? indicacoes;
  final List<ApiIngrediente>? ingredientes;

  ApiBioinsumo({
    this.marcaComercial,
    this.categorias,
    this.titularRegistro,
    this.numeroRegistro,
    this.produtoOrganico,
    this.classificacaoToxicologica,
    this.classificacaoAmbiental,
    this.urlAgrofit,
    this.modoAcao,
    this.inflamavel,
    this.indicacoes,
    this.ingredientes,
  });

  factory ApiBioinsumo.fromJson(Map<String, dynamic> json) {
    return ApiBioinsumo(
      marcaComercial: (json['marca_comercial'] as List?)?.cast<String>(),
      categorias: (json['classe_categoria_agronomica'] as List?)?.cast<String>(),
      titularRegistro: json['titular_registro'],
      numeroRegistro: json['numero_registro'],
      produtoOrganico: json['produto_agricultura_organica'] == true,
      classificacaoToxicologica: json['classificacao_toxicologica'],
      classificacaoAmbiental: json['classificacao_ambiental'],
      urlAgrofit: json['url_agrofit'],
      modoAcao: (json['modo_acao'] as List?)?.cast<String>(),
      inflamavel: json['inflamavel'] == true,
      indicacoes: (json['indicacao_uso'] as List?)
          ?.map((x) => ApiIndicacao.fromJson(x))
          .toList(),
      ingredientes: (json['ingrediente_ativo_detalhado'] as List?)
          ?.map((x) => ApiIngrediente.fromJson(x))
          .toList(),
    );
  }
}

class ApiIndicacao {
  final String? cultura;
  final String? pragaNomeCientifico;
  final List<String> pragaNomeComum;

  ApiIndicacao({
    this.cultura,
    this.pragaNomeCientifico,
    required this.pragaNomeComum,
  });

  factory ApiIndicacao.fromJson(Map<String, dynamic> json) {
    // Lógica do TypeScript portada para Dart para normalizar nomes comuns
    List<String> comuns = [];
    if (json['praga_nome_comum'] is List) {
      comuns = (json['praga_nome_comum'] as List).cast<String>();
    } else if (json['praga_nome_comum'] is String) {
      comuns = [json['praga_nome_comum']];
    }

    return ApiIndicacao(
      cultura: json['cultura'],
      pragaNomeCientifico: json['praga_nome_cientifico'],
      pragaNomeComum: comuns,
    );
  }
}

class ApiIngrediente {
  final String nome;
  final String? concentracao;
  final String? unidade;

  ApiIngrediente({required this.nome, this.concentracao, this.unidade});

  factory ApiIngrediente.fromJson(Map<String, dynamic> json) {
    return ApiIngrediente(
      nome: json['ingrediente_ativo'] ?? '',
      concentracao: json['concentracao'],
      unidade: json['unidade_medida'],
    );
  }
}

class BioinsumoDisplay {
  final String nome;
  final List<String> categorias;
  final String cultura;
  final String alvo;
  final ApiBioinsumo originalData;
  bool expandido;

  BioinsumoDisplay({
    required this.nome,
    required this.categorias,
    required this.cultura,
    required this.alvo,
    required this.originalData,
    this.expandido = false,
  });
}