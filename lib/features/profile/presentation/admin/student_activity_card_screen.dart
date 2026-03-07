import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/local/database_helper.dart';
import '../../../../core/services/avatar_sync_service.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../../student_management/data/academic_term_service.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);

class StudentActivityCardScreen extends StatefulWidget {
  const StudentActivityCardScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.email,
    required this.program,
    this.avatarUrl = '',
  });

  final String studentName;
  final String studentId;
  final String email;
  final String program;
  final String avatarUrl;

  @override
  State<StudentActivityCardScreen> createState() =>
      _StudentActivityCardScreenState();
}

class _StudentActivityCardScreenState extends State<StudentActivityCardScreen> {
  String _studentName = '';
  String _studentProgram = '';
  String _studentId = '';
  String _studentEmail = '';
  String _avatarUrl = '';

  static const int _maxItemsPerRow = 8;
  static const int _maxItemsTotal = _maxItemsPerRow * 2;

  static const String _requirementsView = 'obligatory_requirements';
  static const String _eventsTable = 'events';
  static const String _paymentRequirementsTable = 'payment_requirements';
  static const String _studentsTable = 'students';
  static const String _adminsTable = 'admins';
  static const String _eventAttendanceTable = 'event_attendance';
  static const String _transactionsTable = 'student_transactions';
  static const String _activityCardsTable = 'activity_cards';
  static const String _adminActivityCardsTable = 'admin_activity_cards';

  static const String _eventRequirementType = 'event';
  static const String _paymentRequirementType = 'payment';

  List<(String, bool)> _rowOneActivities = const [];
  List<(String, bool)> _rowTwoActivities = const [];
  bool _isOfficiallyCleared = false;
  bool _isApplyingClearance = false;
  bool _isStampingCard = false;
  bool _isAdminActivityCardStamped = false;
  bool _isStampedByAdmin = false;
  AcademicTermOption? _activeAcademicTerm;

  @override
  void initState() {
    super.initState();

    _studentName = _readLabel(widget.studentName);
    _studentProgram = _readLabel(widget.program);
    _studentId = _readLabel(widget.studentId);
    _studentEmail = _readLabel(widget.email).toLowerCase();
    _avatarUrl = _readLabel(widget.avatarUrl);

    final syncedAvatar = AvatarSyncService.notifier.value;
    if (_avatarUrl.isEmpty &&
        syncedAvatar.email == _normalizedTargetEmail() &&
        syncedAvatar.avatarUrl != null) {
      _avatarUrl = syncedAvatar.avatarUrl!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentProfile();
      _initializeCardData();
    });
  }

  Future<void> _initializeCardData() async {
    await _loadAcademicTerm();
    await _loadObligatoryActivities();
  }

  Future<void> _loadStudentProfile() async {
    final localStudentData = <String, dynamic>{};
    final remoteStudentData = <String, dynamic>{};
    final student = <String, dynamic>{};

    final targetStudentId = _readLabel(widget.studentId);
    final targetEmail = _normalizedTargetEmail();

    if (targetEmail.isNotEmpty) {
      final localStudentRow = await DatabaseHelper.instance.getStudentByEmail(
        targetEmail,
      );
      if (localStudentRow != null) {
        localStudentData.addAll(localStudentRow);
      }
    }

    if (targetStudentId.isNotEmpty) {
      try {
        final remoteStudentRow = await Supabase.instance.client
            .from(_studentsTable)
            .select('email, full_name, student_id, program, profile_photo_url')
            .eq('student_id', targetStudentId)
            .maybeSingle();
        if (remoteStudentRow != null) {
          remoteStudentData.addAll(Map<String, dynamic>.from(remoteStudentRow));
        }
      } catch (_) {
        // Ignore and continue with other fallbacks.
      }
    }

    if (remoteStudentData.isEmpty && targetEmail.isNotEmpty) {
      try {
        final remoteStudentRow = await Supabase.instance.client
            .from(_studentsTable)
            .select('email, full_name, student_id, program, profile_photo_url')
            .ilike('email', targetEmail)
            .maybeSingle();
        if (remoteStudentRow != null) {
          remoteStudentData.addAll(Map<String, dynamic>.from(remoteStudentRow));
        }
      } catch (_) {
        // Ignore and continue with local fallback values.
      }
    }

    student
      ..addAll(localStudentData)
      ..addAll(remoteStudentData);

    final resolvedName = _firstNonEmpty([
      student['full_name'],
      student['fullName'],
      widget.studentName,
      'Student',
    ]);
    final resolvedProgram = _firstNonEmpty([
      student['program'],
      widget.program,
      'N/A',
    ]);
    final resolvedStudentId = _firstNonEmpty([
      student['student_id'],
      student['studentId'],
      widget.studentId,
      'N/A',
    ]);
    final resolvedAvatarUrl = _firstNonEmpty([
      student['profile_photo_url'],
      student['profilePhotoUrl'],
      widget.avatarUrl,
      _avatarUrl,
    ]);
    final resolvedEmail = _firstNonEmpty([student['email'], targetEmail]);

    if (!mounted) {
      return;
    }

    setState(() {
      _studentName = resolvedName;
      _studentProgram = resolvedProgram;
      _studentId = resolvedStudentId;
      _studentEmail = resolvedEmail.toLowerCase();
      _avatarUrl = resolvedAvatarUrl;
    });

    AvatarSyncService.setAvatar(email: resolvedEmail, avatarUrl: _avatarUrl);
  }

  String _normalizedTargetEmail() {
    final email = _firstNonEmpty([_studentEmail, widget.email]).trim();
    if (email.isEmpty) {
      return '';
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
    final activeTermId = _activeAcademicTerm?.id ?? 0;
    var adminStampState = false;
    var studentStampState = false;

    if (activeTermId > 0) {
      try {
        final adminId = await _resolveCurrentAdminIdOrZero();
        if (adminId > 0) {
          adminStampState = await _fetchAdminActivityCardStampState(
            adminId: adminId,
            termId: activeTermId,
          );
        }
      } catch (_) {
        adminStampState = false;
      }
    }

    if (isOfficiallyCleared) {
      if (activeTermId > 0) {
        try {
          final studentId = await _resolveCurrentStudentIdOrEmpty();
          if (studentId.isNotEmpty) {
            studentStampState = await _fetchActivityCardStampState(
              studentId: studentId,
              termId: activeTermId,
            );
          }
        } catch (_) {
          studentStampState = false;
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
      _isAdminActivityCardStamped = adminStampState;
      _isStampedByAdmin = studentStampState;
    });
  }

  bool get _shouldShowOfficialStamp =>
      _isOfficiallyCleared && _isStampedByAdmin;

  Future<void> _onStampCardPressed() async {
    if (_isStampingCard) {
      return;
    }

    if (!_isAdminActivityCardStamped) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stamp your admin activity card first before stamping students.',
          ),
        ),
      );
      return;
    }

    if (!_isOfficiallyCleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student must clear all mandatory requirements before stamping.',
          ),
        ),
      );
      return;
    }

    if (_isStampedByAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This activity card is already stamped.')),
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

    final studentId = await _resolveCurrentStudentIdOrEmpty();
    if (studentId.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to resolve student account.')),
      );
      return;
    }

    setState(() {
      _isStampingCard = true;
    });

    try {
      await _stampActivityCardForTerm(
        studentId: studentId,
        termId: activeTermId,
        isCleared: _isOfficiallyCleared,
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

  Future<void> _clearStudentRequirements() async {
    if (_isApplyingClearance) {
      return;
    }

    List<_ObligatoryActivity> unclearedRequirements = const [];

    try {
      unclearedRequirements = await _fetchUnclearedRequirements();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load uncleared requirements.'),
          ),
        );
      }
      return;
    }

    if (!mounted) {
      return;
    }

    if (unclearedRequirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All mandatory requirements are cleared.'),
        ),
      );
      return;
    }

    final selectedRequirements = await _showClearConfirmationModal(
      unclearedRequirements,
    );

    if (!mounted ||
        selectedRequirements == null ||
        selectedRequirements.isEmpty) {
      return;
    }

    setState(() {
      _isApplyingClearance = true;
    });

    try {
      final studentId = await _resolveCurrentStudentIdOrEmpty();
      if (studentId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to resolve student account.')),
          );
        }
        return;
      }

      final eventIds = selectedRequirements
          .where((item) => item.type == _eventRequirementType)
          .map((item) => item.sourceId)
          .where((sourceId) => sourceId > 0)
          .toSet()
          .toList(growable: false);
      final paymentRequirementIds = selectedRequirements
          .where((item) => item.type == _paymentRequirementType)
          .map((item) => item.sourceId)
          .where((sourceId) => sourceId > 0)
          .toSet()
          .toList(growable: false);

      await _markEventsAsAttended(studentId, eventIds);
      await _markPaymentsAsApproved(studentId, paymentRequirementIds);
      await _loadObligatoryActivities();

      if (!mounted) {
        return;
      }

      final selectedCount = selectedRequirements.length;
      final requirementLabel = selectedCount == 1
          ? 'requirement'
          : 'requirements';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared $selectedCount mandatory $requirementLabel.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear all mandatory requirements.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingClearance = false;
        });
      }
    }
  }

  Future<List<_ObligatoryActivity>> _fetchUnclearedRequirements() async {
    final requirements = await _fetchObligatoryActivities();
    if (requirements.isEmpty) {
      return const [];
    }

    final activityItems = await _buildActivityItems(requirements);
    final maximumIndex = requirements.length < activityItems.length
        ? requirements.length
        : activityItems.length;

    final unclearedRequirements = <_ObligatoryActivity>[];
    for (var index = 0; index < maximumIndex; index++) {
      final isActive = activityItems[index].$2;
      if (!isActive) {
        unclearedRequirements.add(requirements[index]);
      }
    }

    return unclearedRequirements;
  }

  Future<List<_ObligatoryActivity>?> _showClearConfirmationModal(
    List<_ObligatoryActivity> unclearedRequirements,
  ) {
    final selectedKeys = unclearedRequirements.map(_requirementKey).toSet();

    return showDialog<List<_ObligatoryActivity>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalCount = unclearedRequirements.length;
            final selectedCount = selectedKeys.length;
            final allSelected = totalCount > 0 && selectedCount == totalCount;
            final hasSelection = selectedCount > 0;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: royalBlue.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: royalBlue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Ionicons.shield_checkmark_outline,
                                  color: royalBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Clear Requirements',
                                      style: TextStyle(
                                        color: royalBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Choose mandatory items to clear for this student.',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: royalBlue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$selectedCount / $totalCount selected',
                                  style: const TextStyle(
                                    color: royalBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    if (allSelected) {
                                      selectedKeys.clear();
                                    } else {
                                      selectedKeys
                                        ..clear()
                                        ..addAll(
                                          unclearedRequirements.map(
                                            _requirementKey,
                                          ),
                                        );
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: royalBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: Icon(
                                  allSelected
                                      ? Ionicons.remove_circle_outline
                                      : Ionicons.checkmark_done_outline,
                                  size: 16,
                                ),
                                label: Text(
                                  allSelected ? 'Unselect All' : 'Select All',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: unclearedRequirements.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final requirement =
                                    unclearedRequirements[index];
                                final key = _requirementKey(requirement);
                                final isSelected = selectedKeys.contains(key);

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setModalState(() {
                                        if (isSelected) {
                                          selectedKeys.remove(key);
                                        } else {
                                          selectedKeys.add(key);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 130,
                                      ),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? royalBlue.withOpacity(0.06)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? royalBlue
                                              : royalBlue.withOpacity(0.16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            activeColor: royalBlue,
                                            onChanged: (value) {
                                              setModalState(() {
                                                if (value == true) {
                                                  selectedKeys.add(key);
                                                } else {
                                                  selectedKeys.remove(key);
                                                }
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              requirement.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _requirementTypeColor(
                                                requirement,
                                              ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              _requirementTypeLabel(
                                                requirement,
                                              ),
                                              style: TextStyle(
                                                color: _requirementTypeColor(
                                                  requirement,
                                                ),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: royalBlue,
                                    side: BorderSide(
                                      color: royalBlue.withOpacity(0.24),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: hasSelection
                                      ? () {
                                          final selectedRequirements =
                                              unclearedRequirements
                                                  .where(
                                                    (requirement) =>
                                                        selectedKeys.contains(
                                                          _requirementKey(
                                                            requirement,
                                                          ),
                                                        ),
                                                  )
                                                  .toList(growable: false);

                                          Navigator.of(
                                            dialogContext,
                                          ).pop(selectedRequirements);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: royalBlue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: royalBlue
                                        .withOpacity(0.35),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    hasSelection
                                        ? 'Clear Selected ($selectedCount)'
                                        : 'Clear Selected',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _requirementKey(_ObligatoryActivity requirement) {
    return '${requirement.type}:${requirement.sourceId}';
  }

  String _requirementTypeLabel(_ObligatoryActivity requirement) {
    return requirement.type == _eventRequirementType ? 'Event' : 'Payment';
  }

  Color _requirementTypeColor(_ObligatoryActivity requirement) {
    return requirement.type == _eventRequirementType
        ? royalBlue
        : const Color(0xFF2E7D32);
  }

  Future<void> _markEventsAsAttended(
    String studentId,
    List<int> eventIds,
  ) async {
    if (eventIds.isEmpty) {
      return;
    }

    final client = Supabase.instance.client;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final existingRows = await client
        .from(_eventAttendanceTable)
        .select('event_id')
        .eq('student_id', studentId)
        .inFilter('event_id', eventIds);

    final existingEventIds = List<Map<String, dynamic>>.from(existingRows)
        .map((row) => _readInt(row['event_id']))
        .where((eventId) => eventId > 0)
        .toSet();

    final missingEventIds = eventIds
        .where((eventId) => !existingEventIds.contains(eventId))
        .toList(growable: false);

    for (final eventId in missingEventIds) {
      try {
        await client.from(_eventAttendanceTable).insert({
          'event_id': eventId,
          'student_id': studentId,
          'scanned_time_in': nowIso,
          'scanned_time_out': nowIso,
          'status': 'completed',
        });
      } catch (_) {
        // Ignore insert failures and continue with updates below.
      }
    }

    await client
        .from(_eventAttendanceTable)
        .update({
          'scanned_time_in': nowIso,
          'scanned_time_out': nowIso,
          'status': 'completed',
        })
        .eq('student_id', studentId)
        .inFilter('event_id', eventIds);
  }

  Future<void> _markPaymentsAsApproved(
    String studentId,
    List<int> requirementIds,
  ) async {
    if (requirementIds.isEmpty) {
      return;
    }

    final client = Supabase.instance.client;
    final seed = DateTime.now().millisecondsSinceEpoch;

    final existingRows = await client
        .from(_transactionsTable)
        .select('requirement_id')
        .eq('student_id', studentId)
        .inFilter('requirement_id', requirementIds);

    final existingRequirementIds = List<Map<String, dynamic>>.from(existingRows)
        .map((row) => _readInt(row['requirement_id']))
        .where((requirementId) => requirementId > 0)
        .toSet();

    final missingRequirementIds = requirementIds
        .where(
          (requirementId) => !existingRequirementIds.contains(requirementId),
        )
        .toList(growable: false);

    for (var index = 0; index < missingRequirementIds.length; index++) {
      final requirementId = missingRequirementIds[index];
      try {
        await client.from(_transactionsTable).insert({
          'student_id': studentId,
          'requirement_id': requirementId,
          'reference_number': 'ADMIN-CLEAR-$seed-$index',
          'proof_photo_url': 'admin-clearance',
          'status': 'approved',
        });
      } catch (_) {
        // Ignore insert failures and continue with updates below.
      }
    }

    await client
        .from(_transactionsTable)
        .update({'status': 'approved'})
        .eq('student_id', studentId)
        .inFilter('requirement_id', requirementIds);
  }

  Future<bool> _fetchActivityCardStampState({
    required String studentId,
    required int termId,
  }) async {
    final response = await Supabase.instance.client
        .from(_activityCardsTable)
        .select('is_stamp')
        .eq('student_id', studentId)
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

  Future<void> _stampActivityCardForTerm({
    required String studentId,
    required int termId,
    required bool isCleared,
  }) async {
    await Supabase.instance.client.from(_activityCardsTable).upsert({
      'student_id': studentId,
      'term_id': termId,
      'is_cleared': isCleared,
      'is_stamp': true,
    }, onConflict: 'student_id,term_id');
  }

  Future<List<(String, bool)>> _buildActivityItems(
    List<_ObligatoryActivity> requirements,
  ) async {
    if (requirements.isEmpty) {
      return const [];
    }

    final studentId = await _resolveCurrentStudentIdOrEmpty();
    if (studentId.isEmpty) {
      return requirements
          .map<(String, bool)>((item) => (item.label, false))
          .toList(growable: false);
    }

    final eventRequirementIds = requirements
        .where((item) => item.type == _eventRequirementType)
        .map((item) => item.sourceId)
        .toSet()
        .toList(growable: false);

    final paymentRequirementIds = requirements
        .where((item) => item.type == _paymentRequirementType)
        .map((item) => item.sourceId)
        .toSet()
        .toList(growable: false);

    Set<int> activeEventIds = const <int>{};
    Set<int> activePaymentIds = const <int>{};

    try {
      activeEventIds = await _fetchActiveEventIds(
        studentId,
        eventRequirementIds,
      );
    } catch (_) {
      activeEventIds = const <int>{};
    }

    try {
      activePaymentIds = await _fetchActivePaymentRequirementIds(
        studentId,
        paymentRequirementIds,
      );
    } catch (_) {
      activePaymentIds = const <int>{};
    }

    return requirements
        .map((item) {
          final active = item.type == _eventRequirementType
              ? activeEventIds.contains(item.sourceId)
              : activePaymentIds.contains(item.sourceId);
          return (item.label, active);
        })
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

  Future<Set<int>> _fetchActiveEventIds(
    String studentId,
    List<int> eventIds,
  ) async {
    if (eventIds.isEmpty) {
      return const <int>{};
    }

    final response = await Supabase.instance.client
        .from(_eventAttendanceTable)
        .select('event_id, scanned_time_in, scanned_time_out, status')
        .eq('student_id', studentId)
        .inFilter('event_id', eventIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final activeEventIds = <int>{};

    for (final row in rows) {
      final eventId = _readInt(row['event_id']);
      if (eventId <= 0) {
        continue;
      }

      final status = _readLabel(row['status']).toLowerCase();
      final hasTimeIn = _readLabel(row['scanned_time_in']).isNotEmpty;
      final hasTimeOut = _readLabel(row['scanned_time_out']).isNotEmpty;
      final isCompleted = status == 'completed' || (hasTimeIn && hasTimeOut);

      if (isCompleted) {
        activeEventIds.add(eventId);
      }
    }

    return activeEventIds;
  }

  Future<Set<int>> _fetchActivePaymentRequirementIds(
    String studentId,
    List<int> requirementIds,
  ) async {
    if (requirementIds.isEmpty) {
      return const <int>{};
    }

    final response = await Supabase.instance.client
        .from(_transactionsTable)
        .select('requirement_id, status')
        .eq('student_id', studentId)
        .inFilter('requirement_id', requirementIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final activeRequirementIds = <int>{};

    for (final row in rows) {
      final requirementId = _readInt(row['requirement_id']);
      if (requirementId <= 0) {
        continue;
      }

      final status = _readLabel(row['status']).toLowerCase();
      final isRejected = status == 'rejected' || status == 'declined';
      if (!isRejected) {
        activeRequirementIds.add(requirementId);
      }
    }

    return activeRequirementIds;
  }

  Future<String> _resolveCurrentStudentIdOrEmpty() async {
    final targetStudentId = _firstNonEmpty([_studentId, widget.studentId]);
    if (targetStudentId.isNotEmpty) {
      return targetStudentId;
    }

    final email = _normalizedTargetEmail();
    if (email.isEmpty) {
      return '';
    }

    try {
      final student = await Supabase.instance.client
          .from(_studentsTable)
          .select('student_id')
          .ilike('email', email)
          .maybeSingle();
      return _readLabel(student?['student_id']);
    } catch (_) {
      return '';
    }
  }

  Future<int> _resolveCurrentAdminIdOrZero() async {
    final user = SupabaseAuthService.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};

    final metadataAdminId = _readInt(metadata['admin_id']);
    if (metadataAdminId > 0) {
      return metadataAdminId;
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

  String _readLabel(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  Widget _buildStudentAvatarImage() {
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

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _isAdminActivityCardStamped
            ? FloatingActionButton(
                onPressed: _isApplyingClearance || _isStampingCard
                    ? null
                    : _onStampCardPressed,
                tooltip: _isStampingCard
                    ? 'Stamping activity card...'
                    : _isStampedByAdmin
                    ? 'Card already stamped'
                    : 'Stamp activity card',
                backgroundColor: _isStampedByAdmin ? royalBlue : gold,
                foregroundColor: _isStampedByAdmin ? gold : royalBlue,
                child: _isStampingCard
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isStampedByAdmin
                            ? Ionicons.ribbon
                            : Ionicons.ribbon_outline,
                      ),
              )
            : null,
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
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _isApplyingClearance
                    ? null
                    : _clearStudentRequirements,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Clear student requirements',
                icon: _isApplyingClearance
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Ionicons.checkmark_done_circle_outline,
                        color: royalBlue,
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
                        child: _buildStudentAvatarImage(),
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
                            _studentName,
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
                            _studentProgram,
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
                            _studentId,
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
                          'ACES',
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
                          'ACES',
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
                    'ACES',
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
                    'ACES',
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
                    'ACES',
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
                    'ACES',
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
