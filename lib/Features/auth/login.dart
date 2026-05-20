import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:campus_guide/routes/app_routes.dart';
import 'package:campus_guide/Features/auth/register.dart';
import 'package:campus_guide/Features/profile/profile_page.dart'; // import para tela de perfil
/// Widget que representa a tela de login.
///
/// - Exibe os campos de `email` e `senha` (controladores: `emailController`,
///   `senhalController`).
/// - O botão de confirmação valida o formulário e executa a navegação.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhalController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _carregando = false;

  void _login() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        final user = await _authService.logarUsuario(
          email: emailController.text,
          senha: senhalController.text,
        );

        if (user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login efetuado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Redireciona para a tela de perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
        
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
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                width: 350,
                height: 600,
                padding: const EdgeInsets.only(top: 40),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                  'Entrar',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Não tem uma conta?',
                                    style: TextStyle(fontSize: 12),
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
                                      'inscreva-se',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Register(),
                                        ),
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
                        opacity: 0.2,
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email (Institucional)',
                            labelStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'digite seu email';
                            }
                            return null;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 12),
                        child: Opacity(
                          opacity: 0.2,
                          child: TextFormField(
                            controller: senhalController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua senha';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 500,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _login,
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
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(top: 14),
                          overlayColor: Colors.transparent,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: const Color.fromARGB(
                            255,
                            48,
                            60,
                            231,
                          ),
                        ),
                        child: const Text(
                          ' Esqueci minha senha',
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {},
                      ),
                    ],
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
