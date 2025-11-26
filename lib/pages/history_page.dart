import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/counter_app_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<CounterAppState>();

    if (appState.history.isEmpty) {
      return Center(
        child: Text(
          'Nenhum histórico ainda.',
          style: theme.textTheme.titleLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Histórico:',
                style: theme.textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: appState.clearHistory,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: appState.history.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Valor: ${appState.history[index]}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
