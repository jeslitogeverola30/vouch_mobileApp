import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrMetaItem extends StatelessWidget {
  const QrMetaItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.royalBlue,
    required this.white,
    required this.textGray,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color royalBlue;
  final Color white;
  final Color textGray;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: royalBlue.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              color: textGray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: royalBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
