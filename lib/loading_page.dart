import 'package:flutter/material.dart';
import 'package:portal_bioinsumos_app/bio_model.dart';
import 'bio_insumo_page.dart'; // Sua página de gráficos
import 'bio_service.dart';      // O serviço que criamos acima

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BioInsumoLoader(),
  ));
}

class BioInsumoLoader extends StatefulWidget {
  const BioInsumoLoader({super.key});

  @override
  State<BioInsumoLoader> createState() => _BioInsumoLoaderState();
}

class _BioInsumoLoaderState extends State<BioInsumoLoader> {
  // Instancia o serviço
  final BioService _service = BioService();
  
  // Variável que guardará o futuro (a promessa dos dados)
  late Future<List<BioInsumoItem>> _dadosFuture;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento assim que a tela abre
    _dadosFuture = _service.carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BioInsumoItem>>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          
          // 1. Se estiver carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text("Carregando bioinsumos...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 2. Se deu erro
          if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar dados: ${snapshot.error}"),
            );
          }

          // 3. Se terminou com sucesso
          if (snapshot.hasData) {
            final dadosCarregados = snapshot.data ?? [];
            
            // Redireciona para a página de gráficos passando os dados
            return BioInsumoPage(dados: dadosCarregados);
          }

          return const Center(child: Text("Nenhum dado encontrado."));
        },
      ),
    );
  }
}