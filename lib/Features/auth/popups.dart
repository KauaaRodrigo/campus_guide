import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:campus_guide/routes/app_routes.dart';
import 'package:campus_guide/Features/auth/login.dart';
class Popups {
  /// Mostra um diálogo de aguardando confirmação de e-mail.
  ///
  /// - Exibe um diálogo não-dispensável que aguarda por um tempo (timer).
  /// - Se o timer expirar, fecha o diálogo atual e abre o diálogo
  ///   `naoEncontrado` para indicar falha na confirmação.
  /// - Possui ação para reenviar/avançar que manipula a navegação para
  ///   a tela de `Login` quando necessário.
  void esperandoConfirmacao(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    Timer? checkTimer;
    Timer? timeoutTimer;
    int tempoRestante = 60;

    if (user != null && !user.emailVerified) {
      user.sendEmailVerification().catchError((e) {
        debugPrint("Erro ao enviar e-mail: $e");
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
          user = auth.currentUser;
          if (user != null) {
            await user!.reload();

            if (auth.currentUser!.emailVerified) {
              timer.cancel();
              timeoutTimer?.cancel();
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
                encontrado(context);
              }
            }
          }
        });

        timeoutTimer = Timer(Duration(seconds: tempoRestante), () {
          checkTimer?.cancel();
          if (Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext); 
            naoEncontrado(context); 
          }
        });

        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 27, 93, 146),
              width: 12,
            ),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 320,
            height: 190,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 110),
                          child: Icon(Icons.error_outline),
                        ),
                        IconButton(
                          style:
                              IconButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ).copyWith(
                                overlayColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                          onPressed: () {
                            checkTimer?.cancel();
                            timeoutTimer?.cancel();
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(Icons.close),
                          iconSize: 15,
                        ),
                      ],
                    ),
                    Text(
                      'Esperando confirmação...',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Enviamos um link de confirmação para seu',
                      style: TextStyle(fontSize: 13),
                    ),
                    const Text(
                      'email institucional.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const Text(
                      'Confirme seu email para prosseguir.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 240,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 203, 195, 195),
                  ),
                  child: Center(
                    child: Text(
                      "Aguardando...",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color.fromARGB(255, 114, 114, 114),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 18.0),
          actions: [
            Align(
              alignment: Alignment.topCenter,
              child: TextButton(
                style:
                    TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashFactory: NoSplash.splashFactory,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                child: const Text(
                  "Reenviar email",
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () async {
                  if (user != null) {
                    await user!.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('E-mail de confirmação reenviado!'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Mostra o diálogo indicando que o e-mail não foi confirmado.
  ///
  /// - O botão "Voltar" fecha o diálogo atual e redireciona para
  ///   a tela de login via `Navigator.pushReplacementNamed(context, AppRoutes.login)`.
  void naoEncontrado(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(
            top: 0,
            bottom: 35,
            right: 0,
            left: 0,
          ),
          shape: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 27, 93, 146),
              width: 12,
            ),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 320,
            height: 135,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_outlined, size: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Email não confirmado',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                    'Não foi possível confirmar seu e-mail a tempo.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    'Verifique sua caixa de entrada e tente de novo.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 240,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 219, 3, 3),
                ),
                child: TextButton(
                  style:
                      TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        splashFactory: NoSplash.splashFactory,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Text(
                    "Voltar",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      dialogContext,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Mostra o diálogo indicando que o e-mail foi confirmado com sucesso.
  ///
  /// - O botão "Avançar" fecha o diálogo atual e redireciona para
  ///   a tela de login via `Navigator.pushReplacementNamed(context, AppRoutes.login)`.
  void encontrado(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(
            top: 0,
            bottom: 35,
            right: 0,
            left: 0,
          ),
          shape: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 27, 93, 146),
              width: 12,
            ),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 320,
            height: 135,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Email confirmed',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                    'Seu email foi confirmado com sucesso!',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    'Você já pode prosseguir.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 240,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 1, 38, 202),
                ),
                child: TextButton(
                  style:
                      TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        splashFactory: NoSplash.splashFactory,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Text(
                    "Avançar",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      dialogContext,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
