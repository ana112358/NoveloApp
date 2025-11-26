import 'receita_passo.dart';

class Receita {
  final String titulo;
  final List<ReceitaPasso> passos;

  Receita({
    required this.titulo,
    required this.passos,
  });

  Map<String, dynamic> toMap() {
    return {
      "titulo": titulo,
      "passos": passos.map((p) => p.toMap()).toList(),
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      titulo: map["titulo"],
      passos: (map["passos"] as List)
          .map((p) => ReceitaPasso.fromMap(p))
          .toList(),
    );
  }
}
