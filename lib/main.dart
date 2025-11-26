import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/cadastrar_receita_page.dart';
import 'pages/home_page.dart';
import 'pages/lista_receitas_page.dart';
import 'state/counter_app_state.dart';
import 'state/receita_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterAppState()),
        ChangeNotifierProvider(create: (_) => ReceitaState()),
      ],
      child: MaterialApp(
        title: 'Contador App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 11, 113, 131),
          ),
        ),
        initialRoute: "/",
        routes: {
          "/": (context) => const HomePage(),
          "/cadastrar": (context) => const CadastrarReceitaPage(),
          "/receitas": (context) => const ListaReceitasPage(),
        },
      ),
    );
  }
}
