import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/theme_state.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeState()),
      ],
      child: Consumer<ThemeState>(
        builder: (context, themeState, child) {
          return MaterialApp(
            title: 'Contador App',
            debugShowCheckedModeBanner: false,
            themeMode: themeState.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color.fromARGB(255, 224, 230, 237),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 255, 189, 6),
                brightness: Brightness.light,
                primary: const Color.fromARGB(255, 255, 189, 6),
                onPrimary: const Color.fromARGB(255, 16, 42, 67),
                secondary: const Color.fromARGB(255, 0, 60, 129),
                onSecondary: Colors.white,
                tertiary: const Color.fromARGB(255, 48, 173, 158),
                surface: Colors.white,
                onSurface: const Color.fromARGB(255, 16, 42, 67),
                error: const Color.fromARGB(255, 231, 111, 81),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 0, 60, 129),
                foregroundColor: Colors.white,
                centerTitle: true,
              ),
            ),

            //modo escuro
            darkTheme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color.fromARGB(255, 16, 42, 67),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 199, 147, 4),
                brightness: Brightness.dark,
                primary: Colors.white,
                onPrimary: const Color.fromARGB(255, 16, 42, 67),
                secondary: const Color.fromARGB(255, 199, 147, 4),
                onSecondary: Colors.white,
                tertiary: const Color.fromARGB(255, 48, 166, 151),
                surface: const Color.fromARGB(255, 79, 92, 105),
                onSurface: const Color.fromARGB(255, 240, 244, 248),
                error: const Color.fromARGB(255, 180, 85, 62),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 16, 42, 67),
                foregroundColor: Color.fromARGB(255, 255, 189, 6),
                centerTitle: true,
                elevation: 0,
              ),
            ),

            initialRoute: "/",
            routes: {
              "/": (context) => const HomePage(),
              "/cadastrar": (context) => const CadastrarReceitaPage(),
              "/receitas": (context) => const ListaReceitasPage(),
            },
          );
        },
      ),
    );
  }
}
