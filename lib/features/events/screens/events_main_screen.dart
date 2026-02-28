import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../../routes/app_router.dart';
import 'event_details_screen.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color lightGray = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF666666);
const Color lightBlue = Color(0xFFE3F2FD);

class EventsScreen extends StatefulWidget {
  final bool showChrome;

  const EventsScreen({super.key, this.showChrome = true});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 1;
  final Map<String, int> _userRatings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
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
        if (widget.showChrome) const AppMainHeader(),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(),
              _buildUpcomingTab(),
              _buildPastTab(),
              _buildRateTab(),
            ],
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

  Widget _buildTodayTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Ionicons.calendar_clear_outline, color: darkGray, size: 52),
          SizedBox(height: 12),
          Text(
            'No events today',
            style: TextStyle(
              color: darkGray,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final upcomingEvents = [
      {
        'name': 'Mind & Wellness',
        'date': 'November 06, 2026',
        'timeIn': '08:00 AM - 08:15 AM',
        'timeOut': '04:00 PM - 04:15 PM',
        'image': 'https://via.placeholder.com/300x200?text=Mind+Wellness',
        'isObligatory': false,
      },
      {
        'name': 'Service & Outreach',
        'date': 'November 10, 2026',
        'timeIn': '08:00 AM - 08:15 AM',
        'timeOut': '04:00 PM - 04:15 PM',
        'image': 'https://via.placeholder.com/300x200?text=Outreach',
        'isObligatory': false,
      },
      {
        'name': 'Siglakas Day 1',
        'date': 'April 06-12, 2026',
        'timeIn': '08:00 AM - 08:15 AM',
        'timeOut': '08:00 PM - 08:15 PM',
        'image': 'https://via.placeholder.com/300x200?text=Siglakas',
        'isObligatory': true,
      },
      {
        'name': 'Siglakas Day 2',
        'date': 'April 06-12, 2026',
        'timeIn': '08:00 AM - 08:15 AM',
        'timeOut': '08:00 PM - 08:15 PM',
        'image': 'https://via.placeholder.com/300x200?text=Siglakas+2',
        'isObligatory': true,
      },
    ];

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGray, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              color: lightGray,
              child: Image.network(
                event['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: lightGray,
                    child: const Icon(Ionicons.image, color: darkGray),
                  );
                },
              ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                          color: royalBlue.withOpacity(0.1),
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
                Text(
                  event['date'],
                  style: const TextStyle(color: darkGray, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time in: ${event['timeIn']}',
                  style: const TextStyle(
                    color: royalBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time out: ${event['timeOut']}',
                  style: const TextStyle(
                    color: royalBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(
                            eventImage:
                                event['image'] as String? ??
                                'https://via.placeholder.com/300x200?text=Event',
                            eventName: event['name'] as String? ?? 'Event',
                            eventDate:
                                event['date'] as String? ??
                                'Date not available',
                            eventTime:
                                'Time in: ${event['timeIn'] as String? ?? 'Time-in not available'}\n'
                                'Time out: ${event['timeOut'] as String? ?? 'Time-out not available'}',
                            isObligatory:
                                event['isObligatory'] as bool? ?? false,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildPastTab() {
    final pastEvents = [
      {
        'name': 'General Convocation',
        'date': 'April 06-12, 2026',
        'timeIn': '08:50 AM',
        'timeOut': '07:50 PM',
        'attended': true,
      },
      {
        'name': 'Buwan Ng Wika',
        'date': 'April 06-12, 2026',
        'timeIn': '08:50 AM',
        'timeOut': '07:50 PM',
        'attended': true,
      },
      {
        'name': 'Panaghigalaay',
        'date': 'April 06-12, 2026',
        'timeIn': null,
        'timeOut': null,
        'attended': false,
      },
      {
        'name': 'Siglakas 2025',
        'date': 'April 06-12, 2026',
        'timeIn': '08:50 AM',
        'timeOut': '07:50 PM',
        'attended': true,
      },
    ];

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGray, width: 1),
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
          Text(
            event['date'],
            style: const TextStyle(color: darkGray, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: event['attended']
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeRow('Time-in:', event['timeIn']),
                      _buildTimeRow('Time-out:', event['timeOut']),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String? time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: darkGray, fontSize: 14)),
        Text(
          time ?? '-',
          style: const TextStyle(
            color: royalBlue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRateTab() {
    final rateEvents = [
      {
        'name': 'Buwan Ng Wika',
        'date': 'April 06-12, 2026',
        'rating': 4.5,
        'reviews': 125,
        'ratingBreakdown': {'5': 75, '4': 15, '3': 5, '2': 3, '1': 2},
      },
      {
        'name': 'General Convocation',
        'date': 'April 06-12, 2026',
        'rating': 4.7,
        'reviews': 125,
        'ratingBreakdown': {'5': 80, '4': 15, '3': 5, '2': 0, '1': 0},
      },
    ];

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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGray, width: 1),
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
                      fontSize: 32,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rated $rating stars')),
                      );
                    },
                    icon: Icon(
                      index < selectedRating
                          ? Ionicons.star
                          : Ionicons.star_outline,
                      color: index < selectedRating ? gold : darkGray,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Optional: Share your thoughts to help us improve...',
              hintStyle: const TextStyle(color: darkGray, fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: lightGray),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedRating > 0
                          ? 'Rating submitted for $eventName: $selectedRating stars'
                          : 'Please select a rating for $eventName',
                    ),
                  ),
                );
              },
              child: const Text(
                'Submit Rating',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
      }).toList(),
    ];
  }
}
