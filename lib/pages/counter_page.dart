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
              //estilo do ícone
              Icon(Icons.receipt_long, size: 80, color: colorScheme.tertiary),

              const SizedBox(height: 20),
              Text(
                "Nenhuma receita cadastrada ainda",
                //estilo do texto
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.error),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/cadastrar");
                },
                icon: const Icon(Icons.add),
                label: const Text("Cadastrar receita"),
                style: ButtonStyle(
                  // cores do botão
                  backgroundColor:
                      WidgetStateProperty.all(colorScheme.secondary),
                  foregroundColor: WidgetStateProperty.all(colorScheme.primary),

                  // cores do hover
                  overlayColor:
                      WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return colorScheme.surface.withValues(alpha: 0.4);
                    }
                    if (states.contains(WidgetState.pressed)) {
                      return colorScheme.surface.withValues(alpha: 0.4);
                    }
                    return null;
                  }),

                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
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

              //para alternar as cores dos cards:
              final Color cardColor =
                  (i % 2 == 0) ? colorScheme.secondary : colorScheme.surface;

              int totalRepeticoes = receita.passos.fold(
                0,
                (sum, passo) => sum + passo.repeticoes,
              );

              return Card(
                //cor do card:
                color: cardColor,
                surfaceTintColor: Colors.transparent,

                child: ListTile(
                  title: Text(
                    receita.titulo,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${receita.passos.length} passos • Total de repetições: $totalRepeticoes",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                  trailing: IconButton(
                    //estilo botão play:
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.tertiary,
                    ),

                    icon: Icon(Icons.play_arrow),

                    onPressed: () async {
                      // Carrega a receita no receitaState
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
                  style: ButtonStyle(
                    // cores do botão
                    backgroundColor:
                        WidgetStateProperty.all(colorScheme.secondary),
                    foregroundColor:
                        WidgetStateProperty.all(colorScheme.primary),

                    // cores do hover
                    overlayColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return colorScheme.tertiary.withValues(alpha: 0.4);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return colorScheme.tertiary.withValues(alpha: 0.8);
                      }
                      return null;
                    }),

                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10)),
                  ),
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
                  style: ButtonStyle(
                    // cores do botão
                    backgroundColor:
                        WidgetStateProperty.all(colorScheme.secondary),
                    foregroundColor:
                        WidgetStateProperty.all(colorScheme.primary),

                    // cores do hover
                    overlayColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return colorScheme.tertiary.withValues(alpha: 0.4);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return colorScheme.tertiary.withValues(alpha: 0.8);
                      }
                      return null;
                    }),

                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10)),
                  ),
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
                    style: TextStyle(
                        fontSize: 32,
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Passo atual:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    passoAtual.descricao,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Repetição ${appState.repeticoesFeitasNoPasso} / ${passoAtual.repeticoes}",
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                        label: const Text("Retornar"),
                        style: ButtonStyle(
                          // cores do botão
                          backgroundColor:
                              WidgetStateProperty.all(colorScheme.surface),
                          foregroundColor:
                              WidgetStateProperty.all(colorScheme.primary),

                          // cores do hover
                          overlayColor:
                              WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return colorScheme.secondary
                                  .withValues(alpha: 0.4);
                            }
                            if (states.contains(WidgetState.pressed)) {
                              return colorScheme.secondary
                                  .withValues(alpha: 0.8);
                            }
                            return null;
                          }),

                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 18),
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
                        style: ButtonStyle(
                          // cores do botão
                          backgroundColor:
                              WidgetStateProperty.all(colorScheme.tertiary),
                          foregroundColor:
                              WidgetStateProperty.all(colorScheme.primary),

                          // cores do hover
                          overlayColor:
                              WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return colorScheme.secondary
                                  .withValues(alpha: 0.4);
                            }
                            if (states.contains(WidgetState.pressed)) {
                              return colorScheme.secondary
                                  .withValues(alpha: 0.8);
                            }
                            return null;
                          }),

                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (appState.currentStepIndex == appState.passos.length - 1 &&
                      appState.repeticoesFeitasNoPasso == passoAtual.repeticoes)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Receita concluída! 🎉",
                            style: TextStyle(
                                fontSize: 20,
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double
                                .infinity, // Ocupa toda a largura disponível
                            child: ElevatedButton.icon(
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
                              style: ButtonStyle(
                                // cores do botão
                                backgroundColor: WidgetStateProperty.all(
                                    colorScheme.secondary),
                                foregroundColor: WidgetStateProperty.all(
                                    colorScheme.primary),

                                // cores do hover
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return colorScheme.tertiary
                                        .withValues(alpha: 0.4);
                                  }
                                  if (states.contains(WidgetState.pressed)) {
                                    return colorScheme.tertiary
                                        .withValues(alpha: 0.8);
                                  }
                                  return null;
                                }),

                                textStyle: WidgetStateProperty.all(
                                  const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 12)),
                              ),
                            ),
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
                style: ButtonStyle(
                  // cores do botão
                  backgroundColor: WidgetStateProperty.all(colorScheme.error),
                  foregroundColor:
                      WidgetStateProperty.all(colorScheme.onSecondary),

                  // cores do hover
                  overlayColor:
                      WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return colorScheme.secondary.withValues(alpha: 0.4);
                    }
                    if (states.contains(WidgetState.pressed)) {
                      return colorScheme.secondary.withValues(alpha: 0.8);
                    }
                    return null;
                  }),

                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12)),
                ),
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
