import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../../core/config/app_router.dart';
import '../../events/data/event_query_service.dart';
import '../../events/domain/event_date_time_formatters.dart';
import '../../events/presentation/admin/admin_event_details_screen.dart';
import '../data/admin_home_statistics_service.dart';

import '../../../core/config/app_constants.dart';          // ← your new constants
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  final bool showChrome;

  const AdminHomeScreen({super.key, this.showChrome = true});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? _pressedActionLabel;
  bool _isLoadingTodayEvents = true;
  bool _isLoadingStatistics = true;

  int _totalStudentsCount = 0;
  int _upcomingEventsCount = 0;

  List<Map<String, dynamic>> _todayEvents = const [];
  DateTime? _lastRefreshTime;
  int _dailyRefreshCount = 0;
  String _currentDay = '';
  @override
  void initState() {
    super.initState();
    _loadTodayEvents();
  }

    Future<void> _refreshHomeScreen() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Load persisted values
    final lastRefreshStr = prefs.getString('admin_last_refresh_time');
    if (lastRefreshStr != null) {
      _lastRefreshTime = DateTime.tryParse(lastRefreshStr);
    }
    _dailyRefreshCount = prefs.getInt('admin_daily_refresh_count') ?? 0;
    _currentDay = prefs.getString('admin_current_day') ?? '';

    // Reset daily count if it's a new day
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    if (_currentDay != today) {
      _dailyRefreshCount = 0;
      _currentDay = today;
    }

    // === 1. Check cooldown ===
    if (_lastRefreshTime != null) {
      final timeSinceLast = now.difference(_lastRefreshTime!);
      if (timeSinceLast < AppConstants.refreshCooldown) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait at least ${AppConstants.refreshCooldown.inMinutes} minute${AppConstants.refreshCooldown.inMinutes > 1 ? 's' : ''} before refreshing again.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // === 2. Check daily limit ===
    if (_dailyRefreshCount >= AppConstants.maxDailyRefreshes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have reached the maximum of 5 refreshes today. Please try again tomorrow.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // === ALLOW REFRESH ===
    if (mounted) {
      setState(() {
        _isLoadingTodayEvents = true;
        _isLoadingStatistics = true;
      });
    }

    await _loadTodayEvents();

    // Update tracking
    _lastRefreshTime = now;
    _dailyRefreshCount++;

    // Save to device storage
    await prefs.setString('admin_last_refresh_time', now.toIso8601String());
    await prefs.setInt('admin_daily_refresh_count', _dailyRefreshCount);
    await prefs.setString('admin_current_day', today);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Refreshed successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadTodayEvents() async {
    List<Map<String, dynamic>> events = const [];
    int totalStudentsCount = 0;
    int upcomingEventsCount = 0;

    try {
      events = await EventQueryService.fetchEvents();
      upcomingEventsCount = EventQueryService.upcomingEvents(events).length;
    } catch (_) {
      events = const [];
      upcomingEventsCount = 0;
    }

    try {
      totalStudentsCount =
          await AdminHomeStatisticsService.fetchTotalStudentsCount();
    } catch (_) {
      totalStudentsCount = 0;
    }

    try {
      final supabaseUpcomingCount =
          await AdminHomeStatisticsService.fetchUpcomingEventsCount();
      upcomingEventsCount = supabaseUpcomingCount;
    } catch (_) {}

    final todayEvents = EventQueryService.todayEvents(events);

    if (!mounted) {
      return;
    }

    setState(() {
      _todayEvents = todayEvents;
      _totalStudentsCount = totalStudentsCount;
      _upcomingEventsCount = upcomingEventsCount;
      _isLoadingTodayEvents = false;
      _isLoadingStatistics = false;
    });
  }

  void _openAdminTab(int index) {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.adminHome,
      arguments: index,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final isPressed = _pressedActionLabel == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onHighlightChanged: (value) {
          if (!mounted) {
            return;
          }
          setState(() {
            _pressedActionLabel = value ? label : null;
          });
        },
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: isPressed
                ? (isHighlighted
                      ? const Color(0xFFE4AF00)
                      : const Color(0xFF003DA5).withOpacity(0.12))
                : (isHighlighted ? const Color(0xFFFFC107) : Colors.white),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFFFFC107)
                  : const Color(0xFF003DA5).withOpacity(0.15),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPressed
                      ? (isHighlighted
                            ? Colors.white.withOpacity(0.48)
                            : const Color(0xFF003DA5).withOpacity(0.14))
                      : (isHighlighted
                            ? Colors.white.withOpacity(0.35)
                            : const Color(0xFF003DA5).withOpacity(0.08)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF003DA5), size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted
                      ? Colors.black87
                      : const Color(0xFF003DA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
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
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 300,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            widget.showChrome
                ? SafeArea(child: _buildMainContent())
                : _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChrome)
          AppMainHeader(
            avatarPath: 'assets/images/my_profile.png',
            onAvatarTap: () => _openAdminTab(4),
            onSearchTap: () => openGlobalHeaderSearch(context),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshHomeScreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF003DA5).withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Hello, ',
                                  style: TextStyle(
                                    color: Color(0xFF003DA5),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Admin',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Manage students, events, and collections efficiently',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: "Today's Event",
                    subtitle: 'Track active events and attendance windows',
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingTodayEvents)
                    const SizedBox(
                      height: 286,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_todayEvents.isEmpty)
                    const SizedBox(
                      height: 286,
                      child: Center(
                        child: Text(
                          'No events today',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 286,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _todayEvents.length,
                        itemBuilder: (context, index) {
                          final event = _todayEvents[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminEventDetailsScreen(
                                    eventId: _readInt(event['id']),
                                    eventImage:
                                        event['image'] as String? ??
                                        'assets/images/event-siglakas.jpg',
                                    eventName:
                                        event['name'] as String? ?? 'Event',
                                    eventDate:
                                        event['date'] as String? ??
                                        'Date not available',
                                    eventTime:
                                        EventDateTimeFormatters.buildEventTimeText(
                                          timeIn: event['timeIn'] as String?,
                                          timeOut: event['timeOut'] as String?,
                                        ),
                                    location:
                                        event['location'] as String? ??
                                        'University Campus',
                                    locationSubtitle:
                                        event['locationSubtitle'] as String? ??
                                        '',
                                    eventDateRaw:
                                        event['eventDateRaw'] as String? ?? '',
                                    timeInStartRaw:
                                        event['timeInStartRaw'] as String? ??
                                        '',
                                    timeInEndRaw:
                                        event['timeInEndRaw'] as String? ?? '',
                                    timeOutStartRaw:
                                        event['timeOutStartRaw'] as String? ??
                                        '',
                                    timeOutEndRaw:
                                        event['timeOutEndRaw'] as String? ?? '',
                                    shortDescription:
                                        event['shortDescription'] as String? ??
                                        'No short description available for this event.',
                                    description:
                                        event['description'] as String? ??
                                        'No description available for this event.',
                                    isObligatory:
                                        event['isObligatory'] as bool? ?? false,
                                    isTodayEvent: true,
                                  ),
                                ),
                              );

                              if (changed == true && mounted) {
                                _loadTodayEvents();
                              }
                            },
                            child: Container(
                              width: 236,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFF003DA5,
                                  ).withOpacity(0.1),
                                ),
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
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: _buildEventImage(
                                      event['image'] as String? ??
                                          'assets/images/event-siglakas.jpg',
                                      width: 236,
                                      height: 132,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        8,
                                        12,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event['name'] as String? ??
                                                      'Event',
                                                  style: const TextStyle(
                                                    color: Color(0xFF003DA5),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFC107,
                                                  ).withOpacity(0.22),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'TODAY',
                                                  style: TextStyle(
                                                    color: Color(0xFF003DA5),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event['shortDescription']
                                                    as String? ??
                                                'No short description available for this event.',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildTodayEventInfoRow(
                                            icon: Ionicons.calendar_outline,
                                            text:
                                                event['date'] as String? ?? '-',
                                          ),
                                          const SizedBox(height: 6),
                                          _buildTodayEventInfoRow(
                                            icon: Ionicons.log_in_outline,
                                            text:
                                                event['timeIn'] as String? ??
                                                '-',
                                          ),
                                          const SizedBox(height: 6),
                                          _buildTodayEventInfoRow(
                                            icon: Ionicons.log_out_outline,
                                            text:
                                                event['timeOut'] as String? ??
                                                '-',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Open your most-used admin tasks',
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Ionicons.person_add,
                            label: 'Add Student',
                            isHighlighted: true,
                            onTap: () => _openAdminTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Ionicons.calendar,
                            label: 'Events',
                            onTap: () => _openAdminTab(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Ionicons.card,
                            label: 'Payments',
                            onTap: () => _openAdminTab(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: 'Statistics',
                    subtitle: 'Current totals for this term',
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003DA5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Students',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _isLoadingStatistics
                                      ? '...'
                                      : _formatCount(_totalStudentsCount),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Events',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _isLoadingStatistics
                                      ? '...'
                                      : _formatCount(_upcomingEventsCount),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEventInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF003DA5)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(
    String imagePath, {
    required double width,
    required double height,
  }) {
    final isAssetImage = imagePath.startsWith('assets/');

    if (isAssetImage) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF5F5F5),
            child: const Icon(Ionicons.image, color: Color(0xFF666666)),
          );
        },
      );
    }

    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF5F5F5),
          child: const Icon(Ionicons.image, color: Color(0xFF666666)),
        );
      },
    );
  }

  String _formatCount(int value) {
    final sanitized = value < 0 ? 0 : value;
    final digits = sanitized.toString();
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }
}
