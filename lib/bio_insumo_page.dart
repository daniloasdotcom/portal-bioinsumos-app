import 'package:flutter/material.dart';
import 'bio_model.dart'; // Certifique-se de ter criado este arquivo conforme conversamos

class BioInsumoPage extends StatefulWidget {
  final List<BioInsumoItem> dados;

  const BioInsumoPage({Key? key, required this.dados}) : super(key: key);

  @override
  State<BioInsumoPage> createState() => _BioInsumoPageState();
}

class _BioInsumoPageState extends State<BioInsumoPage> {
  // Variáveis de Estado
  List<String> culturasDisponiveis = [];
  String? culturaSelecionada;
  List<GraficoConfig> listaGraficos = [];

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  // Equivalente ao ngOnChanges
  void _inicializarDados() {
    if (widget.dados.isNotEmpty) {
      _extrairCulturas();
      // Seleciona a primeira cultura automaticamente
      if (culturasDisponiveis.isNotEmpty) {
        culturaSelecionada = culturasDisponiveis[0];
        _gerarGraficos();
      }
    }
  }

  // Extrai lista única de culturas e ordena
  void _extrairCulturas() {
    final setCulturas = <String>{};
    for (var item in widget.dados) {
      if (item.cultura.isNotEmpty) {
        setCulturas.add(item.cultura.trim().toUpperCase());
      }
    }
    setState(() {
      culturasDisponiveis = setCulturas.toList()..sort();
    });
  }

  // Listener do Dropdown
  void _onCulturaChanged(String? novaCultura) {
    if (novaCultura != null) {
      setState(() {
        culturaSelecionada = novaCultura;
        _gerarGraficos();
      });
    }
  }

  // Lógica principal de processamento dos dados
  void _gerarGraficos() {
    if (culturaSelecionada == null) return;

    // 1. Filtra dados pela cultura selecionada
    final dadosCultura = widget.dados
        .where(
          (item) => item.cultura.trim().toUpperCase() == culturaSelecionada,
        )
        .toList();

    if (dadosCultura.isEmpty) {
      setState(() => listaGraficos = []);
      return;
    }

    // 2. Agrupa por TIPO (ex: Fixadora, Promotora)
    final mapaTipos = <String, List<BioInsumoItem>>{};
    for (var item in dadosCultura) {
      final tipo = (item.tipo != null && item.tipo!.isNotEmpty)
          ? item.tipo!.trim()
          : 'OUTROS';

      if (!mapaTipos.containsKey(tipo)) {
        mapaTipos[tipo] = [];
      }
      mapaTipos[tipo]!.add(item);
    }

    // 3. Gera Configuração visual para cada grupo
    final novaLista = <GraficoConfig>[];
    mapaTipos.forEach((nomeTipo, itens) {
      novaLista.add(_criarConfigGrafico(nomeTipo, itens));
    });

    // Ordenação Opcional (Alfabética por título do gráfico)
    novaLista.sort((a, b) => a.titulo.compareTo(b.titulo));

    setState(() {
      listaGraficos = novaLista;
    });
  }

  // Conta espécies e prepara dados para as barras
  GraficoConfig _criarConfigGrafico(String titulo, List<BioInsumoItem> itens) {
    final contagem = <String, int>{};

    for (var item in itens) {
      // Normaliza espécie para lista (caso venha string única ou array do JSON)
      List<String> especiesLista = [];
      if (item.especie is List) {
        especiesLista = List<String>.from(item.especie);
      } else if (item.especie is String) {
        especiesLista = [item.especie];
      }

      for (var esp in especiesLista) {
        if (esp.isNotEmpty) {
          final nome = esp.toUpperCase().trim();
          contagem[nome] = (contagem[nome] ?? 0) + 1;
        }
      }
    }

    // Ordena do maior para o menor
    final sortedEntries = contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Soma total do grupo
    final totalDesteTipo = sortedEntries.fold(0, (sum, e) => sum + e.value);

    // Pega o valor máximo para calcular a % da barra (escala relativa)
    final maxValue = sortedEntries.isNotEmpty ? sortedEntries.first.value : 1;

    return GraficoConfig(
      titulo: titulo,
      total: totalDesteTipo,
      cor: _getCorPorTipo(titulo),
      dados: sortedEntries
          .map((e) => BarData(label: e.key, value: e.value))
          .toList(),
      maxValue: maxValue,
    );
  }

  // Definição de cores (igual ao seu SCSS/TS)
  Color _getCorPorTipo(String tipo) {
    final t = tipo.toUpperCase();
    if (t.contains('NITROGÊNIO')) return const Color(0xFF2E7D32); // Verde
    if (t.contains('CRESCIMENTO')) return const Color(0xFFF9A825); // Ouro
    if (t.contains('ASSOCIATIVAS')) return const Color(0xFF0277BD); // Azul
    return const Color(0xFF78909C); // Cinza
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("BioInsumos Mobile"),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- CARD PRINCIPAL ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do Card
                  const Text(
                    "Total de Bioestimulantes e Inoculantes por Cultura",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select (Dropdown)
                  DropdownButtonFormField<String>(
                    value: culturaSelecionada,
                    decoration: InputDecoration(
                      labelText: "Selecione a Cultura",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: culturasDisponiveis
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: _onCulturaChanged,
                  ),

                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),

                  // Lista de Gráficos
                  if (listaGraficos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          "Nenhum dado disponível.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ...listaGraficos.map((config) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildChartSection(config),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que constrói visualmente o gráfico de barras
  Widget _buildChartSection(GraficoConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da Seção (Com detalhe verde na esquerda)
        Container(
          padding: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFF78C655), width: 4),
            ),
          ),
          child: Text(
            "${config.titulo} (Total: ${config.total})",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Barras
        ...config.dados.map((d) {
          final double percentage = d.value / config.maxValue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome da Espécie
                Text(
                  d.label,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Barra e Valor
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Stack(
                        children: [
                          // Fundo cinza (trilho)
                          Container(
                            height: 20,
                            color: Colors.grey[100],
                            width: double.infinity,
                          ),
                          // Barra colorida proporcional
                          // Barra que cresce da esquerda para a direita (efeito suave)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: percentage,
                            ), // Começa do 0 até o valor real
                            duration: const Duration(
                              milliseconds: 1000,
                            ), // Demora 1 segundo
                            curve: Curves
                                .easeOutQuart, // Desacelera suavemente no final
                            builder: (context, valorAnimado, child) {
                              return FractionallySizedBox(
                                widthFactor: valorAnimado,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: config.cor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Valor Numérico
                    SizedBox(
                      width: 40,
                      child: Text(
                        d.value.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        const Divider(color: Color(0xFFE0E0E0)),
      ],
    );
  }
}

// --- CLASSES AUXILIARES DE UI ---
// Estas classes são usadas apenas internamente para a lógica visual desta página,
// por isso podem permanecer aqui.

class GraficoConfig {
  final String titulo;
  final int total;
  final Color cor;
  final List<BarData> dados;
  final int maxValue;

  GraficoConfig({
    required this.titulo,
    required this.total,
    required this.cor,
    required this.dados,
    required this.maxValue,
  });
}

class BarData {
  final String label;
  final int value;

  BarData({required this.label, required this.value});
}
