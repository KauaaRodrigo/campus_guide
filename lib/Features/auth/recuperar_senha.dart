import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campus_guide/Features/auth/login.dart';

// 1. TELA DE INÍCIO: DIGITAR E-MAIL
class RecuperarSenha extends StatefulWidget {
  const RecuperarSenha({super.key});
  @override
  State<RecuperarSenha> createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Image.asset(
                  'imagens/CampusGuide_png.png',
                  width: 400,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recuperar senha',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Insira seu email institucional. Enviaremos um link de redefinição.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Opacity(
                      opacity: 0.6,
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email (Institucional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            48,
                            60,
                            231,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim(),
                          );
                          if (!mounted) return;
                          // Ao enviar, vai para a tela de espera que já inicia o contador
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AguardandoRecuperacao(),
                            ),
                          );
                        },
                        child: const Text(
                          'Enviar Link',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. TELA DE ESPERA: ALERTA EM 15s, DURAÇÃO DE 3s
class AguardandoRecuperacao extends StatefulWidget {
  const AguardandoRecuperacao({super.key});
  @override
  State<AguardandoRecuperacao> createState() => _AguardandoRecuperacaoState();
}

class _AguardandoRecuperacaoState extends State<AguardandoRecuperacao> {
  @override
  void initState() {
    super.initState();
    // Inicia o contador de 15 segundos assim que a tela abre
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) _dispararAlertaSucesso();
    });
  }

  void _dispararAlertaSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Fecha o alerta automaticamente após 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
            );
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified, color: Colors.green, size: 60),
              SizedBox(height: 15),
              Text(
                'Senha alterada!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.mark_email_read_outlined,
                size: 70,
                color: Color.fromARGB(255, 48, 60, 231),
              ),
              SizedBox(height: 20),
              Text(
                'E-mail enviado!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Por favor, verifique sua caixa de entrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
