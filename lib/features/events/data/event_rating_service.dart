import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../../profile/data/supabase_profile_repository_impl.dart';
import '../domain/event_date_time_formatters.dart';
import 'event_query_service.dart';

class EventRatingService {
  EventRatingService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _ratingsTable = 'event_ratings';
  static const String _studentsTable = 'students';

  static Future<List<Map<String, dynamic>>> fetchStudentRateEvents() async {
    final events = await EventQueryService.fetchEvents();
    if (events.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final eventIds = _extractEventIds(events);
    final ratings = await _fetchRatingsForEventIds(eventIds);
    final summaries = _buildSummaryByEventId(ratings);

    final studentId = await _resolveCurrentStudentIdOrEmpty();
    final ratingsByEventId = _studentRatingsByEventId(
      ratings: ratings,
      studentId: studentId,
    );

    return events.map((event) {
      final eventId = _readInt(event['id']);
      final summary = eventId == null
          ? const _RatingSummary.empty()
          : (summaries[eventId] ?? const _RatingSummary.empty());
      final studentRatingRow = eventId == null
          ? null
          : ratingsByEventId[eventId];

      return {
        'eventId': eventId,
        'name': event['name'] as String? ?? 'Event',
        'date': event['date'] as String? ?? 'Date not available',
        'rating': summary.average,
        'reviews': summary.totalReviews,
        'ratingBreakdown': summary.percentageBreakdown,
        'myRating': _readInt(studentRatingRow?['rating']),
        'myComment': _readString(studentRatingRow?['comment']),
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchAdminRateEvents() async {
    final events = await EventQueryService.fetchEvents();
    if (events.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final eventIds = _extractEventIds(events);
    final ratings = await _fetchRatingsForEventIds(eventIds);

    final studentIds = ratings
        .map((row) => _readString(row['student_id']))
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .toList();
    final studentNamesById = await _fetchStudentNamesByIds(studentIds);

    final summaries = _buildSummaryByEventId(
      ratings,
      includeComments: true,
      studentNamesById: studentNamesById,
    );

    return events.map((event) {
      final eventId = _readInt(event['id']);
      final summary = eventId == null
          ? const _RatingSummary.empty()
          : (summaries[eventId] ?? const _RatingSummary.empty());

      return {
        'eventId': eventId,
        'name': event['name'] as String? ?? 'Event',
        'date': event['date'] as String? ?? 'Date not available',
        'rating': summary.average,
        'reviews': summary.totalReviews,
        'ratingBreakdown': summary.percentageBreakdown,
        'comments': summary.comments,
      };
    }).toList();
  }

  static Future<void> submitStudentRating({
    required int eventId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    final studentId = await _resolveCurrentStudentId();

    try {
      await _client.from(_ratingsTable).insert({
        'event_id': eventId,
        'student_id': studentId,
        'rating': rating,
        'comment': comment.trim(),
      });
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const RatingAlreadySubmittedException();
      }

      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchRatingsForEventIds(
    List<int> eventIds,
  ) async {
    if (eventIds.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final response = await _client
        .from(_ratingsTable)
        .select('event_id, student_id, rating, comment, created_at')
        .inFilter('event_id', eventIds)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, String>> _fetchStudentNamesByIds(
    List<String> studentIds,
  ) async {
    if (studentIds.isEmpty) {
      return const <String, String>{};
    }

    final response = await _client
        .from(_studentsTable)
        .select('student_id, full_name')
        .inFilter('student_id', studentIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final mapped = <String, String>{};

    for (final row in rows) {
      final studentId = _readString(row['student_id']);
      if (studentId.isEmpty) {
        continue;
      }

      mapped[studentId] = _readString(row['full_name']);
    }

    return mapped;
  }

  static Map<int, _RatingSummary> _buildSummaryByEventId(
    List<Map<String, dynamic>> rows, {
    bool includeComments = false,
    Map<String, String> studentNamesById = const <String, String>{},
  }) {
    final summaries = <int, _MutableRatingSummary>{};

    for (final row in rows) {
      final eventId = _readInt(row['event_id']);
      final rating = _readInt(row['rating']);

      if (eventId == null || rating == null || rating < 1 || rating > 5) {
        continue;
      }

      final summary = summaries.putIfAbsent(
        eventId,
        () => _MutableRatingSummary(),
      );

      summary.totalReviews += 1;
      summary.totalStars += rating;
      summary.starCounts[rating] = (summary.starCounts[rating] ?? 0) + 1;

      if (!includeComments) {
        continue;
      }

      final comment = _readString(row['comment']);
      if (comment.isEmpty) {
        continue;
      }

      final studentId = _readString(row['student_id']);
      final studentName = _readString(studentNamesById[studentId]).isNotEmpty
          ? _readString(studentNamesById[studentId])
          : 'Student';
      final createdAt = _parseDateTime(row['created_at']);

      summary.comments.add({
        'name': studentName,
        'comment': comment,
        'date': createdAt == null
            ? ''
            : EventDateTimeFormatters.displayDate(createdAt.toLocal()),
      });
    }

    final output = <int, _RatingSummary>{};

    for (final entry in summaries.entries) {
      final totalReviews = entry.value.totalReviews;
      final totalStars = entry.value.totalStars;
      final average = totalReviews <= 0
          ? 0.0
          : double.parse((totalStars / totalReviews).toStringAsFixed(1));

      output[entry.key] = _RatingSummary(
        average: average,
        totalReviews: totalReviews,
        percentageBreakdown: {
          '5': _percentage(entry.value.starCounts[5] ?? 0, totalReviews),
          '4': _percentage(entry.value.starCounts[4] ?? 0, totalReviews),
          '3': _percentage(entry.value.starCounts[3] ?? 0, totalReviews),
          '2': _percentage(entry.value.starCounts[2] ?? 0, totalReviews),
          '1': _percentage(entry.value.starCounts[1] ?? 0, totalReviews),
        },
        comments: List<Map<String, dynamic>>.from(entry.value.comments),
      );
    }

    return output;
  }

  static Map<int, Map<String, dynamic>> _studentRatingsByEventId({
    required List<Map<String, dynamic>> ratings,
    required String studentId,
  }) {
    if (studentId.isEmpty) {
      return const <int, Map<String, dynamic>>{};
    }

    final output = <int, Map<String, dynamic>>{};

    for (final row in ratings) {
      final rowStudentId = _readString(row['student_id']);
      if (rowStudentId != studentId) {
        continue;
      }

      final eventId = _readInt(row['event_id']);
      if (eventId == null) {
        continue;
      }

      output[eventId] = row;
    }

    return output;
  }

  static Future<String> _resolveCurrentStudentId() async {
    final studentId = await _resolveCurrentStudentIdOrEmpty();
    if (studentId.isNotEmpty) {
      return studentId;
    }

    throw Exception('Current student profile could not be resolved.');
  }

  static Future<String> _resolveCurrentStudentIdOrEmpty() async {
    final profile = await SupabaseProfileRepositoryImpl.instance
        .getCurrentUserProfile();
    final profileStudentId = _readString(profile?.studentId);
    if (profileStudentId.isNotEmpty) {
      return profileStudentId;
    }

    final user = SupabaseAuthService.currentUser;
    final metadataStudentId = _readString(user?.userMetadata?['student_id']);
    if (metadataStudentId.isNotEmpty) {
      return metadataStudentId;
    }

    final email = _readString(user?.email);
    if (email.isEmpty) {
      return '';
    }

    final studentRow = await _client
        .from(_studentsTable)
        .select('student_id')
        .ilike('email', email)
        .maybeSingle();

    return _readString(studentRow?['student_id']);
  }

  static List<int> _extractEventIds(List<Map<String, dynamic>> events) {
    return events
        .map((event) => _readInt(event['id']))
        .whereType<int>()
        .toSet()
        .toList();
  }

  static int _percentage(int numerator, int denominator) {
    if (denominator <= 0) {
      return 0;
    }

    return ((numerator / denominator) * 100).round();
  }

  static int? _readInt(dynamic value) {
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

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = _readString(value);
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }
}

class _MutableRatingSummary {
  int totalReviews = 0;
  int totalStars = 0;
  final Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  final List<Map<String, dynamic>> comments = <Map<String, dynamic>>[];
}

class RatingAlreadySubmittedException implements Exception {
  const RatingAlreadySubmittedException();

  @override
  String toString() {
    return 'Rating already submitted for this event.';
  }
}

class _RatingSummary {
  const _RatingSummary({
    required this.average,
    required this.totalReviews,
    required this.percentageBreakdown,
    required this.comments,
  });

  const _RatingSummary.empty()
    : average = 0,
      totalReviews = 0,
      percentageBreakdown = const <String, int>{
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      },
      comments = const <Map<String, dynamic>>[];

  final double average;
  final int totalReviews;
  final Map<String, int> percentageBreakdown;
  final List<Map<String, dynamic>> comments;
}
