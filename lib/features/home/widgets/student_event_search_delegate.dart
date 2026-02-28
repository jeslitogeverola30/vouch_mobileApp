import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class StudentEventSearchDelegate extends SearchDelegate<Map<String, String>?> {
  final List<Map<String, String>> events;

  StudentEventSearchDelegate({required this.events});

  List<Map<String, String>> _filteredEvents() {
    if (query.trim().isEmpty) {
      return events;
    }

    final lowerQuery = query.trim().toLowerCase();

    return events.where((event) {
      final name = (event['name'] ?? '').toLowerCase();
      final date = (event['date'] ?? '').toLowerCase();
      final description = (event['description'] ?? '').toLowerCase();

      return name.contains(lowerQuery) ||
          date.contains(lowerQuery) ||
          description.contains(lowerQuery);
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
    return _buildEventList(context, _filteredEvents());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildEventList(context, _filteredEvents(), isSuggestion: true);
  }

  Widget _buildEventList(
    BuildContext context,
    List<Map<String, String>> filteredEvents, {
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
              "Today's Event",
              style: TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ...filteredEvents.map((event) {
          final imagePath = event['image'] ?? 'assets/images/panaghigalaay.jpg';
          final timeIn = event['timeIn'] ?? 'Time-in not available';
          final timeOut = event['timeOut'] ?? 'Time-out not available';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => close(context, event),
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
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
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
                                  event['name'] ?? 'Event',
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
                            event['date'] ?? 'Date not available',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if ((event['description'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              event['description']!,
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
}
