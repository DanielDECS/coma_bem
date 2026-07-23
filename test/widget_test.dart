import 'package:flutter_test/flutter_test.dart';
import 'package:coma_bem/models/usuario.dart';
import 'package:coma_bem/models/experiencia.dart';

void main() {
  group('Testes Unitários - Modelos do ComaBem', () {

    test('Deve instanciar Usuario e converter de/para Map corretamente', () {
      final usuario = Usuario(
        id: 1,
        email: 'usuario@teste.com',
        senha: 'senha123',
      );

      final map = usuario.toMap();
      expect(map['email'], 'usuario@teste.com');
      expect(map['senha'], 'senha123');

      final usuarioFromMap = Usuario.fromMap(map);
      expect(usuarioFromMap.id, 1);
      expect(usuarioFromMap.email, 'usuario@teste.com');
    });

    test('Deve instanciar Experiencia e converter de/para Map corretamente', () {
      final experiencia = Experiencia(
        id: 10,
        usuarioId: 1,
        nomeRestaurante: 'Outback',
        tipoCulinaria: 'Australiana',
        pratoPrincipal: 'Ribs on the Barbie',
        recomendacao: 'Excelente atendimento e prato bem servido.',
        ranking: 5,
        cidadeUf: 'Curitiba, PR',
      );

      final map = experiencia.toMap();
      expect(map['nomeRestaurante'], 'Outback');
      expect(map['ranking'], 5);

      final expFromMap = Experiencia.fromMap(map);
      expect(expFromMap.id, 10);
      expect(expFromMap.usuarioId, 1);
      expect(expFromMap.pratoPrincipal, 'Ribs on the Barbie');
      expect(expFromMap.cidadeUf, 'Curitiba, PR');
    });

  });
}