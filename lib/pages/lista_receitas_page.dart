import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/receita_state.dart';
import '../state/counter_app_state.dart';
import '../models/receita_passo.dart';

class ListaReceitasPage extends StatelessWidget {
  const ListaReceitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final receitaState = context.watch<ReceitaState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Receitas Salvas")),
      body: receitaState.receitas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //estilo ícone nenhuma receita salva
                  Icon(Icons.gesture, size: 80, color: colorScheme.tertiary),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhuma receita salva',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: receitaState.receitas.length,
              itemBuilder: (_, i) {
                final receita = receitaState.receitas[i];

                //para alternar as cores dos cards:
                final Color cardColor =
                    (i % 2 == 0) ? colorScheme.secondary : colorScheme.surface;

                // Calcula total de repetições e progresso
                int totalRepeticoes = receita.passos
                    .fold(0, (sum, passo) => sum + passo.repeticoes);
                double progresso = receita.passos.isEmpty
                    ? 0.0
                    : (receita.passoAtual + 1) / receita.passos.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${receita.passos.length} passos • Total: $totalRepeticoes repetições",
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                    value: progresso,
                                    minHeight: 6,
                                    color: colorScheme.primary,
                                    backgroundColor: colorScheme.onSecondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Passo ${receita.passoAtual + 1}/${receita.passos.length}",
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (receita.concluida)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.onSecondary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "Concluída",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: colorScheme.error),
                          onPressed: () => _confirmarDelecao(
                              context, receitaState, receita.id!),
                        ),
                        IconButton(
                          //estilo botão play:
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.tertiary,
                          ),

                          icon: Icon(Icons.play_arrow),

                          onPressed: () async {
                            if (receita.passos.isNotEmpty) {
                              // Carrega a receita mais recente do BD
                              await receitaState
                                  .carregarReceitaParaEdicao(receita.id!);

                              // Carrega a receita no contador
                              final passos = receita.passos
                                  .map((p) => StepData(
                                      descricao: p.descricao,
                                      repeticoes: p.repeticoes))
                                  .toList();

                              if (context.mounted) {
                                context.read<CounterAppState>().carregarReceita(
                                      titulo: receita.titulo,
                                      passos: passos,
                                    );

                                // Restaura o progresso (passo atual e repetições feitas)
                                context
                                    .read<CounterAppState>()
                                    .currentStepIndex = receita.passoAtual;
                                context
                                        .read<CounterAppState>()
                                        .repeticoesFeitasNoPasso =
                                    receita.repeticoesFeitasNoPasso;

                                Navigator.pushNamed(context, "/");
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmarDelecao(
      BuildContext context, ReceitaState state, int receitaId) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Deletar receita?"),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              state.excluirReceita(receitaId);
              Navigator.pop(ctx);
            },
            child: Text("Deletar", style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
