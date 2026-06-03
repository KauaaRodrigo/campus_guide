import 'package:flutter/material.dart';

import '../../Components/buttons/primary_button.dart';
import '../../Components/dialogs/logout_dialog.dart';

import 'package:campus_guide/Features/auth/auth_service.dart';
import 'package:campus_guide/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showHistory = false;

  Future<void> _logout() async {
    await AuthService().deslogar();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // HEADER
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          "Meu Perfil",

                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 40),

                // FOTO + INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 140,
                      height: 140,

                      decoration: const BoxDecoration(
                        color: Color(0xFF0D4DB3),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),

                    const SizedBox(width: 24),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          const Text(
                            "Pedro Alves Santana de Souza",

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 24),

                          PrimaryButton(
                            text: "Editar Perfil",

                            height: 52,

                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.editProfile,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // HISTORICO
                _buildOption(
                  icon: Icons.history,
                  title: "Histórico",

                  onTap: () {
                    setState(() {
                      showHistory = !showHistory;
                    });
                  },
                ),

                const Divider(),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),

                  curve: Curves.easeInOut,

                  height: showHistory ? 320 : 0,

                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    child: Column(
                      children: [
                        _historyItem(
                          context,

                          "TechConnect 2026",

                          "03\nABR",

                          "Evento focado em tecnologia, mercado e inovação.",

                          [
                            {"name": "Matheus", "image": ""},
                            {"name": "Mariana", "image": ""},
                          ],
                        ),

                        _historyItem(
                          context,

                          "CodeRush",

                          "10\nABR",

                          "Workshop intensivo de Flutter e desenvolvimento mobile.",

                          [
                            {"name": "Pedro", "image": ""},
                            {"name": "Julia", "image": ""},
                          ],
                        ),

                        _historyItem(
                          context,

                          "Semana da Computação",

                          "22\nMAI",

                          "Semana acadêmica com palestras e minicursos.",

                          [
                            {"name": "Carlos", "image": ""},
                            {"name": "Fernanda", "image": ""},
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // LOGOUT
                _buildOption(
                  icon: Icons.logout,
                  title: "Sair",

                  iconColor: Colors.red,

                  showArrow: false,

                  onTap: () {
                    LogoutDialog.show(
                      context,
                      onConfirm: _logout,
                    );
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

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,

    Color iconColor = Colors.black,

    bool showArrow = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),

        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

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

  Widget _historyItem(
    BuildContext context,
    String title,
    String date,
    String description,
    List<Map<String, String>> speakers,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetails,

          arguments: {
            'title': title,
            'description': description,
            'location': 'Auditório Padre Arnobio',
            'speakers': speakers,
          },
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          top: 12,
          right: 4,
        ),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.grey.shade100,

          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,

              decoration: BoxDecoration(
                color: const Color(0xFF2F49D1),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Center(
                child: Text(
                  date,

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
                title,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}