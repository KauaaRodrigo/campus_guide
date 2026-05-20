import 'package:flutter/material.dart';

import '../../Components/buttons/primary_button.dart';
import '../../Components/dialogs/logout_dialog.dart';
//import '../../Components/navigation/bottom_nav_bar.dart';

import 'package:campus_guide/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentIndex = 3;
  bool showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //bottomNavigationBar: AppBottomNavBar(
        //currentIndex: currentIndex,
        //onTap: (index) {
          //setState(() {
            //currentIndex = index;
         // });
        //},
      //),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
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
                            height: 50,
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
                  height: showHistory ? 320 : 0,
                  child: SingleChildScrollView(
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
                _buildOption(
                  icon: Icons.logout,
                  title: "Sair",
                  iconColor: Colors.red,
                  showArrow: false,
                  onTap: () {
                    LogoutDialog.show(
                      context,
                      onConfirm: () {
                        print("Usuário saiu");
                      },
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
