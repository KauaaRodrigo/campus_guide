import 'package:flutter/material.dart';

import '../../Components/navigation/bottom_nav_bar.dart';
import 'home.dart';
import 'create_page.dart';
import 'my_events_page.dart';
import 'package:campus_guide/features/profile/profile_page.dart';
import '../auth/auth_service.dart';
import '../auth/user.dart';

/// Container que mantém as principais abas e a AppBottomNavBar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  AppUser? usuario;
  bool carregando = true;

  /// Incrementado toda vez que a aba Home (índice 0) fica visível.
  /// HomePage observa esse valor via didUpdateWidget e recarrega os eventos.
  int _homeReloadToken = 0;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final user = await AuthService().buscarUsuarioAtual();

    if (!mounted) return;

    setState(() {
      usuario = user;
      carregando = false;
    });
  }

  void _onTabTap(int i) {
    setState(() {
      if (i == 0) {
        _homeReloadToken++;
      }

      currentIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDocente = usuario?.role == 'docente';

    final pages = isDocente
        ? <Widget>[
            HomePage(reloadToken: _homeReloadToken),
            const CreatePage(),
            const MyEventsPage(),
            const ProfilePage(showBottomNavigationBar: false),
          ]
        : <Widget>[
            HomePage(reloadToken: _homeReloadToken),
            const MyEventsPage(),
            const ProfilePage(showBottomNavigationBar: false),
          ];

    // Evita índices inválidos caso a quantidade de abas mude
    if (currentIndex >= pages.length) {
      currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTap,
        isDocente: isDocente,
      ),
    );
  }
}
