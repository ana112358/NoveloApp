import 'receita_passo.dart';

class Receita {
  final int? id; // ID do banco de dados (null = não salvo ainda)
  final String titulo;
  final List<ReceitaPasso> passos;
  final int passoAtual; // Índice do passo atual (0-based)
  final int repeticoesFeitasNoPasso; // Repetições já feitas no passo atual
  final DateTime? dataInicio;
  final DateTime? dataUltimaAtualizacao;
  final bool concluida;

  Receita({
    this.id,
    required this.titulo,
    required this.passos,
    this.passoAtual = 0,
    this.repeticoesFeitasNoPasso = 0,
    this.dataInicio,
    this.dataUltimaAtualizacao,
    this.concluida = false,
  });

  // Cria uma cópia com campos atualizados
  Receita copyWith({
    int? id,
    String? titulo,
    List<ReceitaPasso>? passos,
    int? passoAtual,
    int? repeticoesFeitasNoPasso,
    DateTime? dataInicio,
    DateTime? dataUltimaAtualizacao,
    bool? concluida,
  }) {
    return Receita(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      passos: passos ?? this.passos,
      passoAtual: passoAtual ?? this.passoAtual,
      repeticoesFeitasNoPasso: repeticoesFeitasNoPasso ?? this.repeticoesFeitasNoPasso,
      dataInicio: dataInicio ?? this.dataInicio,
      dataUltimaAtualizacao: dataUltimaAtualizacao ?? this.dataUltimaAtualizacao,
      concluida: concluida ?? this.concluida,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "passos": passos.map((p) => p.toMap()).toList(),
      "passoAtual": passoAtual,
      "repeticoesFeitasNoPasso": repeticoesFeitasNoPasso,
      "dataInicio": dataInicio?.toIso8601String(),
      "dataUltimaAtualizacao": dataUltimaAtualizacao?.toIso8601String(),
      "concluida": concluida ? 1 : 0,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map["id"],
      titulo: map["titulo"],
      passos: (map["passos"] as List)
          .map((p) => ReceitaPasso.fromMap(p as Map<String, dynamic>))
          .toList(),
      passoAtual: map["passoAtual"] ?? 0,
      repeticoesFeitasNoPasso: map["repeticoesFeitasNoPasso"] ?? 0,
      dataInicio: map["dataInicio"] != null 
          ? DateTime.parse(map["dataInicio"]) 
          : null,
      dataUltimaAtualizacao: map["dataUltimaAtualizacao"] != null
          ? DateTime.parse(map["dataUltimaAtualizacao"])
          : null,
      concluida: (map["concluida"] ?? 0) == 1,
    );
  }
}
