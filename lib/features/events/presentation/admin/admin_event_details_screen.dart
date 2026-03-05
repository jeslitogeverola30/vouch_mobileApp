import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/event_admin_service.dart';
import '../../domain/event_form_initial_data.dart';
import 'admin_edit_event_screen.dart';
import '../../../qr_code/presentation/admin/scan_qr_screen.dart';

enum _AdminEventAction { edit, delete }

class AdminEventDetailsScreen extends StatelessWidget {
  final int? eventId;
  final String eventImage;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String location;
  final String locationSubtitle;
  final String? eventDateRaw;
  final String? timeInStartRaw;
  final String? timeInEndRaw;
  final String? timeOutStartRaw;
  final String? timeOutEndRaw;
  final String shortDescription;
  final String description;
  final bool isObligatory;
  final bool isTodayEvent;

  const AdminEventDetailsScreen({
    super.key,
    this.eventId,
    this.eventImage = 'assets/images/event-siglakas.jpg',
    this.eventName = 'Siglakas 2026 Day 2',
    this.eventDate = 'April 11, 2026',
    this.eventTime =
        'Time in: 08:00 AM - 08:15 AM\nTime out: 04:00 PM - 04:15 PM',
    this.location = 'University Campus',
    this.locationSubtitle = '',
    this.eventDateRaw,
    this.timeInStartRaw,
    this.timeInEndRaw,
    this.timeOutStartRaw,
    this.timeOutEndRaw,
    this.shortDescription = 'No short description available for this event.',
    this.description =
        'Join us for SIGLAKAS 2025, the much-awaited annual sports fest that unites Carolinians through friendly competition, teamwork, and the true spirit of sportsmanship. For one exhilarating week, students from different colleges – Engineering, Business, Architecture, Arts and Sciences, Education, and Nursing – will compete across various sports and recreational activities. SIGLAKAS is more than just a tournament — it\'s a celebration of unity, discipline, and pride as students push their limits on and off the field.',
    this.isObligatory = true,
    this.isTodayEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color royalBlue = Color(0xFF003DA5);
    const Color gold = Color(0xFFFFC107);
    const Color lightGray = Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: 260,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: Colors.white,
                  child: SizedBox(
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Ionicons.arrow_back,
                              color: Color(0xFF003DA5),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openActionsSheet(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF003DA5,
                                ).withOpacity(0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(
                                    0xFF003DA5,
                                  ).withOpacity(0.12),
                                ),
                              ),
                              child: const Icon(
                                Ionicons.ellipsis_vertical,
                                color: Color(0xFF003DA5),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Event ',
                                style: TextStyle(color: Color(0xFF003DA5)),
                              ),
                              TextSpan(
                                text: 'Details',
                                style: TextStyle(color: Color(0xFFFFC107)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEventImage(),
                          const SizedBox(height: 16),
                          _buildTitleRow(),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Ionicons.calendar,
                            iconBgColor: gold.withOpacity(0.12),
                            iconColor: gold,
                            title: eventDate,
                            subtitle: eventTime,
                            subtitleColor: lightGray,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            icon: Ionicons.location,
                            iconBgColor: royalBlue.withOpacity(0.1),
                            iconColor: royalBlue,
                            title: location,
                            subtitle: locationSubtitle,
                            subtitleColor: lightGray,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Short Description',
                            style: GoogleFonts.poppins(
                              color: royalBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            shortDescription,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              color: royalBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isTodayEvent
          ? FloatingActionButton(
              heroTag: 'admin_event_details_scan_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanQrScreen(
                      eventId: eventId,
                      eventName: eventName,
                      location: location,
                      timeWindow: eventTime,
                      isEventActive: isTodayEvent,
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF003DA5),
              foregroundColor: Colors.white,
              elevation: 8,
              highlightElevation: 10,
              shape: const CircleBorder(),
              child: const Icon(Ionicons.scan, size: 26),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _AdminEventAction action,
  ) async {
    if (action == _AdminEventAction.edit) {
      await _handleEditEvent(context);
      return;
    }

    if (action == _AdminEventAction.delete) {
      await _handleDeleteEvent(context);
    }
  }

  Future<void> _openActionsSheet(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<_AdminEventAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003DA5).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Event Options',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF003DA5),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_AdminEventAction.edit),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003DA5).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF003DA5).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Ionicons.create_outline,
                              color: Color(0xFF003DA5),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit event',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF003DA5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Ionicons.chevron_forward,
                            color: Color(0xFF003DA5),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(_AdminEventAction.delete),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3261E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB3261E).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Ionicons.trash_outline,
                              color: Color(0xFFB3261E),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Delete event',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFB3261E),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Ionicons.chevron_forward,
                            color: Color(0xFFB3261E),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedAction == null || !context.mounted) {
      return;
    }

    await _handleAction(context, selectedAction);
  }

  Future<void> _handleEditEvent(BuildContext context) async {
    final initialData = _buildEditInitialData();
    if (initialData == null) {
      _showError(
        context,
        'Unable to edit this event right now. Missing event details.',
      );
      return;
    }

    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEventScreen(initialData: initialData),
      ),
    );

    if (edited == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleDeleteEvent(BuildContext context) async {
    if (eventId == null) {
      _showError(context, 'Unable to delete this event. Missing event ID.');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3261E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Ionicons.trash_outline,
                        color: Color(0xFFB3261E),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Event',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF003DA5),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete this event? This action cannot be undone.',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color(0xFF003DA5).withOpacity(0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB3261E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await EventAdminService.deleteEvent(eventId: eventId!);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (!context.mounted) {
        return;
      }

      final message = error.message.trim().isEmpty
          ? 'Failed to delete event.'
          : error.message.trim();
      _showError(context, message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showError(context, 'Failed to delete event. Please try again.');
    }
  }

  EventFormInitialData? _buildEditInitialData() {
    final id = eventId;
    final parsedDate = _parseDate(eventDateRaw);
    final parsedTimeInStart = _parseDatabaseTimeMinutes(timeInStartRaw);
    final parsedTimeInEnd = _parseDatabaseTimeMinutes(timeInEndRaw);
    final parsedTimeOutStart = _parseDatabaseTimeMinutes(timeOutStartRaw);
    final parsedTimeOutEnd = _parseDatabaseTimeMinutes(timeOutEndRaw);

    if (id == null ||
        parsedDate == null ||
        parsedTimeInStart == null ||
        parsedTimeInEnd == null ||
        parsedTimeOutStart == null ||
        parsedTimeOutEnd == null) {
      return null;
    }

    final initialImageUrl = eventImage.startsWith('assets/') ? '' : eventImage;

    return EventFormInitialData(
      eventId: id,
      name: eventName,
      shortDescription: shortDescription,
      fullDescription: description,
      location: location,
      imageUrl: initialImageUrl,
      eventDate: parsedDate,
      timeInStartMinutes: parsedTimeInStart,
      timeInEndMinutes: parsedTimeInEnd,
      timeOutStartMinutes: parsedTimeOutStart,
      timeOutEndMinutes: parsedTimeOutEnd,
      isMandatory: isObligatory,
    );
  }

  DateTime? _parseDate(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  int? _parseDatabaseTimeMinutes(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) {
      return null;
    }

    return (hour * 60) + minute;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildEventImage() {
    final isAssetImage = eventImage.startsWith('assets/');

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isAssetImage
            ? Image.asset(
                eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              )
            : Image.network(
                eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            eventName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isObligatory) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'OBLIGATORY',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
