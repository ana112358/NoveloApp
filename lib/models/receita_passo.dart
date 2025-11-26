class ReceitaPasso {
  final String descricao;
  final int repeticoes;

  ReceitaPasso({
    required this.descricao,
    required this.repeticoes,
  });

  Map<String, dynamic> toMap() {
    return {
      "descricao": descricao,
      "repeticoes": repeticoes,
    };
  }

  factory ReceitaPasso.fromMap(Map<String, dynamic> map) {
    return ReceitaPasso(
      descricao: map["descricao"],
      repeticoes: map["repeticoes"],
    );
  }
}
