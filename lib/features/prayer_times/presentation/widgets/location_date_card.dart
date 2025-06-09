import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationDateCard extends StatelessWidget {
  final String location;
  final String hijriDate;
  final String gregorianDate;

  const LocationDateCard({
    super.key,
    required this.location,
    required this.hijriDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF1C6758),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                location,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C6758),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$hijriDate - $gregorianDate',
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 