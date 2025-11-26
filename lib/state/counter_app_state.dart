import 'package:flutter/material.dart';

class StepData {
  final String descricao;
  final int repeticoes;
  StepData({required this.descricao, required this.repeticoes});
}

class CounterAppState extends ChangeNotifier {
  int counter = 0;
  List<int> history = [];

  // ---------- VARIÁVEIS DA RECEITA ----------
  String currentRecipeTitle = "";         // Título da receita
  List<StepData> passos = [];             // Lista de passos
  int currentStepIndex = 0;               // Passo atual
  int repeticoesFeitasNoPasso = 0;        // Quantas repetições já foram feitas no passo atual

  // ---------- CONTADOR ----------
  void increment() {
    counter++;
    history.insert(0, counter);
    notifyListeners();
  }

  void decrement() {
    if (counter > 0) {
      counter--;
      history.insert(0, counter);
      notifyListeners();
    }
  }

  void addTwo() {
    counter += 2;
    history.insert(0, counter);
    notifyListeners();
  }

  void subtractTwo() {
    if (counter > 0) {
      counter -= 2;
      if (counter < 0) counter = 0;
      history.insert(0, counter);
      notifyListeners();
    }
  }

  void reset() {
    counter = 0;
    currentRecipeTitle = "";
    passos = [];
    currentStepIndex = 0;
    repeticoesFeitasNoPasso = 0;
    history.insert(0, counter);
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  // ---------- CARREGAR UMA RECEITA ----------
  void carregarReceita({required String titulo, required List<StepData> passos}) {
    currentRecipeTitle = titulo;
    this.passos = passos;
    currentStepIndex = 0;
    repeticoesFeitasNoPasso = 0;
    notifyListeners();
  }

  StepData? get passoAtual {
    if (passos.isEmpty || currentStepIndex >= passos.length) return null;
    return passos[currentStepIndex];
  }

  // ---------- AVANÇAR 1 REPETIÇÃO ----------
  void avancarRepeticao() {
    final passo = passoAtual;
    if (passo == null) return;

    if (repeticoesFeitasNoPasso < passo.repeticoes) {
      repeticoesFeitasNoPasso++;
    } else if (currentStepIndex < passos.length - 1) {
      currentStepIndex++;
      repeticoesFeitasNoPasso = 0;
    }
    notifyListeners();
  }

  // ---------- VOLTAR 1 REPETIÇÃO ----------
  void voltarRepeticao() {
    if (repeticoesFeitasNoPasso > 0) {
      repeticoesFeitasNoPasso--;
    } else if (currentStepIndex > 0) {
      currentStepIndex--;
      repeticoesFeitasNoPasso = passos[currentStepIndex].repeticoes;
    }
    notifyListeners();
  }
}
