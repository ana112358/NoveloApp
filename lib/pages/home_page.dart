import 'package:flutter/material.dart';
import 'package:flutter_application_unid2/pages/cadastrar_receita_page.dart';
import 'package:flutter_application_unid2/pages/lista_receitas_page.dart';
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
        page = ListaReceitasPage();   // ⭐ NOVA PÁGINA: LISTA DE RECEITAS
        break;
      default:
        throw UnimplementedError("Página não existe");
    }

    final mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
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
                    selectedItemColor: colorScheme.primary,
                    unselectedItemColor: colorScheme.onSurfaceVariant,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calculate),
                        label: 'Contador',
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
                        icon: Icon(Icons.list_alt),  // ⭐ ÍCONE DA LISTA
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
                  onDestinationSelected: (value) {
                    setState(() => selectedIndex = value);
                  },
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  selectedLabelTextStyle: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate),
                      label: Text('Contador'),
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
                      icon: Icon(Icons.list_alt), // ⭐ LISTA
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
