import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyAyahCard extends StatelessWidget {
  final String arabicText;
  final String translation;
  final String source;
  final VoidCallback onShare;

  const DailyAyahCard({
    super.key,
    required this.arabicText,
    required this.translation,
    required this.source,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Günün Ayeti',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C6758),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onShare,
                icon: Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              arabicText,
              style: GoogleFonts.amiri(
                fontSize: 28,
                height: 1.5,
                color: const Color(0xFF1C6758),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translation,
            style: GoogleFonts.poppins(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            source,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
} 