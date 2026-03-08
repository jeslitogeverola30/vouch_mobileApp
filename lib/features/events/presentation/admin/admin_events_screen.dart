import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/widgets/admin_bottom_navigation_bar.dart';
import '../../../../core/utils/global_header_search.dart';
import '../../../../core/widgets/app_main_header.dart';
import '../../../../core/config/app_router.dart';
import '../../data/event_rating_service.dart';
import '../../data/event_query_service.dart';
import '../../domain/event_date_time_formatters.dart';
import 'admin_create_event_screen.dart';
import 'admin_event_details_screen.dart';
import 'admin_event_record_screen.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color lightGray = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF666666);
const Color lightBlue = Color(0xFFE3F2FD);

class AdminEventsScreen extends StatefulWidget {
  final bool showChrome;
  final int initialTabIndex;
  final void Function(BuildContext context, Map<String, dynamic> event)?
  onViewDetailsTap;

  const AdminEventsScreen({
    super.key,
    this.showChrome = true,
    this.initialTabIndex = 0,
    this.onViewDetailsTap,
  });

  @override
  State<AdminEventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<AdminEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  late Future<List<Map<String, dynamic>>> _rateEventsFuture;
  final int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventQueryService.fetchEvents();
    _rateEventsFuture = EventRatingService.fetchAdminRateEvents();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
  }

  Future<void> _refreshEvents() async {
    final eventsFuture = EventQueryService.fetchEvents();
    final rateEventsFuture = EventRatingService.fetchAdminRateEvents();

    if (mounted) {
      setState(() {
        _eventsFuture = eventsFuture;
        _rateEventsFuture = rateEventsFuture;
      });
    }

    await Future.wait<List<Map<String, dynamic>>>([
      eventsFuture,
      rateEventsFuture,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              bottom: 280,
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
        floatingActionButton: FloatingActionButton(
          heroTag: 'admin_events_add_fab',
          onPressed: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen()),
            );

            if (created == true && mounted) {
              _refreshEvents();
            }
          },
          backgroundColor: const Color(0xFF003DA5),
          foregroundColor: Colors.white,
          elevation: 8,
          highlightElevation: 10,
          shape: const CircleBorder(),
          child: const Icon(Ionicons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: widget.showChrome
            ? AdminBottomNavigationBar(
                currentIndex: _selectedNavIndex,
                onTap: _onNavTapped,
              )
            : null,
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChrome)
          AppMainHeader(onSearchTap: () => openGlobalHeaderSearch(context)),
        if (widget.showChrome) const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF003DA5).withOpacity(0.1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelColor: royalBlue,
              unselectedLabelColor: darkGray,
              dividerColor: Colors.transparent,
              indicatorColor: royalBlue,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Ratings'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshEvents,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildNoEventsState(
                    'Failed to load events. Pull to refresh this screen.',
                  );
                }

                final events = snapshot.data ?? const <Map<String, dynamic>>[];
                final todayEvents = EventQueryService.todayEvents(events);
                final upcomingEvents = EventQueryService.upcomingEvents(events);
                final pastEvents = EventQueryService.pastEvents(events);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(todayEvents),
                    _buildUpcomingTab(upcomingEvents),
                    _buildPastTab(pastEvents),
                    _buildRateTab(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRouter.adminHome,
      arguments: index,
    );
  }

  Widget _buildTodayTab(List<Map<String, dynamic>> todayEvents) {
    if (todayEvents.isEmpty) {
      return _buildNoEventsState('No events today');
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: todayEvents
            .map((event) => _buildUpcomingEventCard(event, isTodayEvent: true))
            .toList(),
      ),
    );
  }

  Widget _buildUpcomingTab(List<Map<String, dynamic>> upcomingEvents) {
    if (upcomingEvents.isEmpty) {
      return _buildNoEventsState('No upcoming events');
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: upcomingEvents
            .map((event) => _buildUpcomingEventCard(event, isTodayEvent: false))
            .toList(),
      ),
    );
  }

  Widget _buildUpcomingEventCard(
    Map<String, dynamic> event, {
    required bool isTodayEvent,
  }) {
    final imagePath =
        event['image'] as String? ?? 'assets/images/event-siglakas.jpg';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              color: lightGray,
              child: _buildEventImage(imagePath),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event['name'],
                        style: const TextStyle(
                          color: royalBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (event['isObligatory'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OBLIGATORY',
                          style: TextStyle(
                            color: royalBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Ionicons.calendar_outline,
                      size: 14,
                      color: darkGray,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      event['date'],
                      style: const TextStyle(color: darkGray, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: royalBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Ionicons.log_in_outline,
                        size: 14,
                        color: royalBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Time in: ${event['timeIn']}',
                          style: const TextStyle(
                            color: royalBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: royalBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Ionicons.log_out_outline,
                        size: 14,
                        color: royalBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Time out: ${event['timeOut']}',
                          style: const TextStyle(
                            color: royalBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: royalBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (widget.onViewDetailsTap != null) {
                        widget.onViewDetailsTap!(context, event);
                        return;
                      }

                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminEventDetailsScreen(
                            eventId: _readInt(event['id']),
                            eventImage:
                                event['image'] as String? ??
                                'assets/images/event-siglakas.jpg',
                            eventName: event['name'] as String? ?? 'Event',
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
                                event['locationSubtitle'] as String? ?? '',
                            eventDateRaw:
                                event['eventDateRaw'] as String? ?? '',
                            timeInStartRaw:
                                event['timeInStartRaw'] as String? ?? '',
                            timeInEndRaw:
                                event['timeInEndRaw'] as String? ?? '',
                            timeOutStartRaw:
                                event['timeOutStartRaw'] as String? ?? '',
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
                            isTodayEvent: isTodayEvent,
                          ),
                        ),
                      );

                      if (changed == true && mounted) {
                        _refreshEvents();
                      }
                    },
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastTab(List<Map<String, dynamic>> pastEvents) {
    if (pastEvents.isEmpty) {
      return _buildNoEventsState('No past events yet');
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: pastEvents
            .map((event) => _buildPastEventCard(event))
            .toList(),
      ),
    );
  }

  Future<void> _openPastEventRecord(Map<String, dynamic> event) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => EventRecordScreen(
          eventId: _readInt(event['id']),
          eventName: event['name'] as String? ?? 'Event',
          eventDate: event['date'] as String? ?? 'Date not available',
          eventDateRaw: event['eventDateRaw'] as String?,
          isEventDone: true,
          eventLocation: event['location'] as String? ?? 'University Campus',
          eventTimeIn: event['timeIn'] as String? ?? '-',
          eventTimeOut: event['timeOut'] as String? ?? '-',
          eventImage:
              event['image'] as String? ?? 'assets/images/event-siglakas.jpg',
          isObligatory: event['isObligatory'] as bool? ?? false,
        ),
      ),
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openPastEventRecord(event),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: royalBlue.withOpacity(0.1), width: 1),
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
              Text(
                event['name'],
                style: const TextStyle(
                  color: royalBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Ionicons.calendar_outline,
                    size: 14,
                    color: darkGray,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    event['date'],
                    style: const TextStyle(color: darkGray, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (event['attended']) ...[
                _buildTimeRow(
                  label: 'Time-in',
                  time: event['timeIn'],
                  icon: Ionicons.log_in_outline,
                ),
                const SizedBox(height: 8),
                _buildTimeRow(
                  label: 'Time-out',
                  time: event['timeOut'],
                  icon: Ionicons.log_out_outline,
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Not Attended',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Ionicons.document_text_outline,
                    size: 14,
                    color: royalBlue.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'View record',
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Ionicons.chevron_forward,
                    size: 15,
                    color: royalBlue.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow({
    required String label,
    required String? time,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: royalBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: royalBlue, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: const TextStyle(
              color: darkGray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            time ?? '-',
            style: const TextStyle(
              color: royalBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 320,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Ionicons.calendar_clear_outline,
                  color: darkGray,
                  size: 52,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: darkGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventImage(String imagePath) {
    final isAssetImage = imagePath.startsWith('assets/');

    if (isAssetImage) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: lightGray,
            child: const Icon(Ionicons.image, color: darkGray),
          );
        },
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: lightGray,
          child: const Icon(Ionicons.image, color: darkGray),
        );
      },
    );
  }

  Widget _buildRateTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _rateEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildNoEventsState('Failed to load event ratings.');
        }

        final rateEvents = snapshot.data ?? const <Map<String, dynamic>>[];
        if (rateEvents.isEmpty) {
          return _buildNoEventsState('No event ratings available yet');
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: rateEvents
                .map((event) => _buildRateEventCard(event))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildRateEventCard(Map<String, dynamic> event) {
    final eventName = event['name'] as String? ?? 'Event';
    final averageRating = _readDouble(event['rating']);
    final reviewCount = _readInt(event['reviews']) ?? 0;
    final averageStarCount = averageRating.floor().clamp(0, 5);
    final ratingBreakdown = _readBreakdown(event['ratingBreakdown']);
    final comments = (event['comments'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.1), width: 1),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['name'],
                    style: const TextStyle(
                      color: royalBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['date'],
                    style: const TextStyle(color: darkGray, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: royalBlue,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < averageStarCount
                            ? Ionicons.star
                            : Ionicons.star_outline,
                        color: gold,
                        size: 16,
                      ),
                    ),
                  ),
                  Text(
                    '($reviewCount reviews)',
                    style: const TextStyle(color: darkGray, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildRatingBreakdown(ratingBreakdown),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Showing rating results based on submitted student feedback.',
              style: TextStyle(
                color: darkGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: royalBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showCommentsSheet(eventName: eventName, comments: comments);
              },
              child: const Text(
                'View Comments',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  Map<String, int> _readBreakdown(dynamic value) {
    final empty = const <String, int>{'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    if (value is! Map) {
      return empty;
    }

    final output = <String, int>{...empty};
    for (final stars in output.keys.toList()) {
      output[stars] = _readInt(value[stars]) ?? 0;
    }

    return output;
  }

  List<Widget> _buildRatingBreakdown(Map<String, int> breakdown) {
    return [
      ...['5', '4', '3', '2', '1'].map((stars) {
        final percentage = breakdown[stars] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '$stars star',
                style: const TextStyle(color: darkGray, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: lightGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(gold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: const TextStyle(color: darkGray, fontSize: 12),
              ),
            ],
          ),
        );
      }),
    ];
  }

  void _showCommentsSheet({
    required String eventName,
    required List<Map<String, dynamic>> comments,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$eventName Comments',
                  style: const TextStyle(
                    color: royalBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'No comments available yet.',
                      style: TextStyle(
                        color: darkGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = comments[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: lightGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] as String? ?? 'Student',
                                      style: const TextStyle(
                                        color: royalBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['date'] as String? ?? '',
                                    style: const TextStyle(
                                      color: darkGray,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['comment'] as String? ?? '',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
