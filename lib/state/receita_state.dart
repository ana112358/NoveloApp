import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../models/receita_passo.dart';

class ReceitaState extends ChangeNotifier {
  List<ReceitaPasso> passosTemp = [];
  List<Receita> receitas = [];

  // Adiciona um passo
  void adicionarPasso(ReceitaPasso passo) {
    passosTemp.add(passo);
    notifyListeners();
  }

  // Limpa passos temporários
  void limparPassos() {
    passosTemp.clear();
    notifyListeners();
  }

  // Salvar receita completa
  void salvarReceita(String titulo) {
    if (titulo.isEmpty || passosTemp.isEmpty) return;

    receitas.add(
      Receita(titulo: titulo, passos: List.from(passosTemp)),
    );

    limparPassos();
    notifyListeners();
  }

  // Excluir receita salva
  void excluirReceita(int index) {
    receitas.removeAt(index);
    notifyListeners();
  }
}
