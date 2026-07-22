import 'package:coma_bem/database/database_helper.dart';
import 'package:coma_bem/models/usuario.dart';

class AuthService {
  static Usuario? _usuarioLogado;

  // Retorna o usuário que está atualmente autenticado na sessão
  static Usuario? get usuarioLogado => _usuarioLogado;

  // Realiza o login consultando no SQLite
  Future<Usuario?> login(String email, String senha) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email.trim(), senha],
    );

    if (result.isNotEmpty) {
      _usuarioLogado = Usuario.fromMap(result.first);
      return _usuarioLogado;
    }
    return null;
  }

  // Cadastra um novo usuário caso o e-mail não exista
  Future<Usuario?> cadastrar(String email, String senha) async {
    final db = await DatabaseHelper.instance.database;

    // Verifica se já existe um usuário cadastrado com esse e-mail
    final existe = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim()],
    );

    if (existe.isNotEmpty) {
      throw Exception('E-mail já cadastrado.');
    }

    final id = await db.insert('usuarios', {
      'email': email.trim(),
      'senha': senha,
    });

    _usuarioLogado = Usuario(id: id, email: email.trim(), senha: senha);
    return _usuarioLogado;
  }

  // Encerra a sessão do usuário (Botão "Sair" na Tela 02)
  static void logout() {
    _usuarioLogado = null;
  }
}