import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        height: 65,
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF1C6758).withOpacity(0.1),
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 0
                    ? const Color(0xFF1C6758).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/icons/home.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0
                      ? const Color(0xFF1C6758)
                      : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 1
                    ? const Color(0xFF1C6758).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/icons/mosque.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 1
                      ? const Color(0xFF1C6758)
                      : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 2
                    ? const Color(0xFF1C6758).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/icons/quran.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 2
                      ? const Color(0xFF1C6758)
                      : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 3
                    ? const Color(0xFF1C6758).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/icons/compass.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 3
                      ? const Color(0xFF1C6758)
                      : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
} 