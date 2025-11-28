import 'package:flutter/material.dart';
import '../models/receita_passo.dart';
import '../models/receita.dart';
import '../services/database_service.dart';

class ReceitaState extends ChangeNotifier {
  List<ReceitaPasso> passosTemp = [];
  List<Receita> receitas = [];
  final DatabaseService _db = DatabaseService();
  Receita? receitaEmEdicao; // Receita atualmente em progresso

  // Construtor: carrega receitas ao iniciar
  ReceitaState() {
    carregarReceitasDoBancoDados();
  }

  /// Carrega todas as receitas do banco de dados
  Future<void> carregarReceitasDoBancoDados() async {
    receitas = await _db.carregarReceitas();
    notifyListeners();
  }

  /// Adiciona um passo temporário (durante o cadastro)
  void adicionarPasso(ReceitaPasso passo) {
    passosTemp.add(passo);
    notifyListeners();
  }

  /// Limpa passos temporários
  void limparPassos() {
    passosTemp.clear();
    notifyListeners();
  }

  /// Salva uma nova receita no banco de dados
  Future<void> salvarReceita(String titulo) async {
    if (titulo.isEmpty || passosTemp.isEmpty) return;

    final novaReceita = Receita(
      titulo: titulo,
      passos: List.from(passosTemp),
    );

    final id = await _db.salvarReceita(novaReceita);
    
    // Adiciona à lista com o ID gerado
    receitas.add(
      novaReceita.copyWith(id: id.toInt()),
    );

    limparPassos();
    notifyListeners();
  }

  /// Carrega uma receita para edição/visualização de progresso
  /// Carrega do BD para garantir que os dados são os mais recentes
  Future<void> carregarReceitaParaEdicao(int receitaId) async {
    // Primeiro tenta carregar do BD para garantir dados atualizados
    final receitaDB = await _db.carregarReceitaById(receitaId);
    if (receitaDB != null) {
      receitaEmEdicao = receitaDB;
      print('DEBUG carregarReceitaParaEdicao: Carregada do BD - ID=$receitaId, dataInicio=${receitaDB.dataInicio}');
    } else {
      // Fallback: carrega da lista em memória
      receitaEmEdicao = receitas.firstWhere((r) => r.id == receitaId);
      print('DEBUG carregarReceitaParaEdicao: Carregada da memória - ID=$receitaId, dataInicio=${receitaEmEdicao?.dataInicio}');
    }
    notifyListeners();
  }

  /// Atualiza o passo atual e as repetições feitas, salvando no BD
  Future<void> atualizarProgressoCompleto(
    int novoPassoAtual,
    int repeticoesFeitasNoPasso,
  ) async {
    if (receitaEmEdicao == null) return;

    final now = DateTime.now();
    
    // Se ainda não tem dataInicio, marca agora como iniciada
    final dataInicio = receitaEmEdicao!.dataInicio ?? now;
    
    print('DEBUG atualizarProgressoCompleto: ID=${receitaEmEdicao!.id}, dataInicio=${receitaEmEdicao!.dataInicio}, nova dataInicio=$dataInicio');

    receitaEmEdicao = receitaEmEdicao!.copyWith(
      passoAtual: novoPassoAtual,
      repeticoesFeitasNoPasso: repeticoesFeitasNoPasso,
      dataInicio: dataInicio,
      dataUltimaAtualizacao: now,
    );
    
    if (receitaEmEdicao!.id != null) {
      // Salva tudo no BD de uma vez, inclusive dataInicio
      await _db.atualizarProgresso(
        receitaEmEdicao!.id!,
        novoPassoAtual,
        repeticoesFeitasNoPasso,
        receitaEmEdicao!.concluida,
        dataInicioIso: dataInicio.toIso8601String(),
      );
      
      // Atualiza na lista de receitas imediatamente
      final index = receitas.indexWhere((r) => r.id == receitaEmEdicao!.id);
      if (index != -1) {
        receitas[index] = receitaEmEdicao!;
      }
    }
    
    notifyListeners();
  }

  /// Marca uma receita como concluída
  Future<void> marcarComoConcluida(int receitaId) async {
    final index = receitas.indexWhere((r) => r.id == receitaId);
    if (index != -1) {
      final receita = receitas[index];
      receitas[index] = receita.copyWith(
        concluida: true,
        dataUltimaAtualizacao: DateTime.now(),
      );
      
      if (receita.id != null) {
          await _db.atualizarProgresso(
            receita.id!,
            receita.passos.length - 1,
            receita.repeticoesFeitasNoPasso,
            true,
            dataInicioIso: receita.dataInicio?.toIso8601String(),
          );
        
        // Atualiza receitaEmEdicao também
        if (receitaEmEdicao?.id == receitaId) {
          receitaEmEdicao = receitas[index];
        }
      }
      notifyListeners();
    }
  }

  /// Excluir receita salva
  Future<void> excluirReceita(int receitaId) async {
    if (receitaId > 0) {
      await _db.deletarReceita(receitaId);
    }
    receitas.removeWhere((r) => r.id == receitaId);
    notifyListeners();
  }

  /// Limpa o histórico: remove receitas do histórico (apaga dataInicio)
  Future<void> limparHistorico() async {
    if (receitas.isEmpty) return;
    
    print('DEBUG limparHistorico: Iniciando limpeza...');
    
    // Atualiza no BD: reseta dataInicio para todas as receitas
    final db = await _db.database;
    final result = await db.update(
      'receitas',
      {
        'dataInicio': null,
        'dataUltimaAtualizacao': null,
      },
      where: 'dataInicio IS NOT NULL',
    );
    
    print('DEBUG limparHistorico: $result receitas atualizadas no BD');
    
    // Recarrega do BD para garantir sincronização perfeita
    receitas = await _db.carregarReceitas();
    receitaEmEdicao = null;
    
    print('DEBUG limparHistorico: Receitas recarregadas. Total=${receitas.length}');
    notifyListeners();
  }

  /// Limpa a receita em edição e recarrega todas as receitas do BD
  Future<void> limparReceitaEmEdicao() async {
    receitaEmEdicao = null;
    // Recarrega do BD para garantir sincronização
    await carregarReceitasDoBancoDados();
    print('DEBUG limparReceitaEmEdicao: Receitas recarregadas do BD');
    notifyListeners();
  }
}
