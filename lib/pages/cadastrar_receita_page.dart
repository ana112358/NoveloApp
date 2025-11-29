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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputDecoration = InputDecoration(
      // estilo das bordas
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.tertiary, width: 3.0),
      ),
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
      ),
    );

    return Scaffold(
      // cor do fundo:
      backgroundColor: colorScheme.onSecondary,

      //app bar:
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
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                surfaceTintColor: Colors.transparent,

                //cor do card:
                color: colorScheme.secondary,
                margin: const EdgeInsets.only(bottom: 16),

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: tituloController,

                    //cor do texto digitado:
                    style: TextStyle(
                      color:
                          isDark ? colorScheme.tertiary : colorScheme.primary,
                      fontSize: 16,
                    ),

                    decoration: inputDecoration.copyWith(
                      labelText: "Título da Receita",
                      filled: true,
                      fillColor: colorScheme.onSecondary,

                      // cor do rótulo:
                      labelStyle: TextStyle(
                        color:
                            isDark ? colorScheme.tertiary : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // FORMULÁRIO DO PASSO
              Card(
                elevation: 4,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                surfaceTintColor: Colors.transparent,

                //cor do card:
                color: colorScheme.secondary,
                margin: const EdgeInsets.only(bottom: 16),

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: descricaoController,

                        //cor do texto digitado:
                        style: TextStyle(
                          color: isDark
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          fontSize: 16,
                        ),

                        decoration: inputDecoration.copyWith(
                          labelText: "Descrição do passo",
                          filled: true,
                          fillColor: colorScheme.onSecondary,

                          // cor do rótulo:
                          labelStyle: TextStyle(
                            color: isDark
                                ? colorScheme.tertiary
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: repeticoesController,
                        keyboardType: TextInputType.number,

                        //cor do texto digitado:
                        style: TextStyle(
                          color: isDark
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          fontSize: 16,
                        ),

                        decoration: inputDecoration.copyWith(
                          labelText: "Repetições",
                          filled: true,
                          fillColor: colorScheme.onSecondary,

                          // cor do rótulo:
                          labelStyle: TextStyle(
                            color: isDark
                                ? colorScheme.tertiary
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Adicionar Passo"),

                          //estilos do botão:
                          style: ButtonStyle(
                            //Cores do Botão
                            backgroundColor: WidgetStateProperty.all(isDark
                                ? colorScheme.primary
                                : colorScheme.onSecondary),
                            foregroundColor: WidgetStateProperty.all(isDark
                                ? colorScheme.tertiary
                                : colorScheme.primary),

                            // Hover
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>(
                                    (states) {
                              if (isDark) {
                                if (states.contains(WidgetState.hovered)) {
                                  return colorScheme.surface
                                      .withValues(alpha: 0.4);
                                }
                                if (states.contains(WidgetState.pressed)) {
                                  return colorScheme.surface
                                      .withValues(alpha: 0.8);
                                }
                              } else {
                                if (states.contains(WidgetState.hovered)) {
                                  return colorScheme.tertiary
                                      .withValues(alpha: 0.4);
                                }
                                if (states.contains(WidgetState.pressed)) {
                                  return colorScheme.tertiary
                                      .withValues(alpha: 0.8);
                                }
                              }
                              return null;
                            }),

                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),

                            //estilo do label
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                fontSize: 16,
                              ),
                            ),
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

              // LISTA DE PASSOS
              Card(
                elevation: 0,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                surfaceTintColor: Colors.transparent,

                //cor do card:
                color: colorScheme.onSecondary,

                child: receitaState.passosTemp.isEmpty
                    ? SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Nenhum passo adicionado ainda",
                            //cor do texto
                            style: TextStyle(
                              color: isDark
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              fontSize: 16,
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
                            // cor dos passos salvos (Fundo)
                            color: colorScheme.surface,
                            margin: const EdgeInsets.only(bottom: 8),

                            child: ListTile(
                              title: Text(
                                passo.descricao,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "${passo.repeticoes} repetições",
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
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

                  //estilos do botão:
                  style: ButtonStyle(
                    // Cores do Botão
                    backgroundColor:
                        WidgetStateProperty.all(colorScheme.tertiary),
                    foregroundColor:
                        WidgetStateProperty.all(colorScheme.primary),

                    // Hover
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

                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),

                    //estilo do label
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 16,
                      ),
                    ),
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
