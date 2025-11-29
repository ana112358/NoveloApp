import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_unid2/pages/cadastrar_receita_page.dart';
import 'package:flutter_application_unid2/pages/lista_receitas_page.dart';
import '../state/theme_state.dart';
import 'counter_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeState = context.watch<ThemeState>();
    final isDark = themeState.isDarkMode(context);

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = CounterPage();
        break;
      case 1:
        page = HistoryPage();
        break;
      case 2:
        page = CadastrarReceitaPage();
        break;
      case 3:
        page = ListaReceitasPage(); // ⭐ NOVA PÁGINA: LISTA DE RECEITAS
        break;
      default:
        throw UnimplementedError("Página não existe");
    }

    final mainArea = ColoredBox(
      color: colorScheme.surface,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          context.read<ThemeState>().toggleTheme();
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.surface,
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Layout celular
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() => selectedIndex = value);
                    },
                    backgroundColor: colorScheme.surface,
                    selectedItemColor: colorScheme.secondary,
                    unselectedItemColor: colorScheme.primary,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calculate),
                        label: 'Vamos crochetar?',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.history),
                        label: 'Histórico',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.edit_note),
                        label: 'Cadastrar',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list_alt),
                        label: 'Receitas',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Layout tablet/desktop
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) =>
                      setState(() => selectedIndex = value),
                  backgroundColor: colorScheme.surface,
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: IconButton(
                          icon:
                              Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () =>
                              context.read<ThemeState>().toggleTheme(),
                        ),
                      ),
                    ),
                  ),
                  selectedLabelTextStyle: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: colorScheme.primary,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate),
                      label: Text('Vamos crochetar?'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('Histórico'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.edit_note),
                      label: Text('Cadastrar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt),
                      label: Text('Receitas'),
                    ),
                  ],
                ),
              ),
              Expanded(child: mainArea),
            ],
          );
        },
      ),
    );
  }
}
