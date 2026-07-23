import 'package:coma_bem/database/database_helper.dart';
import 'package:coma_bem/models/experiencia.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ExperienciaController {
  final ImagePicker _picker = ImagePicker();
  final Geocoding _geocoding = Geocoding();

  // Salva uma nova experiência no SQLite
  Future<int> salvarExperiencia(Experiencia experiencia) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('experiencias', experiencia.toMap());
  }

  // Busca apenas as experiências do usuário logado
  Future<List<Experiencia>> buscarPorUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'experiencias',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );

    return result.map((map) => Experiencia.fromMap(map)).toList();
  }

  // Exclui uma experiência pelo ID
  Future<int> deletarExperiencia(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'experiencias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Captura foto da câmera ou seleciona da galeria
  Future<String?> tirarFoto({bool daGaleria = false}) async {
    final XFile? photo = await _picker.pickImage(
      source: daGaleria ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 80,
    );

    return photo?.path;
  }

  // Captura localização GPS e retorna latitude, longitude e Cidade/UF
  Future<Map<String, dynamic>> capturarLocalizacaoGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissões de localização permanentemente negadas.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    String cidadeUf = "Localização Capturada";

    try {
      final List<Placemark> placemarks =
      await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final String cidade =
            place.subAdministrativeArea ?? place.locality ?? '';

        final String estado =
            place.administrativeArea ?? '';

        if (cidade.isNotEmpty && estado.isNotEmpty) {
          cidadeUf = "$cidade, $estado";
        }
      }
    } catch (e) {
      // Mantém o valor padrão caso não seja possível converter
      // as coordenadas para Cidade/UF.
    }

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'cidadeUf': cidadeUf,
    };
  }
}