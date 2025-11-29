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
    final colorScheme = Theme.of(context).colorScheme;

    // Filtra receitas com progresso (começa 0 de 0 não mostra)
    final receitasComProgresso =
        receitaState.receitas.where((r) => r.dataInicio != null).toList();

    Widget bodyContent;

    // ---------------------------------------------------------
    // CENÁRIO 1: Lista Vazia
    // ---------------------------------------------------------
    if (receitasComProgresso.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: colorScheme.tertiary),
            const SizedBox(height: 20),
            Text(
              'Nenhuma receita em progresso',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ---------------------------------------------------------
    // CENÁRIO 2: Lista com Histórico
    // ---------------------------------------------------------
    else {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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

                //para alternar as cores dos cards:
                final Color cardColor = (index % 2 == 0)
                    ? colorScheme.secondary
                    : colorScheme.surface;

                return GestureDetector(
                  onTap: () {
                    final receitaState = context.read<ReceitaState>();
                    receitaState.carregarReceitaParaEdicao(receita.id!);

                    // Carrega a receita no contador
                    final passos = receita.passos
                        .map((p) => StepData(
                            descricao: p.descricao, repeticoes: p.repeticoes))
                        .toList();

                    context.read<CounterAppState>().carregarReceita(
                          titulo: receita.titulo,
                          passos: passos,
                        );

                    // Restaura o progresso exato (passo atual e repetições feitas)
                    context.read<CounterAppState>().currentStepIndex =
                        receita.passoAtual;
                    context.read<CounterAppState>().repeticoesFeitasNoPasso =
                        receita.repeticoesFeitasNoPasso;

                    Navigator.pushNamed(context, "/");
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),

                    //cor do card:
                    color: cardColor,
                    surfaceTintColor: Colors.transparent,

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
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (receita.concluida)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSecondary,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    "✓ Concluída",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.primary,
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
                                      color: colorScheme.primary,
                                      backgroundColor: colorScheme.onSecondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${(porcentagem * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Passo ${receita.passoAtual + 1}/${receita.passos.length}",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (receita.dataInicio != null)
                            Text(
                              "Iniciada em: ${_formatarData(receita.dataInicio!)}",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          if (receita.dataUltimaAtualizacao != null)
                            Text(
                              "Última atualização: ${_formatarData(receita.dataUltimaAtualizacao!)}",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
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

          //botão limpar histórico
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                //estilo:
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(colorScheme.error),
                  foregroundColor:
                      WidgetStateProperty.all(colorScheme.onSecondary),

                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // hover
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
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
                        'Limpar histórico?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                          'Deseja resetar o progresso de todas as receitas? As receitas salvas serão mantidas.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'Limpar',
                              style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold),
                            )),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico"),
        centerTitle: true,
      ),
      body: bodyContent,
    );
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }
}
