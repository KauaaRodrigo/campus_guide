import 'package:flutter/material.dart';

/*
  create_page.dart
  - Página placeholder para a aba "Criar" do fluxo de eventos.
  - Atualmente contém um Scaffold simples com texto de placeholder.
  - Uso esperado: substituir por um formulário real de criação de evento
    e integração com backend/Firebase quando disponível.
*/

/// Página usada como aba "Criar" no `HomeShell`.
/// Substitua pelo formulário de criação real quando implementar.
class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Evento')),
      body: const Center(child: Text('Tela de criação (placeholder)')),
    );
  }
}
