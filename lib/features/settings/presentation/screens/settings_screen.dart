import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C6758),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Bildirimler',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.language_outlined,
                      title: 'Dil',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.color_lens_outlined,
                      title: 'Tema',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'Hakkında',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text(
            'Ayarlar',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF1C6758).withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1C6758),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF1C6758),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF1C6758),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
} 