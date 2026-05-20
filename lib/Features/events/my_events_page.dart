import 'package:flutter/material.dart';

/*
  my_events_page.dart
  - Página que exibirá apenas os eventos em que o usuário está inscrito.
  - Implementação atual é um placeholder; quando integrado com auth/DB,
    deve filtrar a lista de eventos pelo usuário atual.
*/

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Eventos')),
      body: const Center(child: Text('Eventos em que o usuário está inscrito (placeholder)')),
    );
  }
}
