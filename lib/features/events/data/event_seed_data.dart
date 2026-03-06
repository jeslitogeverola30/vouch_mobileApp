class EventSeedData {
  EventSeedData._();

  static final List<Map<String, dynamic>> upcomingEvents = [
    {
      'name': 'Mind & Wellness',
      'date': 'November 06, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '04:00 PM - 04:15 PM',
      'image': 'assets/images/mind-wellnes.jpg',
      'isObligatory': false,
    },
    {
      'name': 'Service & Outreach',
      'date': 'November 10, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '04:00 PM - 04:15 PM',
      'image': 'assets/images/service-outreach.jpg',
      'isObligatory': false,
    },
    {
      'name': 'Siglakas Day 1',
      'date': 'April 06-12, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '08:00 PM - 08:15 PM',
      'image': 'assets/images/event-siglakas.jpg',
      'isObligatory': true,
    },
    {
      'name': 'Siglakas Day 2',
      'date': 'April 06-12, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '08:00 PM - 08:15 PM',
      'image': 'assets/images/event-siglakas.jpg',
      'isObligatory': true,
    },
  ];

  static final List<Map<String, dynamic>> pastEvents = [
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

  static final List<Map<String, dynamic>> ratedEvents = [
    {
      'name': 'Buwan Ng Wika',
      'date': 'April 06-12, 2026',
      'rating': 4.5,
      'reviews': 125,
      'ratingBreakdown': {'5': 75, '4': 15, '3': 5, '2': 3, '1': 2},
      'comments': [
        {
          'name': 'A. Student',
          'comment': 'Very organized and enjoyable event.',
          'date': 'Apr 13, 2026',
        },
        {
          'name': 'M. Garcia',
          'comment': 'Program flow was smooth from start to finish.',
          'date': 'Apr 13, 2026',
        },
      ],
    },
    {
      'name': 'General Convocation',
      'date': 'April 06-12, 2026',
      'rating': 4.7,
      'reviews': 125,
      'ratingBreakdown': {'5': 80, '4': 15, '3': 5, '2': 0, '1': 0},
      'comments': [
        {
          'name': 'R. Dela Cruz',
          'comment': 'Speakers were informative and engaging.',
          'date': 'Apr 14, 2026',
        },
        {
          'name': 'J. Santos',
          'comment': 'Sound system and venue setup were excellent.',
          'date': 'Apr 14, 2026',
        },
      ],
    },
  ];

  static const List<String> feedbackSuggestions = [
    'Well organized',
    'Engaging activities',
    'Clear instructions',
    'Great venue',
    'Needs improvement',
  ];
}
