import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/receita_state.dart';
import '../state/counter_app_state.dart';

class ListaReceitasPage extends StatelessWidget {
  const ListaReceitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final receitaState = context.watch<ReceitaState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Receitas Salvas")),
      body: ListView.builder(
        itemCount: receitaState.receitas.length,
        itemBuilder: (_, i) {
          final receita = receitaState.receitas[i];

          // Calcula total de repetições da receita
          int totalRepeticoes = receita.passos.fold(
              0, (sum, passo) => sum + passo.repeticoes);

          return Card(
            child: ListTile(
              title: Text(receita.titulo),
              subtitle: Text(
                  "${receita.passos.length} passos • Total de repetições: $totalRepeticoes"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de excluir
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => receitaState.excluirReceita(i),
                  ),
                  // Botão de começar
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () {
                      if (receita.passos.isNotEmpty) {
                        // Converte os passos para StepData (se ainda não estiver nesse formato)
                        final passos = receita.passos
                            .map((p) =>
                                StepData(descricao: p.descricao, repeticoes: p.repeticoes))
                            .toList();

                        // Carrega a receita no contador
                        context.read<CounterAppState>().carregarReceita(
                              titulo: receita.titulo,
                              passos: passos,
                            );

                        // Vai para a página do contador
                        Navigator.pushNamed(context, "/");
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
}
