import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF1C6758).withOpacity(0.1),
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      height: 65,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Color(0xFF1C6758)),
          label: 'Ana Sayfa',
        ),
        NavigationDestination(
          icon: Icon(Icons.mosque_outlined),
          selectedIcon: Icon(Icons.mosque, color: Color(0xFF1C6758)),
          label: 'Namaz',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book, color: Color(0xFF1C6758)),
          label: 'Kuran',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: Color(0xFF1C6758)),
          label: 'Ayarlar',
        ),
      ],
    );
  }
} 