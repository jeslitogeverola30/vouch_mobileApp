import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../domain/qr_event_session_entity.dart';

class QrCurrentEventCard extends StatelessWidget {
  const QrCurrentEventCard({
    super.key,
    required this.event,
    required this.isTimeInActive,
    required this.onRecordTimeIn,
    required this.onRecordTimeOut,
  });

  final QrEventSessionEntity event;
  final bool isTimeInActive;
  final VoidCallback onRecordTimeIn;
  final VoidCallback onRecordTimeOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      (event.isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF455A64))
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  event.isActive ? 'Active' : 'Closed',
                  style: TextStyle(
                    color: event.isActive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF455A64),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Ionicons.location_outline,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Ionicons.time_outline,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.timeWindow,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: isTimeInActive
                    ? ElevatedButton.icon(
                        onPressed: onRecordTimeIn,
                        icon: const Icon(Ionicons.log_in, size: 17),
                        label: const Text('Time In'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF003DA5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: onRecordTimeIn,
                        icon: const Icon(Ionicons.log_in, size: 17),
                        label: const Text('Time In'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF003DA5),
                          side: BorderSide(
                            color: const Color(0xFF003DA5).withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isTimeInActive
                    ? OutlinedButton.icon(
                        onPressed: onRecordTimeOut,
                        icon: const Icon(Ionicons.log_out, size: 17),
                        label: const Text('Time Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF003DA5),
                          side: BorderSide(
                            color: const Color(0xFF003DA5).withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: onRecordTimeOut,
                        icon: const Icon(Ionicons.log_out, size: 17),
                        label: const Text('Time Out'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF003DA5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
