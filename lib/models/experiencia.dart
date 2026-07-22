class Experiencia {
  final int? id;
  final int usuarioId;
  final String nomeRestaurante;
  final String tipoCulinaria;
  final String pratoPrincipal;
  final String recomendacao;
  final int ranking;
  final String? caminhoFoto;
  final double? latitude;
  final double? longitude;
  final String? cidadeUf;

  Experiencia({
    this.id,
    required this.usuarioId,
    required this.nomeRestaurante,
    required this.tipoCulinaria,
    required this.pratoPrincipal,
    required this.recomendacao,
    required this.ranking,
    this.caminhoFoto,
    this.latitude,
    this.longitude,
    this.cidadeUf,
  });

  // Converte o objeto Dart para Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuarioId': usuarioId,
      'nomeRestaurante': nomeRestaurante,
      'tipoCulinaria': tipoCulinaria,
      'pratoPrincipal': pratoPrincipal,
      'recomendacao': recomendacao,
      'ranking': ranking,
      'caminhoFoto': caminhoFoto,
      'latitude': latitude,
      'longitude': longitude,
      'cidadeUf': cidadeUf,
    };
  }

  // Cria o objeto Dart a partir do Map (retornado do SQLite)
  factory Experiencia.fromMap(Map<String, dynamic> map) {
    return Experiencia(
      id: map['id'] as int?,
      usuarioId: map['usuarioId'] as int,
      nomeRestaurante: map['nomeRestaurante'] as String,
      tipoCulinaria: map['tipoCulinaria'] as String,
      pratoPrincipal: map['pratoPrincipal'] as String,
      recomendacao: map['recomendacao'] as String,
      ranking: map['ranking'] as int,
      caminhoFoto: map['caminhoFoto'] as String?,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      cidadeUf: map['cidadeUf'] as String?,
    );
  }
}