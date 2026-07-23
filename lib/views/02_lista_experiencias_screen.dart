import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coma_bem/controllers/experiencia_controller.dart';
import 'package:coma_bem/models/experiencia.dart';
import 'package:coma_bem/services/auth_service.dart';
import 'package:coma_bem/views/00_login_screen.dart';
import 'package:coma_bem/views/03_cadastro_experiencia_screen.dart';

class ListaExperienciasScreen extends StatefulWidget {
  const ListaExperienciasScreen({super.key});

  @override
  State<ListaExperienciasScreen> createState() => _ListaExperienciasScreenState();
}

class _ListaExperienciasScreenState extends State<ListaExperienciasScreen> {
  final _controller = ExperienciaController();
  List<Experiencia> _experiencias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarExperiencias();
  }

  Future<void> _carregarExperiencias() async {
    setState(() => _carregando = true);
    final usuario = AuthService.usuarioLogado;
    if (usuario != null && usuario.id != null) {
      final lista = await _controller.buscarPorUsuario(usuario.id!);
      setState(() {
        _experiencias = lista;
        _carregando = false;
      });
    } else {
      setState(() => _carregando = false);
    }
  }

  void _fazerLogout() {
    AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildEstrelas(int ranking) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < ranking ? Icons.star : Icons.star_border,
          color: index < ranking ? Colors.green : Colors.grey,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Experiências'),
        actions: [
          TextButton(
            onPressed: _fazerLogout,
            child: const Text('Sair', style: TextStyle(color: Colors.green, fontSize: 16)),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _experiencias.isEmpty
          ? const Center(child: Text('Nenhuma experiência cadastrada ainda.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _experiencias.length,
        itemBuilder: (context, index) {
          final exp = _experiencias[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: exp.caminhoFoto != null && exp.caminhoFoto!.isNotEmpty
                        ? Image.file(
                      File(exp.caminhoFoto!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Conteúdo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.nomeRestaurante,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Tipo: ${exp.tipoCulinaria}', style: const TextStyle(fontSize: 13)),
                        Text('Prato: ${exp.pratoPrincipal}', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          'Recomendação:\n${exp.recomendacao}',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('Ranking: ', style: TextStyle(fontSize: 12)),
                            _buildEstrelas(exp.ranking),
                          ],
                        ),
                        if (exp.cidadeUf != null && exp.cidadeUf!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(exp.cidadeUf!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E6B34),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroExperienciaScreen()),
          );
          if (res == true) {
            _carregarExperiencias();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}