# flutter_application_uni2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 📘 Estrutura do Projeto

Abaixo está a explicação completa da função de cada pasta e arquivo do projeto.
```
lib/
├─ main.dart
├─ state/
│ └─ counter_app_state.dart
├─ pages/
│ ├─ home_page.dart
│ ├─ counter_page.dart
│ └─ history_page.dart
└─ widgets/
└─ big_counter_card.dart
```


---

## 📁 **main.dart**
Arquivo principal do Flutter.  
Responsável por:

- iniciar o app com `runApp()`
- configurar o Provider (`ChangeNotifierProvider`)
- definir tema e cores
- carregar `HomePage` como primeira tela

É o ponto de entrada da aplicação.

---

## 📁 **state/**

### `counter_app_state.dart`
Gerencia todo o **estado global** do app usando Provider.

Contém:
- `counter` → valor do contador  
- `history` → lista com valores anteriores  
- Métodos que atualizam o estado:  
  - `increment()`  
  - `decrement()`  
  - `reset()`  
  - `clearHistory()`  

Cada atualização chama `notifyListeners()`, permitindo que as telas atualizem automaticamente.

---

## 📁 **pages/**

### `home_page.dart`
Página principal do app, responsável por:

- controlar a navegação entre **CounterPage** e **HistoryPage**
- detectar o tamanho da tela e escolher entre:
  - `BottomNavigationBar` (celular)
  - `NavigationRail` (tablet/desktop)
- animar a troca de páginas com `AnimatedSwitcher`

Serve como “hub” da aplicação.

---

### `counter_page.dart`
Tela onde o usuário interage com o contador:

- incrementa  
- decrementa  
- zera  
- visualiza o valor em destaque usando `BigCounterCard`

Ela usa `context.watch<CounterAppState>()` para acessar o estado.

---

### `history_page.dart`
Exibe a lista de valores registrados durante o uso do contador.

Possui:
- número total de registros
- lista estilizada com cartões
- botão de "Limpar histórico"

---

## 📁 **widgets/**

### `big_counter_card.dart`
Widget reutilizável que mostra o contador em um cartão estilizado.

- animação com `AnimatedSize`
- texto grande e destacado
- mantém a interface organizada separando componentes

---
