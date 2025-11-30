import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/receita.dart';
import '../models/receita_passo.dart';
import 'log_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'receitas_database.db');

    LogService().d("Abrindo banco de dados em: $path");

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    LogService().i("Criando tabelas do Banco de Dados (v$version)...");

    await db.execute(
      '''
      CREATE TABLE receitas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        passos TEXT NOT NULL,
        passoAtual INTEGER DEFAULT 0,
        repeticoesFeitasNoPasso INTEGER DEFAULT 0,
        dataInicio TEXT,
        dataUltimaAtualizacao TEXT,
        concluida INTEGER DEFAULT 0
      )
      ''',
    );
  }

  /// Migração do banco de dados
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    LogService().w("Atualizando DB da v$oldVersion para v$newVersion");

    if (oldVersion < 2) {
      // Adiciona coluna repeticoesFeitasNoPasso se não existir
      try {
        await db.execute(
          'ALTER TABLE receitas ADD COLUMN repeticoesFeitasNoPasso INTEGER DEFAULT 0',
        );
        LogService()
            .i("Migração v2: Coluna repeticoesFeitasNoPasso adicionada.");
      } catch (e) {
        // Coluna já existe, ignorar erro
        LogService().w("Migração v2: Coluna já existia ou erro ignorável: $e");
      }
    }
  }

  /// Salva uma nova receita no banco de dados
  /// dataInicio é deixado como NULL inicialmente (será preenchido apenas quando a receita for aberta)
  Future<int> salvarReceita(Receita receita) async {
    try {
      final db = await database;
      final now = DateTime.now();

      final result = await db.insert(
        'receitas',
        {
          'titulo': receita.titulo,
          'passos': jsonEncode(receita.passos.map((p) => p.toMap()).toList()),
          'passoAtual': receita.passoAtual,
          'repeticoesFeitasNoPasso': 0,
          'dataInicio': null,
          'dataUltimaAtualizacao': now.toIso8601String(),
          'concluida': receita.concluida ? 1 : 0,
        },
      );

      LogService()
          .i('Receita salva: "${receita.titulo}" (ID: $result)'); // LOG SUCESSO
      return result;
    } catch (e) {
      LogService().e("Erro ao salvar receita", e); // LOG ERRO
      rethrow;
    }
  }

  /// Carrega todas as receitas do banco de dados
  Future<List<Receita>> carregarReceitas() async {
    final db = await database;
    final maps = await db.query('receitas');

    LogService().d("Carregando ${maps.length} receitas do banco...");

    final receitas = List.generate(maps.length, (i) {
      final dataInicio = maps[i]['dataInicio'] != null
          ? DateTime.parse(maps[i]['dataInicio'] as String)
          : null;

      return Receita(
        id: maps[i]['id'] as int?,
        titulo: maps[i]['titulo'] as String,
        passos: _parsePassos(maps[i]['passos'] as String),
        passoAtual: maps[i]['passoAtual'] as int? ?? 0,
        repeticoesFeitasNoPasso:
            maps[i]['repeticoesFeitasNoPasso'] as int? ?? 0,
        dataInicio: dataInicio,
        dataUltimaAtualizacao: maps[i]['dataUltimaAtualizacao'] != null
            ? DateTime.parse(maps[i]['dataUltimaAtualizacao'] as String)
            : null,
        concluida: (maps[i]['concluida'] as int? ?? 0) == 1,
      );
    });

    return receitas;
  }

  /// Atualiza o progresso de uma receita. Se `dataInicioIso` for fornecido,
  /// também será gravado (útil na primeira atualização onde dataInicio era nula).
  Future<int> atualizarProgresso(
    int receitaId,
    int passoAtual,
    int repeticoesFeitasNoPasso,
    bool concluida, {
    String? dataInicioIso,
  }) async {
    final db = await database;

    final updateMap = <String, Object?>{
      'passoAtual': passoAtual,
      'repeticoesFeitasNoPasso': repeticoesFeitasNoPasso,
      'concluida': concluida ? 1 : 0,
      'dataUltimaAtualizacao': DateTime.now().toIso8601String(),
    };

    if (dataInicioIso != null) {
      updateMap['dataInicio'] = dataInicioIso;
    }

    LogService().d(
        'Atualizando ID=$receitaId: Passo $passoAtual, Rep $repeticoesFeitasNoPasso, Concluída: $concluida');

    return db.update(
      'receitas',
      updateMap,
      where: 'id = ?',
      whereArgs: [receitaId],
    );
  }

  /// Deleta uma receita do banco de dados
  Future<int> deletarReceita(int receitaId) async {
    final db = await database;

    LogService().w("Deletando receita ID: $receitaId");

    return db.delete(
      'receitas',
      where: 'id = ?',
      whereArgs: [receitaId],
    );
  }

  /// Carrega uma receita específica pelo ID
  Future<Receita?> carregarReceitaById(int receitaId) async {
    final db = await database;
    final maps = await db.query(
      'receitas',
      where: 'id = ?',
      whereArgs: [receitaId],
    );

    if (maps.isEmpty) {
      LogService().w("Busca por ID $receitaId não encontrou nada.");
      return null;
    }

    final map = maps.first;
    return Receita(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      passos: _parsePassos(map['passos'] as String),
      passoAtual: map['passoAtual'] as int? ?? 0,
      repeticoesFeitasNoPasso: map['repeticoesFeitasNoPasso'] as int? ?? 0,
      dataInicio: map['dataInicio'] != null
          ? DateTime.parse(map['dataInicio'] as String)
          : null,
      dataUltimaAtualizacao: map['dataUltimaAtualizacao'] != null
          ? DateTime.parse(map['dataUltimaAtualizacao'] as String)
          : null,
      concluida: (map['concluida'] as int? ?? 0) == 1,
    );
  }

  /// Auxilia no parse de passos JSON
  List<ReceitaPasso> _parsePassos(String passosJson) {
    try {
      final List<dynamic> decoded = jsonDecode(passosJson);
      return decoded
          .map((p) => ReceitaPasso.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LogService().e("Erro crítico ao converter JSON dos passos", e);
      return [];
    }
  }

  /// Fecha a conexão com o banco de dados (opcional)
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    LogService().i("Conexão com Banco de Dados encerrada.");
  }

  /// Deleta todas as receitas do banco de dados
  Future<int> deletarTodasReceitas() async {
    final db = await database;
    LogService().w("ATENÇÃO: Todas as receitas estão sendo apagadas!");
    return db.delete('receitas');
  }
}
