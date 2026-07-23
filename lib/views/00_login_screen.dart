import 'package:flutter/material.dart';
import 'package:coma_bem/services/auth_service.dart';
import 'package:coma_bem/views/01_splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();

  bool _obscureSenha = true;
  bool _carregando = false;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final email = _emailController.text.trim();
      final senha = _senhaController.text;

      var usuario = await _authService.login(email, senha);

      // Se usuário não existe, tenta cadastrar automaticamente para agilizar o teste
      if (usuario == null) {
        usuario = await _authService.cadastrar(email, senha);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada e autenticada com sucesso!')),
          );
        }
      }

      if (mounted && usuario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao autenticar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo do ComaBem
                  Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.restaurant_menu,
                      size: 100,
                      color: Color(0xFF2E6B34),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo E-mail
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Digite seu e-mail',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Informe seu e-mail';
                      if (!val.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Senha
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Senha', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscureSenha,
                    decoration: InputDecoration(
                      hintText: 'Digite sua senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Informe sua senha';
                      if (val.length < 4) return 'A senha deve ter no mínimo 4 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _fazerLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6B34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _carregando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}