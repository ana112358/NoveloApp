import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/counter_app_state.dart';
import '../state/receita_state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<CounterAppState>();
    final receitaState = context.watch<ReceitaState>();

    final passoAtual = appState.passoAtual;

    // =====================================================
    // 1) SE NÃO HÁ RECEITA CARREGADA
    // =====================================================
    if (passoAtual == null) {
      // -------------------------------
      // 1.1 — Nenhuma receita cadastrada
      // -------------------------------
      if (receitaState.receitas.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
              const SizedBox(height: 20),

              const Text(
                "Nenhuma receita cadastrada ainda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/cadastrar");
                },
                icon: const Icon(Icons.add),
                label: const Text("Cadastrar receita"),
              ),
            ],
          ),
        );
      }

      // -------------------------------
      // 1.2 — Há receitas → Mostrar lista
      // -------------------------------
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: receitaState.receitas.length,
          itemBuilder: (_, i) {
            final receita = receitaState.receitas[i];

            int totalRepeticoes = receita.passos.fold(
              0,
              (sum, passo) => sum + passo.repeticoes,
            );

            return Card(
              child: ListTile(
                title: Text(receita.titulo),
                subtitle: Text(
                  "${receita.passos.length} passos • Total de repetições: $totalRepeticoes",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () {
                    final passos = receita.passos
                        .map((p) => StepData(
                              descricao: p.descricao,
                              repeticoes: p.repeticoes,
                            ))
                        .toList();

                    appState.carregarReceita(
                      titulo: receita.titulo,
                      passos: passos,
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }

    // =====================================================
    // 2) RECEITA CARREGADA → MOSTRAR CONTADOR
    // =====================================================
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          Text(
            appState.currentRecipeTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const Text(
            "Passo atual:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          Text(
            passoAtual.descricao,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          Text(
            "Repetição ${appState.repeticoesFeitasNoPasso} / ${passoAtual.repeticoes}",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (appState.repeticoesFeitasNoPasso > 0 ||
                        appState.currentStepIndex > 0)
                    ? appState.voltarRepeticao
                    : null,
                icon: const Icon(Icons.navigate_before),
                label: const Text("Voltar"),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: (appState.currentStepIndex < appState.passos.length - 1 ||
                        appState.repeticoesFeitasNoPasso < passoAtual.repeticoes)
                    ? appState.avancarRepeticao
                    : null,
                icon: const Icon(Icons.navigate_next),
                label: const Text("Avançar"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (appState.currentStepIndex == appState.passos.length - 1 &&
              appState.repeticoesFeitasNoPasso == passoAtual.repeticoes)
            const Text(
              "Receita concluída! 🎉",
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: appState.reset,
            icon: const Icon(Icons.refresh),
            label: const Text("Zerar receita"),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
