import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../events/data/event_query_service.dart';
import '../../events/domain/event_date_time_formatters.dart';
import '../../events/presentation/student/student_event_details_screen.dart';

class StudentEventSearchDelegate extends SearchDelegate<void> {
  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;
  bool _hasFetched = false;

  StudentEventSearchDelegate() {
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await EventQueryService.fetchEvents();
      _allEvents = events;
    } catch (_) {
      _allEvents = [];
    } finally {
      _isLoading = false;
      _hasFetched = true;
    }
  }

  List<Map<String, dynamic>> _filteredEvents() {
    if (query.trim().isEmpty) {
      return _allEvents;
    }

    final lowerQuery = query.trim().toLowerCase();

    return _allEvents.where((event) {
      final name = (event['name'] as String? ?? '').toLowerCase();
      final date = (event['date'] as String? ?? '').toLowerCase();
      final description = (event['description'] as String? ?? '').toLowerCase();
      final shortDescription =
          (event['shortDescription'] as String? ?? '').toLowerCase();

      return name.contains(lowerQuery) ||
          date.contains(lowerQuery) ||
          description.contains(lowerQuery) ||
          shortDescription.contains(lowerQuery);
    }).toList();
  }

  @override
  String get searchFieldLabel => 'Search event name, date, or keyword';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF003DA5),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Color(0xFF003DA5),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Ionicons.close_outline),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Ionicons.arrow_back_outline),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildBody(context, isSuggestion: true);
  }

  Widget _buildBody(BuildContext context, {bool isSuggestion = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return StatefulBuilder(
      builder: (context, setState) {
        final filtered = _filteredEvents();
        return _buildEventList(context, filtered, isSuggestion: isSuggestion);
      },
    );
  }

  Widget _buildEventList(
    BuildContext context,
    List<Map<String, dynamic>> filteredEvents, {
    bool isSuggestion = false,
  }) {
    if (filteredEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Ionicons.search_outline,
                size: 44,
                color: Color(0xFF003DA5),
              ),
              const SizedBox(height: 10),
              const Text(
                'No matching events found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                query.trim().isEmpty
                    ? 'Try searching event name, date, or keyword.'
                    : 'Try another keyword to find your event.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        if (isSuggestion && query.trim().isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Events",
              style: TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ...filteredEvents.map((event) {
          final imagePath =
              event['image'] as String? ?? 'assets/images/event-siglakas.jpg';
          final timeIn = event['timeIn'] as String? ?? '-';
          final timeOut = event['timeOut'] as String? ?? '-';
          final shortDescription =
              event['shortDescription'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(
                      eventImage: imagePath,
                      eventName: event['name'] as String? ?? 'Event',
                      eventDate:
                          event['date'] as String? ?? 'Date not available',
                      eventTime: EventDateTimeFormatters.buildEventTimeText(
                        timeIn: event['timeIn'] as String?,
                        timeOut: event['timeOut'] as String?,
                      ),
                      location:
                          event['location'] as String? ?? 'University Campus',
                      locationSubtitle:
                          event['locationSubtitle'] as String? ?? '',
                      shortDescription: shortDescription.isNotEmpty
                          ? shortDescription
                          : 'No short description available for this event.',
                      description: event['description'] as String? ??
                          'No description available for this event.',
                      isObligatory:
                          event['isObligatory'] as bool? ?? false,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF003DA5).withOpacity(0.1),
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
                      child: _buildEventImage(imagePath,
                          width: double.infinity, height: 130),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event['name'] as String? ?? 'Event',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Ionicons.chevron_forward_outline,
                                color: Color(0xFF003DA5),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event['date'] as String? ?? 'Date not available',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (shortDescription.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              shortDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            'Time in: $timeIn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF003DA5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Time out: $timeOut',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF003DA5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
}