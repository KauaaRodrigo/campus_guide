/*
  Tela de registro de usuário.

  Formulário básico para coletar matrícula, email institucional e senha.
  Este arquivo usa `Popups` para mostrar o fluxo de confirmação de email
  (método `esperandoConfirmacao`) — o popup gerencia o redirecionamento
  posterior para a tela de login.
*/
import 'package:campus_guide/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'popups.dart';

/// Widget de cadastro.
///
/// - Valida matrícula, email e senha de forma local.
/// - Ao enviar o formulário com sucesso chama `Popups.esperandoConfirmacao`
///   que apresenta ao usuário o próximo passo (confirmação por email) e
///   o redireciona para a tela de login quando aplicável.
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _carregando = false;

  void _registrar() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        await _authService.cadastrarUsuario(
          matricula: matriculaController.text,
          email: emailController.text,
          senha: senhaController.text,
        );

        if (!mounted) return;

        Popups popup = Popups();
        popup.esperandoConfirmacao(context);

        matriculaController.clear();
        emailController.clear();
        senhaController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'imagens/CampusGuide_png.png',
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Container(
                  alignment: Alignment.topCenter,
                  width: 350,
                  height: 600,
                  padding: const EdgeInsets.only(top: 40),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 17, bottom: 20),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'Cadastre-se',
                                    style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    const Text(
                                      'Já tem uma conta?',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(left: 3),
                                        overlayColor: Colors.transparent,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        foregroundColor: const Color.fromARGB(
                                          255,
                                          48,
                                          60,
                                          231,
                                        ),
                                      ),
                                      child: const Text(
                                        'Entre',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Opacity(
                          opacity: 0.6,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: matriculaController,
                            decoration: InputDecoration(
                              labelText: 'Matrícula',
                              labelStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua matrícula';
                              }
                              if (value.length < 4) return 'Matrícula inválida';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Opacity(
                          opacity: 0.6,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email (Institucional)',
                              labelStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o email';
                              }
                              if (!value.contains('@')) return 'Email invalido';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Opacity(
                          opacity: 0.6,
                          child: TextFormField(
                            controller: senhaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite a senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: 500,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _registrar,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                48,
                                60,
                                231,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Avançar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
