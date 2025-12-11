// ARQUIVO: lib/bio_model.dart

class BioInsumoItem {
  final String cultura;
  final String? tipo;
  // Pode vir como String única ou Lista do JSON, por isso usamos dynamic
  final dynamic especie; 

  BioInsumoItem({
    required this.cultura,
    this.tipo,
    this.especie,
  });
}