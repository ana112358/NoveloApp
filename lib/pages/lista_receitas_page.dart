import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/receita_state.dart';
import '../state/counter_app_state.dart';

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
              child: Text(
                "Nenhuma receita salva ainda.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: receitaState.receitas.length,
              itemBuilder: (_, i) {
                final receita = receitaState.receitas[i];

                // Calcula total de repetições e progresso
                int totalRepeticoes = receita.passos
                    .fold(0, (sum, passo) => sum + passo.repeticoes);
                double progresso = receita.passos.isEmpty
                    ? 0.0
                    : (receita.passoAtual + 1) / receita.passos.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(receita.titulo),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${receita.passos.length} passos • Total: $totalRepeticoes repetições",
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progresso,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Passo ${receita.passoAtual + 1}/${receita.passos.length}",
                              style: const TextStyle(fontSize: 12),
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
                                color: colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Concluída",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.tertiary,
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
                          icon: Icon(Icons.play_arrow,
                              color: colorScheme.tertiary),
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
