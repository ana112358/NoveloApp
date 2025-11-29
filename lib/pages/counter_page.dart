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
    final colorScheme = Theme.of(context).colorScheme;

    final passoAtual = appState.passoAtual;

    Widget bodyContent;

    // =====================================================
    // 1) SE NÃO HÁ RECEITA CARREGADA
    // =====================================================
    if (passoAtual == null) {
      // -------------------------------
      // 1.1 — Nenhuma receita cadastrada
      // -------------------------------
      if (receitaState.receitas.isEmpty) {
        bodyContent = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: colorScheme.error),
              const SizedBox(height: 20),
              const Text(
                "Nenhuma receita cadastrada ainda",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
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
      else {
        bodyContent = Padding(
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
                    icon: Icon(Icons.play_arrow, color: colorScheme.tertiary),
                    onPressed: () async {
                      // Carrega a receita no receitaState também!
                      await receitaState.carregarReceitaParaEdicao(receita.id!);

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
    }

    // =====================================================
    // 2) RECEITA CARREGADA → MOSTRAR CONTADOR
    // =====================================================
    else {
      bodyContent = Column(
        children: [
          // Barra superior com botões de navegação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Salva e volta para a lista de receitas
                    await receitaState.atualizarProgressoCompleto(
                      appState.currentStepIndex,
                      appState.repeticoesFeitasNoPasso,
                    );
                    await receitaState.limparReceitaEmEdicao();
                    appState.reset();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (route) => false);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Salva e sai da tela
                    await receitaState.atualizarProgressoCompleto(
                      appState.currentStepIndex,
                      appState.repeticoesFeitasNoPasso,
                    );
                    await receitaState.limparReceitaEmEdicao();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Sair"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appState.currentRecipeTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Passo atual:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    passoAtual.descricao,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
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
                            ? () async {
                                appState.voltarRepeticao();
                                // Salva progresso completo no BD (passo + repetições)
                                await receitaState.atualizarProgressoCompleto(
                                  appState.currentStepIndex,
                                  appState.repeticoesFeitasNoPasso,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.navigate_before),
                        label: const Text("Voltar"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: (appState.currentStepIndex <
                                    appState.passos.length - 1 ||
                                appState.repeticoesFeitasNoPasso <
                                    passoAtual.repeticoes)
                            ? () async {
                                appState.avancarRepeticao();
                                // Salva progresso completo no BD (passo + repetições)
                                await receitaState.atualizarProgressoCompleto(
                                  appState.currentStepIndex,
                                  appState.repeticoesFeitasNoPasso,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.navigate_next),
                        label: const Text("Avançar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (appState.currentStepIndex == appState.passos.length - 1 &&
                      appState.repeticoesFeitasNoPasso == passoAtual.repeticoes)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Receita concluída! 🎉",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Marca como concluída no BD
                              if (receitaState.receitaEmEdicao != null) {
                                await receitaState.marcarComoConcluida(
                                  receitaState.receitaEmEdicao!.id!,
                                );
                              }

                              if (!context.mounted) return;

                              // Volta para a home
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Finalizar"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: appState.reset,
                icon: const Icon(Icons.refresh),
                label: const Text("Zerar receita"),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vamos crochetar?"),
        centerTitle: true,
      ),
      body: bodyContent,
    );
  }
}
