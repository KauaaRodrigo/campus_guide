import 'package:flutter/material.dart';

import 'package:campus_guide/Features/auth/auth_service.dart';
import 'package:campus_guide/Features/auth/user.dart';
import 'package:campus_guide/Features/profile/edit_profile_page.dart';
import 'package:campus_guide/components/buttons/primary_button.dart';
import 'package:campus_guide/components/dialogs/logout_dialog.dart';
import 'package:campus_guide/components/navigation/bottom_nav_bar.dart';
import 'package:campus_guide/crudEvent/enrollment_repository.dart';
import 'package:campus_guide/crudEvent/event_model.dart';
import 'package:campus_guide/crudEvent/event_repository.dart';
import 'package:campus_guide/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  final bool showBottomNavigationBar;

  const ProfilePage({super.key, this.showBottomNavigationBar = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _profileImageAsset = 'imagens/Icone_perfil.png';

  final AuthService _authService = AuthService();
  final EnrollmentRepository _enrollmentRepository = EnrollmentRepository();
  final EventRepository _eventRepository = EventRepository();

  late Future<_ProfileData> _profileFuture;
  int currentIndex = 3;
  bool showHistory = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  void _reloadUser() {
    setState(() {
      _profileFuture = _loadProfileData();
    });
  }

  Future<_ProfileData> _loadProfileData() async {
    final user = await _authService.buscarUsuarioAtual();
    if (user == null) return const _ProfileData();

    final history = await _loadHistory(user.id);
    return _ProfileData(user: user, history: history);
  }

  Future<List<EventModel>> _loadHistory(String userID) async {
    final eventIds = await _enrollmentRepository.buscarEventoIdsPorUsuario(
      userID,
    );
    if (eventIds.isEmpty) return [];

    final events = await Future.wait(
      eventIds.map(_eventRepository.buscarPorId),
    );
    final now = DateTime.now();

    final history =
        events
            .whereType<EventModel>()
            .where((event) => !event.dataInicio.isAfter(now))
            .toList()
          ..sort((a, b) => b.dataInicio.compareTo(a.dataInicio));

    return history;
  }

  Future<void> _logout() async {
    await _authService.deslogar();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _openEditProfile(AppUser? user) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );

    if (updated == true) {
      _reloadUser();
    }
  }

  String _displayName(AppUser? user) {
    final name = user?.name.trim() ?? '';
    return name.isEmpty ? 'Usuário' : name;
  }

  String _historyDate(EventModel event) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    final date = event.dataInicio;
    return '${date.day.toString().padLeft(2, '0')}\n${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.showBottomNavigationBar
          ? AppBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Meu Perfil",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 40),
                _buildProfileInfo(),
                const SizedBox(height: 50),
                _buildOption(
                  icon: Icons.history,
                  title: "Histórico",
                  onTap: () {
                    setState(() {
                      if (!showHistory) {
                        _profileFuture = _loadProfileData();
                      }
                      showHistory = !showHistory;
                    });
                  },
                ),
                const Divider(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: showHistory ? 320 : 0,
                  child: _buildHistory(),
                ),
                _buildOption(
                  icon: Icons.logout,
                  title: "Sair",
                  iconColor: Colors.red,
                  showArrow: false,
                  onTap: () {
                    LogoutDialog.show(context, onConfirm: _logout);
                  },
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return FutureBuilder<_ProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final user = snapshot.data?.user;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  Text(
                    isLoading ? "Carregando..." : _displayName(user),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: "Editar Perfil",
                    height: 50,
                    loading: isLoading,
                    onPressed: () => _openEditProfile(user),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 18),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 22))),
            if (showArrow)
              AnimatedRotation(
                turns: showHistory ? 0.25 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.arrow_forward_ios),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF0D4DB3),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(_profileImageAsset, fit: BoxFit.cover),
    );
  }

  Widget _buildHistory() {
    return FutureBuilder<_ProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Não foi possível carregar o histórico.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        final history = snapshot.data?.history ?? [];
        if (history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Nenhum evento finalizado no seu histórico.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: history.length,
          itemBuilder: (context, index) {
            return _historyItem(context, history[index]);
          },
        );
      },
    );
  }

  Widget _historyItem(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetails,
          arguments: {
            'title': event.titulo,
            'description': event.descricao,
            'location': event.local,
            'speakers': event.ministrantes,
            'remainingVacancies': event.vagasRestantes,
            'isOpen': event.estaAberto,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF2F49D1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _historyDate(event),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                event.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileData {
  final AppUser? user;
  final List<EventModel> history;

  const _ProfileData({this.user, this.history = const []});
}
