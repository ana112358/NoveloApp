import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/receita_state.dart';
import '../state/counter_app_state.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Recarrega receitas quando a página é aberta
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ReceitaState>().carregarReceitasDoBancoDados();
      print('DEBUG HistoryPage initState: Receitas recarregadas');
    });
  }

  @override
  Widget build(BuildContext context) {
    final receitaState = context.watch<ReceitaState>();
    final theme = Theme.of(context);

    // Filtra receitas com progresso (começa 0 de 0 não mostra)
    final receitasComProgresso = receitaState.receitas
        .where((r) => r.dataInicio != null)
        .toList();

    if (receitasComProgresso.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma receita em progresso ou concluída',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Histórico de Receitas',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: receitasComProgresso.length,
            itemBuilder: (context, index) {
              final receita = receitasComProgresso[index];
              final porcentagem = receita.passos.isEmpty
                  ? 0.0
                  : (receita.passoAtual + 1) / receita.passos.length;

              return GestureDetector(
                onTap: () {
                  final receitaState = context.read<ReceitaState>();
                  receitaState.carregarReceitaParaEdicao(receita.id!);
                  
                  // Carrega a receita no contador
                  final passos = receita.passos
                      .map((p) =>
                          StepData(descricao: p.descricao, repeticoes: p.repeticoes))
                      .toList();
                  
                  context.read<CounterAppState>().carregarReceita(
                        titulo: receita.titulo,
                        passos: passos,
                      );
                  
                  // Restaura o progresso exato (passo atual e repetições feitas)
                  context.read<CounterAppState>().currentStepIndex = receita.passoAtual;
                  context.read<CounterAppState>().repeticoesFeitasNoPasso = receita.repeticoesFeitasNoPasso;
                  
                  Navigator.pushNamed(context, "/");
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              receita.titulo,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (receita.concluida)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "✓ Concluída",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: porcentagem,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(porcentagem * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Passo ${receita.passoAtual + 1}/${receita.passos.length}",
                        style: theme.textTheme.bodySmall,
                      ),
                      if (receita.dataInicio != null)
                        Text(
                          "Iniciada em: ${_formatarData(receita.dataInicio!)}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      if (receita.dataUltimaAtualizacao != null)
                        Text(
                          "Última atualização: ${_formatarData(receita.dataUltimaAtualizacao!)}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Limpar histórico?'),
                    content: const Text('Deseja resetar o progresso de todas as receitas? As receitas salvas serão mantidas.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Limpar')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await receitaState.limparHistorico();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Histórico limpo com sucesso!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Limpar histórico'),
            ),
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }
}
