import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/receita_state.dart';
import '../models/receita_passo.dart';

class CadastrarReceitaPage extends StatefulWidget {
  const CadastrarReceitaPage({super.key});

  @override
  State<CadastrarReceitaPage> createState() => _CadastrarReceitaPageState();
}

class _CadastrarReceitaPageState extends State<CadastrarReceitaPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final repeticoesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final receitaState = context.watch<ReceitaState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Receita"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD DO TÍTULO
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título da Receita",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            // FORMULÁRIO DO PASSO
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: descricaoController,
                      decoration: const InputDecoration(
                        labelText: "Descrição do passo",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: repeticoesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Repetições",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Passo"),
                        onPressed: () {
                          final descricao = descricaoController.text.trim();
                          final repeticoes =
                              int.tryParse(repeticoesController.text.trim()) ?? 0;

                          if (descricao.isEmpty || repeticoes <= 0) return;

                          receitaState.adicionarPasso(
                            ReceitaPasso(
                              descricao: descricao,
                              repeticoes: repeticoes,
                            ),
                          );

                          descricaoController.clear();
                          repeticoesController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // LISTA DE PASSOS
            Expanded(
              child: Card(
                elevation: 2,
                child: receitaState.passosTemp.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum passo adicionado ainda",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: receitaState.passosTemp.length,
                        itemBuilder: (_, index) {
                          final passo = receitaState.passosTemp[index];
                          return Card(
                            child: ListTile(
                              title: Text(passo.descricao),
                              subtitle: Text("${passo.repeticoes} repetições"),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Salvar Receita"),
                onPressed: () {
                  final titulo = tituloController.text.trim();
                  if (titulo.isEmpty) return;

                  receitaState.salvarReceita(titulo);

                  // Limpa tudo
                  tituloController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
