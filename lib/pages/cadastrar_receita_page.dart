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
    final colorScheme = Theme.of(context).colorScheme;

    final inputDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.tertiary, width: 2.0),
      ),
      // Cor do rótulo quando focado
      floatingLabelStyle: TextStyle(color: colorScheme.tertiary),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Receita"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CARD DO TÍTULO
              Card(
                elevation: 4,
                shadowColor:
                    colorScheme.shadow.withOpacity(0.2), // Sombra suave
                color: colorScheme
                    .surface, // Fundo do Card (Branco no Day, Cinza no Night)
                surfaceTintColor: Colors.transparent,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: tituloController,
                    decoration: inputDecoration.copyWith(
                      labelText: "Título da Receita",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // FORMULÁRIO DO PASSO
              Card(
                elevation: 4,
                shadowColor: colorScheme.shadow.withOpacity(0.2),
                color: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: descricaoController,
                        decoration: inputDecoration.copyWith(
                          labelText: "Descrição do passo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: repeticoesController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
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
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor:
                                colorScheme.onPrimary, // Texto branco
                          ),
                          onPressed: () {
                            final descricao = descricaoController.text.trim();
                            final repeticoes = int.tryParse(
                                    repeticoesController.text.trim()) ??
                                0;

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

              // LISTA DE PASSOS (com shrinkWrap para evitar conflito de tamanho)
              Card(
                elevation: 4,
                color: colorScheme.surface, // Fundo branco/cinza
                surfaceTintColor: Colors.transparent,
                child: receitaState.passosTemp.isEmpty
                    ? SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Nenhum passo adicionado ainda",
                            style: TextStyle(
                              color: colorScheme.outline, // Cinza do tema
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: receitaState.passosTemp.length,
                        itemBuilder: (_, index) {
                          final passo = receitaState.passosTemp[index];
                          return Card(
                            color: colorScheme.surfaceContainerHighest,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(passo.descricao),
                              subtitle: Text("${passo.repeticoes} repetições"),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar Receita"),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onPrimary, // Texto Azul Escuro
                    padding:
                        const EdgeInsets.symmetric(vertical: 16), // Mais alto
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
      ),
    );
  }
}
