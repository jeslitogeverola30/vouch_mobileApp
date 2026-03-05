import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/utils/global_header_search.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_main_header.dart';
import '../../../../core/config/app_router.dart';
import '../../data/event_query_service.dart';
import '../../data/event_seed_data.dart';
import '../../domain/event_date_time_formatters.dart';
import 'student_event_details_screen.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color lightGray = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF666666);
const Color lightBlue = Color(0xFFE3F2FD);

class EventsScreen extends StatefulWidget {
  final bool showChrome;
  final int initialTabIndex;
  final void Function(BuildContext context, Map<String, dynamic> event)?
  onViewDetailsTap;

  const EventsScreen({
    super.key,
    this.showChrome = true,
    this.initialTabIndex = 0,
    this.onViewDetailsTap,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  int _selectedNavIndex = 1;
  final Map<String, int> _userRatings = {};
  final Map<String, Set<String>> _selectedSuggestions = {};
  final Map<String, TextEditingController> _customFeedbackControllers = {};

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventQueryService.fetchEvents();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    for (final controller in _customFeedbackControllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  TextEditingController _feedbackControllerFor(String eventName) {
    return _customFeedbackControllers.putIfAbsent(
      eventName,
      () => TextEditingController(),
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
        bottomNavigationBar: widget.showChrome
            ? AppBottomNavigationBar(
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
                Tab(text: 'Rate'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildNoEventsState(
                  'Failed to load events. Please try again later.',
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
      ],
    );
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRouter.studentHome);
      return;
    }

    if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRouter.myQrCode);
      return;
    }

    if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRouter.payments);
      return;
    }

    if (index == 4) {
      Navigator.pushReplacementNamed(context, AppRouter.profile);
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  Widget _buildTodayTab(List<Map<String, dynamic>> todayEvents) {
    if (todayEvents.isEmpty) {
      return _buildNoEventsState('No events today');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: todayEvents.map(_buildUpcomingEventCard).toList(),
      ),
    );
  }

  Widget _buildUpcomingTab(List<Map<String, dynamic>> upcomingEvents) {
    if (upcomingEvents.isEmpty) {
      return _buildNoEventsState('No upcoming events');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: upcomingEvents
            .map((event) => _buildUpcomingEventCard(event))
            .toList(),
      ),
    );
  }

  Widget _buildUpcomingEventCard(Map<String, dynamic> event) {
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
                    onPressed: () {
                      if (widget.onViewDetailsTap != null) {
                        widget.onViewDetailsTap!(context, event);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(
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
                            shortDescription:
                                event['shortDescription'] as String? ??
                                'No short description available for this event.',
                            description:
                                event['description'] as String? ??
                                'No description available for this event.',
                            isObligatory:
                                event['isObligatory'] as bool? ?? false,
                          ),
                        ),
                      );
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: pastEvents
            .map((event) => _buildPastEventCard(event))
            .toList(),
      ),
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
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
              const Icon(Ionicons.calendar_outline, size: 14, color: darkGray),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ],
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
    return Center(
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
    final rateEvents = EventSeedData.ratedEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rateEvents
            .map((event) => _buildRateEventCard(event))
            .toList(),
      ),
    );
  }

  Widget _buildRateEventCard(Map<String, dynamic> event) {
    final eventName = event['name'] as String? ?? 'Event';
    final selectedRating = _userRatings[eventName] ?? 0;
    final selectedSuggestions = _selectedSuggestions[eventName] ?? <String>{};
    final feedbackController = _feedbackControllerFor(eventName);

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
                    event['rating'].toString(),
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
                        index < event['rating'].toInt()
                            ? Ionicons.star
                            : Ionicons.star_outline,
                        color: gold,
                        size: 16,
                      ),
                    ),
                  ),
                  Text(
                    '(${event['reviews']} reviews)',
                    style: const TextStyle(color: darkGray, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildRatingBreakdown(event['ratingBreakdown']),
          const SizedBox(height: 16),
          const Text(
            'Rate this event',
            style: TextStyle(
              color: royalBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    onPressed: () {
                      final rating = index + 1;
                      setState(() {
                        _userRatings[eventName] = rating;
                      });
                    },
                    icon: Icon(
                      index < selectedRating
                          ? Ionicons.star
                          : Ionicons.star_outline,
                      color: index < selectedRating ? gold : darkGray,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suggestions',
            style: TextStyle(
              color: royalBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventSeedData.feedbackSuggestions.map((suggestion) {
              final isSelected = selectedSuggestions.contains(suggestion);
              return ChoiceChip(
                label: Text(suggestion),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final updatedSuggestions = Set<String>.from(
                      _selectedSuggestions[eventName] ?? <String>{},
                    );

                    if (selected) {
                      updatedSuggestions.add(suggestion);
                    } else {
                      updatedSuggestions.remove(suggestion);
                    }

                    _selectedSuggestions[eventName] = updatedSuggestions;
                  });
                },
                selectedColor: royalBlue.withOpacity(0.14),
                backgroundColor: lightBlue.withOpacity(0.35),
                side: BorderSide(
                  color: isSelected ? royalBlue.withOpacity(0.45) : lightGray,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? royalBlue : darkGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Own Feedback',
            style: TextStyle(
              color: royalBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: feedbackController,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your own comments about this event...',
              hintStyle: const TextStyle(
                color: darkGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: lightBlue.withOpacity(0.22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: royalBlue.withOpacity(0.5)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Your feedback helps improve future events.',
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
                if (selectedRating <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please rate $eventName before submitting.',
                      ),
                    ),
                  );
                  return;
                }

                final customFeedback = feedbackController.text.trim();
                final selectedSuggestionText = selectedSuggestions.isEmpty
                    ? 'No suggestion selected'
                    : selectedSuggestions.join(', ');
                final customFeedbackText = customFeedback.isEmpty
                    ? 'No custom feedback'
                    : customFeedback;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rating submitted for $eventName: $selectedRating stars • $selectedSuggestionText • $customFeedbackText',
                    ),
                  ),
                );
              },
              child: const Text(
                'Submit Rating',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
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
}
