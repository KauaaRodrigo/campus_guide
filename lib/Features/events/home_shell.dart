import 'package:flutter/material.dart';

import '../../Components/navigation/bottom_nav_bar.dart';
import 'home.dart';
import 'create_page.dart';
import 'my_events_page.dart';
import 'package:campus_guide/Features/profile/profile_tab.dart';

/// Container que mantém as principais abas e a `AppBottomNavBar`.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const CreatePage(),
      const MyEventsPage(),
      const ProfileTab(),
    ];

    return Scaffold(
      // `IndexedStack` preserva o estado de cada aba ao alternar.
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}
