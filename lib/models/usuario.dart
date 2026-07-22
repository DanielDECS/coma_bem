class Usuario {
  final int? id;
  final String email;
  final String senha;

  Usuario({
    this.id,
    required this.email,
    required this.senha,
  });

  // Converte o objeto Dart para Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'senha': senha,
    };
  }

  // Cria o objeto Dart a partir do Map (retornado do SQLite)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      email: map['email'] as String,
      senha: map['senha'] as String,
    );
  }
}