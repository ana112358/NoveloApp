import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/counter_app_state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<CounterAppState>();
    final passoAtual = appState.passoAtual;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          if (passoAtual != null)
            Column(
              children: [
                // Título da receita
                Text(
                  appState.currentRecipeTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Passo atual
                Text(
                  "Passo atual:",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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

                // Botões Voltar / Avançar
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

                // Conclusão da receita
                if (appState.currentStepIndex == appState.passos.length - 1 &&
                    appState.repeticoesFeitasNoPasso == passoAtual.repeticoes)
                  const Text(
                    "Receita concluída! 🎉",
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
              ],
            )
          else
            const Text(
              "Nenhuma receita carregada",
              style: TextStyle(fontSize: 22),
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
