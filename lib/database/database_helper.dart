import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('comabem.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Habilita a verificação de Chaves Estrangeiras (Foreign Keys) no SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

// Definição das Tabelas
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realTypeNullable = 'REAL';
    const intType = 'INTEGER NOT NULL';

    // 1. Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id $idType,
        email $textType UNIQUE,
        senha $textType
      )
    ''');

    // 2. Tabela de Experiências
    await db.execute('''
      CREATE TABLE experiencias (
        id $idType,
        usuarioId $intType,
        nomeRestaurante $textType,
        tipoCulinaria $textType,
        pratoPrincipal $textType,
        recomendacao $textType,
        ranking $intType,
        caminhoFoto $textTypeNullable,
        latitude $realTypeNullable,
        longitude $realTypeNullable,
        cidadeUf $textTypeNullable,
        FOREIGN KEY (usuarioId) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}