/*
  Entrada do aplicativo e configuração do `MaterialApp`.

  - Inicializa o Firebase.
  - Define `initialRoute` e `onGenerateRoute` apontando para `AppRouter`.

  Observação: atualmente `AppRoutes.home` está mapeado para `ProfilePage`, por
  isso o app inicia nessa tela. Para iniciar em `Login` altere
  `initialRoute: AppRoutes.login` ou adicione um guard de autenticação. Feito
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// Widget raiz do aplicativo.
///
/// Define as configurações globais do `MaterialApp` (debug banner, rota
/// inicial e gerador de rotas). Em projetos reais você pode injetar um
/// provedor de autenticação aqui para escolher a rota inicial dinamicamente.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 17),
          titleLarge: TextStyle(fontSize: 24),
          labelLarge: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}