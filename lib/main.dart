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
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'crudEvent/event_controller.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => EventController())],
      child: const MyApp(),
    ),
  );
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
      // Localização — necessária para DatePicker em português
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      // Sistema de rotas dos colaboradores — mantido intacto
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
