import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/avatar_sync_service.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../../student_management/data/academic_term_service.dart';
import '../../data/supabase_admin_profile_repository_impl.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);

class ActivityCardScreen extends StatefulWidget {
  const ActivityCardScreen({super.key});

  @override
  State<ActivityCardScreen> createState() => _ActivityCardScreenState();
}

class _ActivityCardScreenState extends State<ActivityCardScreen> {
  String _adminName = '';
  String _adminFaculty = '';
  String _adminId = '';
  String _avatarUrl = '';

  static const int _maxItemsPerRow = 8;
  static const int _maxItemsTotal = _maxItemsPerRow * 2;

  static const String _requirementsView = 'obligatory_requirements';
  static const String _eventsTable = 'events';
  static const String _paymentRequirementsTable = 'payment_requirements';
  static const String _adminsTable = 'admins';
  static const String _adminActivityCardsTable = 'admin_activity_cards';

  static const String _eventRequirementType = 'event';
  static const String _paymentRequirementType = 'payment';

  List<(String, bool)> _rowOneActivities = const [];
  List<(String, bool)> _rowTwoActivities = const [];
  bool _isOfficiallyCleared = false;
  bool _isStampingCard = false;
  bool _isStampedByAdmin = false;
  AcademicTermOption? _activeAcademicTerm;

  @override
  void initState() {
    super.initState();

    final syncedAvatar = AvatarSyncService.notifier.value;
    if (syncedAvatar.email == _normalizedCurrentEmail() &&
        syncedAvatar.avatarUrl != null) {
      _avatarUrl = syncedAvatar.avatarUrl!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdminProfile();
      _initializeCardData();
    });
  }

  Future<void> _initializeCardData() async {
    await _loadAcademicTerm();
    await _loadObligatoryActivities();
  }

  Future<void> _loadAdminProfile() async {
    final currentUser = SupabaseAuthService.currentUser;
    final email = _readLabel(currentUser?.email);
    final metadata = currentUser?.userMetadata ?? const <String, dynamic>{};

    final admin = <String, dynamic>{};
    var avatarFromProfileRepo = '';

    try {
      final avatar = await SupabaseAdminProfileRepositoryImpl.instance
          .getCurrentAvatarUrl();
      if (avatar != null) {
        avatarFromProfileRepo = _readLabel(avatar);
      }
    } catch (_) {
      // Ignore and continue with table lookup.
    }

    if (email.isNotEmpty) {
      try {
        final remoteAdminRow = await Supabase.instance.client
            .from(_adminsTable)
            .select('id, email, full_name, faculty, profile_photo_url')
            .ilike('email', email)
            .maybeSingle();
        if (remoteAdminRow != null) {
          admin.addAll(Map<String, dynamic>.from(remoteAdminRow));
        }
      } catch (_) {
        // Ignore and continue with metadata fallback.
      }
    }

    final resolvedName = _firstNonEmpty([
      admin['full_name'],
      admin['fullName'],
      metadata['full_name'],
      _metadataCombinedName(metadata),
      'Admin',
    ]);
    final resolvedFaculty = _firstNonEmpty([
      admin['faculty'],
      metadata['faculty'],
      'N/A',
    ]);
    final adminIdValue = _firstNonEmpty([admin['id'], metadata['admin_id']]);
    final resolvedAdminId = adminIdValue.isEmpty
        ? 'Admin ID: N/A'
        : 'Admin ID: $adminIdValue';
    final resolvedAvatarUrl = _firstNonEmpty([
      admin['profile_photo_url'],
      admin['profilePhotoUrl'],
      _avatarUrl,
      avatarFromProfileRepo,
    ]);
    final resolvedEmail = _firstNonEmpty([admin['email'], email]);

    if (!mounted) {
      return;
    }

    setState(() {
      _adminName = resolvedName;
      _adminFaculty = resolvedFaculty;
      _adminId = resolvedAdminId;
      _avatarUrl = resolvedAvatarUrl;
    });

    AvatarSyncService.setAvatar(email: resolvedEmail, avatarUrl: _avatarUrl);
  }

  String? _normalizedCurrentEmail() {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    return email.toLowerCase();
  }

  Future<void> _loadAcademicTerm() async {
    List<AcademicTermOption> terms = const <AcademicTermOption>[];

    try {
      terms = await AcademicTermService.fetchTerms();
    } catch (_) {
      terms = const <AcademicTermOption>[];
    }

    AcademicTermOption? activeTerm;
    for (final term in terms) {
      if (term.isActive) {
        activeTerm = term;
        break;
      }
    }

    activeTerm ??= terms.isNotEmpty ? terms.first : null;

    if (!mounted) {
      return;
    }

    setState(() {
      _activeAcademicTerm = activeTerm;
    });
  }

  String get _activityCardTermLabel {
    final activeTerm = _activeAcademicTerm;
    if (activeTerm == null) {
      return 'No active term selected';
    }

    return '${activeTerm.semester} • A.Y. ${activeTerm.academicYear}';
  }

  Future<void> _loadObligatoryActivities() async {
    List<(String, bool)> activities = const [];

    try {
      final requirements = await _fetchObligatoryActivities();
      activities = await _buildActivityItems(requirements);
    } catch (_) {
      activities = const [];
    }

    if (!mounted) {
      return;
    }

    final capped = activities.take(_maxItemsTotal).toList(growable: false);
    final isOfficiallyCleared =
        capped.isNotEmpty && capped.every((item) => item.$2);
    var stampState = false;

    if (isOfficiallyCleared) {
      final termId = _activeAcademicTerm?.id ?? 0;
      if (termId > 0) {
        try {
          final adminId = await _resolveCurrentAdminIdOrZero();
          if (adminId > 0) {
            stampState = await _fetchAdminActivityCardStampState(
              adminId: adminId,
              termId: termId,
            );
          }
        } catch (_) {
          stampState = false;
        }
      }
    }

    setState(() {
      _rowOneActivities = capped.take(_maxItemsPerRow).toList(growable: false);
      _rowTwoActivities = capped
          .skip(_maxItemsPerRow)
          .take(_maxItemsPerRow)
          .toList(growable: false);
      _isOfficiallyCleared = isOfficiallyCleared;
      _isStampedByAdmin = stampState;
    });
  }

  bool get _shouldShowOfficialStamp =>
      _isOfficiallyCleared && _isStampedByAdmin;

  Future<void> _onStampCardPressed() async {
    if (_isStampingCard) {
      return;
    }

    if (!_isOfficiallyCleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All mandatory requirements must be cleared before stamping.',
          ),
        ),
      );
      return;
    }

    final activeTermId = _activeAcademicTerm?.id ?? 0;
    if (activeTermId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active academic term available.')),
      );
      return;
    }

    final adminId = await _resolveCurrentAdminIdOrZero();
    if (adminId <= 0) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to resolve admin account.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isStampingCard = true;
    });

    try {
      await _stampAdminActivityCardForTerm(
        adminId: adminId,
        termId: activeTermId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isStampedByAdmin = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity card stamped successfully.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to stamp activity card.')),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isStampingCard = false;
      });
    }
  }

  Future<bool> _fetchAdminActivityCardStampState({
    required int adminId,
    required int termId,
  }) async {
    final response = await Supabase.instance.client
        .from(_adminActivityCardsTable)
        .select('is_stamp')
        .eq('admin_id', adminId)
        .eq('term_id', termId)
        .maybeSingle();

    if (response == null) {
      return false;
    }

    final stampValue = response['is_stamp'];
    if (stampValue is bool) {
      return stampValue;
    }

    return _readLabel(stampValue).toLowerCase() == 'true';
  }

  Future<void> _stampAdminActivityCardForTerm({
    required int adminId,
    required int termId,
  }) async {
    await Supabase.instance.client.from(_adminActivityCardsTable).upsert({
      'admin_id': adminId,
      'term_id': termId,
      'is_stamp': true,
    }, onConflict: 'admin_id,term_id');
  }

  Future<int> _resolveCurrentAdminIdOrZero() async {
    final user = SupabaseAuthService.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final metadataAdminId = _readInt(metadata['admin_id']);
    if (metadataAdminId > 0) {
      return metadataAdminId;
    }

    final visibleAdminId = _readInt(_adminId.replaceFirst('Admin ID:', ''));
    if (visibleAdminId > 0) {
      return visibleAdminId;
    }

    final email = _readLabel(user?.email);
    if (email.isEmpty) {
      return 0;
    }

    try {
      final row = await Supabase.instance.client
          .from(_adminsTable)
          .select('id')
          .ilike('email', email)
          .maybeSingle();
      return _readInt(row?['id']);
    } catch (_) {
      return 0;
    }
  }

  Future<List<(String, bool)>> _buildActivityItems(
    List<_ObligatoryActivity> requirements,
  ) async {
    return requirements
        .map<(String, bool)>((item) => (item.label, true))
        .take(_maxItemsTotal)
        .toList(growable: false);
  }

  Future<List<_ObligatoryActivity>> _fetchObligatoryActivities() async {
    final activeTerm = _activeAcademicTerm;
    if (activeTerm == null) {
      return const <_ObligatoryActivity>[];
    }

    final client = Supabase.instance.client;

    try {
      final response = await client
          .from(_requirementsView)
          .select(
            'requirement_type, source_id, title, description, date_or_deadline, amount, academic_year, academic_period',
          )
          .eq('academic_year', activeTerm.academicYear)
          .eq('academic_period', activeTerm.semester)
          .order('requirement_type', ascending: true)
          .order('source_id', ascending: true)
          .limit(_maxItemsTotal);

      return _mapRequirementRows(List<Map<String, dynamic>>.from(response));
    } on PostgrestException {
      return _fetchObligatoryActivitiesWithoutView(client);
    }
  }

  Future<List<_ObligatoryActivity>> _fetchObligatoryActivitiesWithoutView(
    SupabaseClient client,
  ) async {
    final activeTermId = _activeAcademicTerm?.id;
    if (activeTermId == null || activeTermId <= 0) {
      return const <_ObligatoryActivity>[];
    }

    final eventRows = await client
        .from(_eventsTable)
        .select('id, name')
        .eq('is_mandatory', true)
        .eq('term_id', activeTermId)
        .order('event_date', ascending: true)
        .order('id', ascending: true);

    final paymentRows = await client
        .from(_paymentRequirementsTable)
        .select('id, title')
        .eq('is_mandatory', true)
        .eq('term_id', activeTermId)
        .order('id', ascending: true);

    final events = List<Map<String, dynamic>>.from(eventRows)
        .map(
          (row) => _ObligatoryActivity(
            type: _eventRequirementType,
            sourceId: _readInt(row['id']),
            label: _readLabel(row['name']),
          ),
        )
        .where((item) => item.sourceId > 0 && item.label.isNotEmpty);

    final payments = List<Map<String, dynamic>>.from(paymentRows)
        .map(
          (row) => _ObligatoryActivity(
            type: _paymentRequirementType,
            sourceId: _readInt(row['id']),
            label: _readLabel(row['title']),
          ),
        )
        .where((item) => item.sourceId > 0 && item.label.isNotEmpty);

    final combined = [...events, ...payments];
    return combined.take(_maxItemsTotal).toList(growable: false);
  }

  List<_ObligatoryActivity> _mapRequirementRows(
    List<Map<String, dynamic>> rows,
  ) {
    return rows
        .map(
          (row) => _ObligatoryActivity(
            type: _normalizeRequirementType(row['requirement_type']),
            sourceId: _readInt(row['source_id']),
            label: _readLabel(row['title']),
          ),
        )
        .where(
          (item) =>
              item.sourceId > 0 &&
              item.label.isNotEmpty &&
              (item.type == _eventRequirementType ||
                  item.type == _paymentRequirementType),
        )
        .take(_maxItemsTotal)
        .toList(growable: false);
  }

  String _normalizeRequirementType(dynamic value) {
    final normalized = _readLabel(value).toLowerCase();
    if (normalized.startsWith('event')) {
      return _eventRequirementType;
    }
    if (normalized.startsWith('payment')) {
      return _paymentRequirementType;
    }

    return normalized;
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final normalized = _readLabel(value);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return '';
  }

  String _metadataCombinedName(Map<String, dynamic> metadata) {
    final firstName = _readLabel(metadata['first_name']);
    final lastName = _readLabel(metadata['last_name']);
    final combined = '$firstName $lastName'.trim();
    return combined;
  }

  String _readLabel(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  Widget _buildAdminAvatarImage() {
    if (_avatarUrl.isNotEmpty) {
      return Image.network(
        _avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/my_profile.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Ionicons.person, color: Colors.white, size: 63);
            },
          );
        },
      );
    }

    return Image.asset(
      'assets/images/my_profile.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Ionicons.person, color: Colors.white, size: 63);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final isStampedByAdmin = _isStampedByAdmin;

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: _isStampingCard ? null : _onStampCardPressed,
          tooltip: _isStampingCard
              ? 'Stamping activity cards...'
              : isStampedByAdmin
              ? 'Card already stamped'
              : 'Stamp activity card',
          backgroundColor: isStampedByAdmin ? royalBlue : gold,
          foregroundColor: isStampedByAdmin ? gold : royalBlue,
          child: _isStampingCard
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isStampedByAdmin ? Ionicons.ribbon : Ionicons.ribbon_outline,
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                  _buildHeader(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Center(
                            child: SizedBox(
                              width: constraints.maxWidth > 420
                                  ? 420
                                  : constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: _buildMainCard(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: royalBlue),
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
                    text: 'Activity ',
                    style: TextStyle(color: royalBlue),
                  ),
                  TextSpan(
                    text: 'Card',
                    style: TextStyle(color: gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
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
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 148, 10, 22),
                      child: _buildActivitiesGrid(),
                    ),
                  ),
                  _buildRightBanner(),
                ],
              ),
            ),
            Positioned(top: 80, left: -48, child: _buildProfileSection()),
            if (_shouldShowOfficialStamp)
              Positioned(
                left: -60,
                bottom: 12,
                child: Transform.rotate(
                  angle: 1.57079632679,
                  child: _buildOfficiallyClearedTab(),
                ),
              ),
            if (_shouldShowOfficialStamp)
              Positioned(
                left: 83,
                bottom: 37,
                child: Transform.rotate(
                  angle: 1.57079632679,
                  child: SizedBox(
                    width: 135,
                    height: 135,
                    child: _buildClearedStamp(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 500,
        height: 378,
        child: Center(
          child: Transform.rotate(
            angle: 1.57079632679,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 1000,
                height: 250,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 130,
                        height: 130,
                        color: royalBlue,
                        child: _buildAdminAvatarImage(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _adminName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: royalBlue,
                              fontSize: 26,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _adminFaculty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1F2C40),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _adminId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1F2C40),
                              fontSize: 20,
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
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 166,
        height: 244,
        child: Align(
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: const Offset(-244, 41),
            child: Transform.scale(
              scale: 3.3,
              alignment: Alignment.topLeft,
              child: Transform.rotate(
                angle: 1.57079632679,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 430,
                    height: 164,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildActivityRow(
                          _rowOneActivities,
                          includeMiddleGap: false,
                        ),
                        const SizedBox(height: 4),
                        _buildActivityRow(
                          _rowTwoActivities,
                          includeMiddleGap: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityRow(
    List<(String, bool)> items, {
    required bool includeMiddleGap,
  }) {
    const double itemSlotWidth = 45;
    const double normalGap = 10;
    const double middleGap = 10;

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          SizedBox(
            width: itemSlotWidth,
            child: _buildActivityItem(items[index].$1, items[index].$2),
          ),
          if (index != items.length - 1)
            SizedBox(
              width: includeMiddleGap && index == 1 ? middleGap : normalGap,
            ),
        ],
      ],
    );
  }

  Widget _buildActivityItem(String label, bool active) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 78,
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? const Color(0xFF8FA5E2)
                      : const Color(0xFFE7E7E7),
                ),
                child: Icon(
                  Ionicons.calendar_clear_outline,
                  size: 24,
                  color: active ? royalBlue : const Color(0xFF9B9B9B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.05,
                  color: active ? royalBlue : const Color(0xFF8A8A8A),
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightBanner() {
    return Container(
      width: 82,
      color: royalBlue,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 10, color: gold),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Transform.rotate(
                angle: 1.57079632679,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logos/vouch_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Ionicons.shield_checkmark,
                          color: royalBlue,
                          size: 26,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: -28,
            child: Transform.rotate(
              angle: 1.57079632679,
              child: SizedBox(
                width: 128,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Text(
                          'Vouch',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 35,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1.2
                              ..color = Colors.white,
                          ),
                        ),
                        Text(
                          'Vouch',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Organization',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 433,
            right: -77,
            child: Transform.rotate(
              angle: 1.57079632679,
              child: SizedBox(
                width: 400,
                height: 215,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ACTIVITY CLEARANCE CARD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(
                      '                  $_activityCardTermLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearedStamp() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: royalBlue.withOpacity(0.04),
          border: Border.all(color: royalBlue, width: 3.0),
          boxShadow: [
            BoxShadow(
              color: royalBlue.withOpacity(0.16),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: royalBlue, width: 2.0),
              ),
            ),
            Positioned(
              top: 13,
              child: Stack(
                children: [
                  Text(
                    'Vouch',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.9
                        ..color = royalBlue,
                    ),
                  ),
                  const Text(
                    'Vouch',
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(-18, 8),
              child: Transform.rotate(
                angle: -0.52,
                child: Transform.scale(
                  scale: 1.2,
                  child: Stack(
                    children: [
                      Text(
                        'CLEARED',
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 34,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2.0
                            ..color = royalBlue,
                        ),
                      ),
                      const Text(
                        'CLEARED',
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: royalBlue,
                          fontSize: 34,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 13,
              child: Stack(
                children: [
                  Text(
                    'Vouch',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.9
                        ..color = royalBlue,
                    ),
                  ),
                  const Text(
                    'Vouch',
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficiallyClearedTab() {
    return Container(
      width: 170,
      height: 50,
      decoration: const BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(
                Ionicons.checkmark,
                color: Color(0xFFE0B100),
                size: 16,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'OFFICIALLY\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: 'CLEARED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObligatoryActivity {
  const _ObligatoryActivity({
    required this.type,
    required this.sourceId,
    required this.label,
  });

  final String type;
  final int sourceId;
  final String label;
}
