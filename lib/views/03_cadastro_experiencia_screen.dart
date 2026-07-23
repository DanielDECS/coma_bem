import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coma_bem/controllers/experiencia_controller.dart';
import 'package:coma_bem/models/experiencia.dart';
import 'package:coma_bem/services/auth_service.dart';

class CadastroExperienciaScreen extends StatefulWidget {
  const CadastroExperienciaScreen({super.key});

  @override
  State<CadastroExperienciaScreen> createState() => _CadastroExperienciaScreenState();
}

class _CadastroExperienciaScreenState extends State<CadastroExperienciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ExperienciaController();

  final _restauranteCtrl = TextEditingController();
  final _culinariaCtrl = TextEditingController();
  final _pratoCtrl = TextEditingController();
  final _recomendacaoCtrl = TextEditingController();

  int _ranking = 0;
  String? _caminhoFoto;
  double? _latitude;
  double? _longitude;
  String? _cidadeUf;

  bool _carregandoGps = false;
  bool _salvando = false;

  Future<void> _selecionarFoto() async {
    final path = await _controller.tirarFoto();
    if (path != null) {
      setState(() => _caminhoFoto = path);
    }
  }

  Future<void> _capturarGps() async {
    setState(() => _carregandoGps = true);
    try {
      final loc = await _controller.capturarLocalizacaoGPS();
      setState(() {
        _latitude = loc['latitude'];
        _longitude = loc['longitude'];
        _cidadeUf = loc['cidadeUf'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Localização obtida: $_cidadeUf')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de GPS: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoGps = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ranking == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma nota no Ranking!')),
      );
      return;
    }

    final usuario = AuthService.usuarioLogado;
    if (usuario == null || usuario.id == null) return;

    setState(() => _salvando = true);

    final exp = Experiencia(
      usuarioId: usuario.id!,
      nomeRestaurante: _restauranteCtrl.text.trim(),
      tipoCulinaria: _culinariaCtrl.text.trim(),
      pratoPrincipal: _pratoCtrl.text.trim(),
      recomendacao: _recomendacaoCtrl.text.trim(),
      ranking: _ranking,
      caminhoFoto: _caminhoFoto,
      latitude: _latitude,
      longitude: _longitude,
      cidadeUf: _cidadeUf,
    );

    await _controller.salvarExperiencia(exp);

    if (mounted) {
      setState(() => _salvando = false);
      Navigator.pop(context, true);
    }
  }

  Widget _buildSeletorEstrelas() {
    return Row(
      children: List.generate(5, (index) {
        final estrelaNum = index + 1;
        return IconButton(
          icon: Icon(
            estrelaNum <= _ranking ? Icons.star : Icons.star_border,
            color: estrelaNum <= _ranking ? Colors.green : Colors.grey,
            size: 32,
          ),
          onPressed: () => setState(() => _ranking = estrelaNum),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Experiência', style: TextStyle(color: Color(0xFF2E6B34))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do Restaurante
              const Text('Nome do Restaurante', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _restauranteCtrl,
                decoration: const InputDecoration(hintText: 'Digite o nome do restaurante', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Tipo de Culinária
              const Text('Tipo de Culinária', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _culinariaCtrl,
                decoration: const InputDecoration(hintText: 'Digite o tipo de culinária', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Prato Principal
              const Text('Prato Principal', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _pratoCtrl,
                decoration: const InputDecoration(hintText: 'Digite o prato principal', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Recomendação
              const Text('Recomendação', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _recomendacaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Conte sua recomendação', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Ranking
              const Text('Ranking', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildSeletorEstrelas(),
              const SizedBox(height: 16),

              // Foto
              const Text('Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _selecionarFoto,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _caminhoFoto != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_caminhoFoto!), fit: BoxFit.cover),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      SizedBox(width: 8),
                      Text('Adicionar Foto'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Localização GPS
              const Text('Localização (GPS)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _carregandoGps ? null : _capturarGps,
                  icon: const Icon(Icons.location_on, color: Colors.black87),
                  label: _carregandoGps
                      ? const CircularProgressIndicator()
                      : Text(_cidadeUf ?? 'Capturar Localização', style: const TextStyle(color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6B34)),
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}