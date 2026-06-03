import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:campus_guide/routes/app_routes.dart';
import 'recuperar_senha.dart';
/// Tela de login do aplicativo.
///
/// - Usa um `Form` com validação simples para `email` e `senha`.
/// - Ao submeter com sucesso, chama `AuthService.logarUsuario` e navega
///   para a rota home (`AppRoutes.home`).
/// - Mensagens de sucesso/erro são exibidas via `SnackBar`.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  // Chave para acessar e validar o formulário.
  final _formkey = GlobalKey<FormState>();

  // Controladores para os campos de entrada.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhalController = TextEditingController();

  // Serviço responsável pela autenticação (encapsula Firebase/REST etc.).
  final AuthService _authService = AuthService();

  // Indica se uma requisição de autenticação está em andamento.
  bool _carregando = false;

  /// Tenta autenticar o usuário com os valores dos controladores.
  ///
  /// - Valida o formulário antes de enviar.
  /// - Exibe um `SnackBar` em caso de sucesso ou erro.
  /// - Desabilita o botão enquanto a requisição está em andamento.
  void _login() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        // Chamada ao serviço de autenticação. Espera-se que `logarUsuario`
        // retorne um objeto usuário (ou `null` em caso de falha silenciosa).
        final user = await _authService.logarUsuario(
          email: emailController.text,
          senha: senhalController.text,
        );

        // Se houve retorno válido e o widget ainda está montado, navega.
        if (user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login efetuado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Remove todas as rotas anteriores e vai para a home.
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
      } catch (e) {
        // Em caso de erro, mostra a mensagem (limpa o prefixo 'Exception:').
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Garantir que o estado de carregamento volte para false.
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
      // O `SingleChildScrollView` evita overflow quando o teclado abre.
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo no topo da tela.
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

              // Container central com o formulário de login.
              Container(
                alignment: Alignment.topCenter,
                width: 350,
                height: 600,
                padding: const EdgeInsets.all(0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título e link para registro.
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Não tem uma conta?',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  // Botão para ir à tela de registro.
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
                                      'Inscreva-se',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.register,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Campo de email.
                      // Observação: Opacidade está baixa (0.2) — verificar se é
                      // intenção de design ou bug de estilo.
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
                              return 'digite seu email';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Campo de senha.
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 12),
                        child: Opacity(
                          opacity: 0.6,
                          child: TextFormField(
                            controller: senhalController,
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
                                return 'Digite sua senha';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      // Botão principal de envio.
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
                          // Enquanto carrega, mostra `CircularProgressIndicator`.
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

                      // Link para recuperação de senha (ainda sem implementação).
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecuperarSenha(),
                            ),
                          );
                        },
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
