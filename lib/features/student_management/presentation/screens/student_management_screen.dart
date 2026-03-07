import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/academic_term_service.dart';
import '../../data/supabase_student_management_impl.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../domain/student_directory_query.dart';
import '../../domain/student_entity.dart';
import '../../domain/student_management_repository.dart';
import 'student_profile_screen.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StudentManagementRepository _studentRepository =
      SupabaseStudentManagementImpl.instance;
  static const String _allProgramsLabel = 'All';
  static const String _clearedTabLabel = 'Cleared';

  static const String _adminsTable = 'admins';
  static const String _eventsTable = 'events';
  static const String _paymentRequirementsTable = 'payment_requirements';
  static const String _eventAttendanceTable = 'event_attendance';
  static const String _transactionsTable = 'student_transactions';
  static const String _activityCardsTable = 'activity_cards';
  static const String _adminActivityCardsTable = 'admin_activity_cards';

  String _selectedTab = 'All';
  String _selectedProgram = _allProgramsLabel;

  List<StudentEntity> _allStudents = const <StudentEntity>[];
  bool _isLoadingStudents = true;
  String? _studentsLoadError;
  bool _isSelectionMode = false;
  bool _isBulkActionRunning = false;
  bool _isAdminActivityCardStamped = false;
  bool _isLoadingAcademicTerms = true;
  final Set<String> _selectedStudentIds = <String>{};
  Set<String> _clearedStudentIds = <String>{};
  List<AcademicTermOption> _academicTerms = const <AcademicTermOption>[];
  AcademicTermOption? _activeAcademicTerm;

  static const List<String> _semesterOptions = <String>[
    '1st Semester',
    '2nd Semester',
    'Summer',
  ];

  List<String> get _facetPrograms {
    final programs =
        _allStudents
            .map((student) => student.program.trim())
            .where((program) => program.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return programs;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _loadStudents();
    _loadAcademicTerms();
  }

  Future<void> _loadAcademicTerms() async {
    final previousActiveTermId = _activeAcademicTerm?.id ?? 0;
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

    if (activeTerm == null && terms.isNotEmpty) {
      activeTerm = terms.first;
    }

    if (!mounted) {
      return;
    }

    final nextActiveTermId = activeTerm?.id ?? 0;
    final didChangeActiveTerm = previousActiveTermId != nextActiveTermId;

    setState(() {
      _academicTerms = terms;
      _activeAcademicTerm = activeTerm;
      _isLoadingAcademicTerms = false;

      if (didChangeActiveTerm) {
        _clearedStudentIds = <String>{};
        _isAdminActivityCardStamped = false;
        _selectedStudentIds.clear();
        _isSelectionMode = false;
      }
    });

    await _refreshClearanceAndAdminStampState();
  }

  Future<void> _loadStudents() async {
    if (mounted) {
      setState(() {
        _isLoadingStudents = true;
        _studentsLoadError = null;
      });
    }

    try {
      final students = await _studentRepository.fetchStudents();

      if (!mounted) {
        return;
      }

      final availablePrograms = students
          .map((student) => student.program.trim())
          .where((program) => program.isNotEmpty)
          .toSet();
      final availableStudentIds = students
          .map((student) => student.studentId.trim())
          .where((studentId) => studentId.isNotEmpty)
          .toSet();

      setState(() {
        _allStudents = students;
        _isLoadingStudents = false;
        _studentsLoadError = null;
        _selectedStudentIds.removeWhere(
          (studentId) => !availableStudentIds.contains(studentId),
        );

        if (_selectedProgram != _allProgramsLabel &&
            !availablePrograms.contains(_selectedProgram)) {
          _selectedProgram = _allProgramsLabel;
        }
      });

      await _refreshClearanceAndAdminStampState();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingStudents = false;
        _studentsLoadError =
            'Unable to load students from server. Pull down to retry.';
      });
    }
  }

  bool _allVisibleStudentsSelected(List<StudentEntity> students) {
    final visibleStudentIds = students
        .map((student) => student.studentId.trim())
        .where((studentId) => studentId.isNotEmpty)
        .toSet();

    if (visibleStudentIds.isEmpty) {
      return false;
    }

    return visibleStudentIds.difference(_selectedStudentIds).isEmpty;
  }

  void _startSelectionMode() {
    if (_isLoadingStudents || _allStudents.isEmpty) {
      return;
    }

    setState(() {
      _isSelectionMode = true;
      _selectedStudentIds.clear();
    });
  }

  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedStudentIds.clear();
    });
  }

  void _toggleSelectAllVisible(List<StudentEntity> students) {
    final visibleStudentIds = students
        .map((student) => student.studentId.trim())
        .where((studentId) => studentId.isNotEmpty)
        .toSet();

    if (visibleStudentIds.isEmpty) {
      return;
    }

    setState(() {
      final areAllVisibleSelected = visibleStudentIds
          .difference(_selectedStudentIds)
          .isEmpty;

      if (areAllVisibleSelected) {
        _selectedStudentIds.removeAll(visibleStudentIds);
      } else {
        _selectedStudentIds.addAll(visibleStudentIds);
      }
    });
  }

  void _toggleStudentSelection(String studentId) {
    final normalizedStudentId = studentId.trim();
    if (normalizedStudentId.isEmpty) {
      return;
    }

    setState(() {
      if (_selectedStudentIds.contains(normalizedStudentId)) {
        _selectedStudentIds.remove(normalizedStudentId);
      } else {
        _selectedStudentIds.add(normalizedStudentId);
      }
    });
  }

  Future<void> _freezeSelectedStudents() async {
    await _runBulkAction(
      action: _studentRepository.freezeStudents,
      successMessage: 'Selected students were frozen.',
      failureMessage: 'Unable to freeze selected students.',
    );
  }

  Future<void> _stampSelectedStudents() async {
    if (_selectedStudentIds.isEmpty || _isBulkActionRunning) {
      return;
    }

    if (!_isAdminActivityCardStamped) {
      _showErrorMessage(
        'Stamp action is locked until admin activity card is stamped.',
      );
      return;
    }

    final termId = _activeAcademicTerm?.id ?? 0;
    if (termId <= 0) {
      _showErrorMessage('No active academic term selected.');
      return;
    }

    final selectedIds = _normalizeStudentIds(_selectedStudentIds.toList());
    final stampableStudentIds = selectedIds
        .where((studentId) => _clearedStudentIds.contains(studentId))
        .toList(growable: false);

    if (stampableStudentIds.isEmpty) {
      _showErrorMessage('Only cleared students can be stamped.');
      return;
    }

    final skippedCount = selectedIds.length - stampableStudentIds.length;
    final successMessage = skippedCount > 0
        ? 'Stamped ${stampableStudentIds.length} cleared student(s). '
              '$skippedCount selected student(s) are not cleared.'
        : 'Selected students were stamped.';

    await _runBulkAction(
      action: (studentIds) => _stampStudentsForTerm(studentIds, termId),
      successMessage: successMessage,
      failureMessage: 'Unable to stamp selected students.',
      studentIdsOverride: stampableStudentIds,
    );
  }

  Future<void> _deleteSelectedStudents() async {
    if (_selectedStudentIds.isEmpty || _isBulkActionRunning) {
      return;
    }

    final shouldDelete = await _confirmDeleteSelectedStudents();
    if (shouldDelete != true) {
      return;
    }

    await _runBulkAction(
      action: _studentRepository.deleteStudents,
      successMessage: 'Selected students were deleted.',
      failureMessage: 'Unable to delete selected students.',
    );
  }

  Future<bool?> _confirmDeleteSelectedStudents() {
    final selectedCount = _selectedStudentIds.length;
    final selectedLabel = selectedCount == 1 ? 'student' : 'students';

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Ionicons.warning_outline,
                  color: Color(0xFFC62828),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete Selected',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Delete $selectedCount $selectedLabel? This action cannot be undone.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.68),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF003DA5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runBulkAction({
    required Future<void> Function(List<String> studentIds) action,
    required String successMessage,
    required String failureMessage,
    List<String>? studentIdsOverride,
  }) async {
    if (_isBulkActionRunning) {
      return;
    }

    final selectedStudentIds = _normalizeStudentIds(
      studentIdsOverride ?? _selectedStudentIds.toList(),
    );
    if (selectedStudentIds.isEmpty) {
      return;
    }

    setState(() {
      _isBulkActionRunning = true;
    });

    try {
      await action(selectedStudentIds);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedStudentIds.clear();
        _isSelectionMode = false;
      });

      await _loadStudents();
      await _refreshClearanceAndAdminStampState();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isBulkActionRunning = false;
        });
      }
    }
  }

  List<StudentEntity> get _filteredStudents {
    final tabForStatusFilter = _selectedTab == _clearedTabLabel
        ? 'All'
        : _selectedTab;

    final students = StudentDirectoryQuery.filterStudents(
      students: _allStudents,
      query: _searchController.text,
      selectedStatus: tabForStatusFilter,
      selectedProgram: _selectedProgram,
      allProgramsLabel: _allProgramsLabel,
    );

    if (_selectedTab != _clearedTabLabel) {
      return students;
    }

    return students
        .where((student) => _clearedStudentIds.contains(student.studentId))
        .toList(growable: false);
  }

  Future<void> _stampStudentsForTerm(
    List<String> studentIds,
    int termId,
  ) async {
    if (termId <= 0) {
      return;
    }

    final normalizedStudentIds = _normalizeStudentIds(studentIds);
    if (normalizedStudentIds.isEmpty) {
      return;
    }

    final rows = normalizedStudentIds
        .map(
          (studentId) => {
            'student_id': studentId,
            'term_id': termId,
            'is_cleared': true,
            'is_stamp': true,
          },
        )
        .toList(growable: false);

    await Supabase.instance.client
        .from(_activityCardsTable)
        .upsert(rows, onConflict: 'student_id,term_id');
  }

  List<String> _normalizeStudentIds(List<String> studentIds) {
    return studentIds
        .map((studentId) => studentId.trim())
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<void> _refreshClearanceAndAdminStampState() async {
    final termId = _activeAcademicTerm?.id ?? 0;
    if (termId <= 0) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAdminActivityCardStamped = false;
        _clearedStudentIds = <String>{};
      });
      return;
    }

    final candidateStudentIds = _allStudents
        .map((student) => student.studentId.trim())
        .where((studentId) => studentId.isNotEmpty)
        .toSet();

    var adminStamped = false;
    var clearedStudentIds = <String>{};

    try {
      final adminId = await _resolveCurrentAdminIdOrZero();
      if (adminId > 0) {
        adminStamped = await _fetchAdminActivityCardStampState(
          adminId: adminId,
          termId: termId,
        );
      }
    } catch (_) {
      adminStamped = false;
    }

    try {
      clearedStudentIds = await _fetchClearedStudentIdsForTerm(
        termId: termId,
        candidateStudentIds: candidateStudentIds,
      );
    } catch (_) {
      clearedStudentIds = <String>{};
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isAdminActivityCardStamped = adminStamped;
      _clearedStudentIds = clearedStudentIds;
    });
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

    return stampValue?.toString().toLowerCase() == 'true';
  }

  Future<Set<String>> _fetchClearedStudentIdsForTerm({
    required int termId,
    required Set<String> candidateStudentIds,
  }) async {
    if (candidateStudentIds.isEmpty) {
      return <String>{};
    }

    final client = Supabase.instance.client;

    final eventRows = await client
        .from(_eventsTable)
        .select('id')
        .eq('term_id', termId)
        .eq('is_mandatory', true);

    final paymentRows = await client
        .from(_paymentRequirementsTable)
        .select('id')
        .eq('term_id', termId)
        .eq('is_mandatory', true);

    final mandatoryEventIds = List<Map<String, dynamic>>.from(
      eventRows,
    ).map((row) => _readInt(row['id'])).where((id) => id > 0).toSet();

    final mandatoryPaymentIds = List<Map<String, dynamic>>.from(
      paymentRows,
    ).map((row) => _readInt(row['id'])).where((id) => id > 0).toSet();

    if (mandatoryEventIds.isEmpty && mandatoryPaymentIds.isEmpty) {
      return <String>{};
    }

    final normalizedStudentIds = candidateStudentIds.toList(growable: false);

    final completedEventsByStudent = await _fetchCompletedEventsByStudent(
      eventIds: mandatoryEventIds.toList(growable: false),
      studentIds: normalizedStudentIds,
    );
    final clearedPaymentsByStudent = await _fetchClearedPaymentsByStudent(
      requirementIds: mandatoryPaymentIds.toList(growable: false),
      studentIds: normalizedStudentIds,
    );

    final clearedStudentIds = <String>{};
    for (final studentId in normalizedStudentIds) {
      final completedEventIds =
          completedEventsByStudent[studentId] ?? const <int>{};
      final clearedPaymentIds =
          clearedPaymentsByStudent[studentId] ?? const <int>{};

      final eventsCleared = mandatoryEventIds.every(completedEventIds.contains);
      final paymentsCleared = mandatoryPaymentIds.every(
        clearedPaymentIds.contains,
      );

      if (eventsCleared && paymentsCleared) {
        clearedStudentIds.add(studentId);
      }
    }

    return clearedStudentIds;
  }

  Future<Map<String, Set<int>>> _fetchCompletedEventsByStudent({
    required List<int> eventIds,
    required List<String> studentIds,
  }) async {
    if (eventIds.isEmpty || studentIds.isEmpty) {
      return const <String, Set<int>>{};
    }

    final response = await Supabase.instance.client
        .from(_eventAttendanceTable)
        .select(
          'student_id, event_id, scanned_time_in, scanned_time_out, status',
        )
        .inFilter('event_id', eventIds)
        .inFilter('student_id', studentIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final completedEventsByStudent = <String, Set<int>>{};

    for (final row in rows) {
      final studentId = row['student_id']?.toString().trim() ?? '';
      final eventId = _readInt(row['event_id']);
      if (studentId.isEmpty || eventId <= 0) {
        continue;
      }

      final status = row['status']?.toString().trim().toLowerCase() ?? '';
      final hasTimeIn =
          (row['scanned_time_in']?.toString().trim().isNotEmpty ?? false);
      final hasTimeOut =
          (row['scanned_time_out']?.toString().trim().isNotEmpty ?? false);
      final isCompleted = status == 'completed' || (hasTimeIn && hasTimeOut);

      if (!isCompleted) {
        continue;
      }

      completedEventsByStudent
          .putIfAbsent(studentId, () => <int>{})
          .add(eventId);
    }

    return completedEventsByStudent;
  }

  Future<Map<String, Set<int>>> _fetchClearedPaymentsByStudent({
    required List<int> requirementIds,
    required List<String> studentIds,
  }) async {
    if (requirementIds.isEmpty || studentIds.isEmpty) {
      return const <String, Set<int>>{};
    }

    final response = await Supabase.instance.client
        .from(_transactionsTable)
        .select('student_id, requirement_id, status')
        .inFilter('requirement_id', requirementIds)
        .inFilter('student_id', studentIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final clearedPaymentsByStudent = <String, Set<int>>{};

    for (final row in rows) {
      final studentId = row['student_id']?.toString().trim() ?? '';
      final requirementId = _readInt(row['requirement_id']);
      if (studentId.isEmpty || requirementId <= 0) {
        continue;
      }

      final status = row['status']?.toString().trim().toLowerCase() ?? '';
      final isRejected = status == 'rejected' || status == 'declined';
      if (isRejected) {
        continue;
      }

      clearedPaymentsByStudent
          .putIfAbsent(studentId, () => <int>{})
          .add(requirementId);
    }

    return clearedPaymentsByStudent;
  }

  Future<int> _resolveCurrentAdminIdOrZero() async {
    final user = SupabaseAuthService.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final metadataAdminId = _readInt(metadata['admin_id']);
    if (metadataAdminId > 0) {
      return metadataAdminId;
    }

    final email = user?.email?.trim().toLowerCase() ?? '';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshScreen() async {
    await Future.wait<void>([_loadStudents(), _loadAcademicTerms()]);
  }

  Future<void> _openAcademicTermActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      builder: (sheetContext) {
        final activeLabel = _activeAcademicTerm?.label ?? 'No active term set';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Academic Term',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Active: $activeLabel',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                _buildAcademicActionTile(
                  icon: Ionicons.add_circle_outline,
                  title: 'Add New Term',
                  subtitle: 'Create a new academic year and semester',
                  onTap: () => Navigator.of(sheetContext).pop('add'),
                ),
                const SizedBox(height: 10),
                _buildAcademicActionTile(
                  icon: Ionicons.checkmark_circle_outline,
                  title: 'Set Active Term',
                  subtitle: _academicTerms.isEmpty
                      ? 'Add a term first'
                      : 'Switch the current active term',
                  enabled: _academicTerms.isNotEmpty,
                  onTap: _academicTerms.isEmpty
                      ? null
                      : () => Navigator.of(sheetContext).pop('set-active'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    bool changed = false;
    if (action == 'add') {
      changed = await _showAddAcademicTermDialog();
      if (changed && mounted) {
        _showInfoMessage('Academic term saved.');
      }
    }

    if (action == 'set-active') {
      changed = await _showSetActiveAcademicTermDialog();
      if (changed && mounted) {
        _showInfoMessage('Active academic term updated.');
      }
    }

    if (changed) {
      _loadAcademicTerms();
    }
  }

  Future<bool> _showAddAcademicTermDialog() async {
    final yearController = TextEditingController(
      text: _suggestedAcademicYear(),
    );
    String selectedSemester = _suggestedSemester();
    bool setAsActive = true;
    bool isSaving = false;
    String? yearErrorText;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Add Academic Term',
                        style: TextStyle(
                          color: Color(0xFF003DA5),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create a term and optionally set it as active.',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (yearErrorText == null) {
                            return;
                          }
                          setSheetState(() {
                            yearErrorText = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Academic Year',
                          hintText: '2026-2027',
                          errorText: yearErrorText,
                          filled: true,
                          fillColor: const Color(0xFF003DA5).withOpacity(0.03),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF003DA5).withOpacity(0.16),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Color(0xFF003DA5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Semester',
                        style: TextStyle(
                          color: Color(0xFF003DA5),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _semesterOptions
                            .map(
                              (semester) => _buildSemesterChoiceChip(
                                label: semester,
                                isSelected: selectedSemester == semester,
                                onTap: isSaving
                                    ? null
                                    : () {
                                        setSheetState(() {
                                          selectedSemester = semester;
                                        });
                                      },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF003DA5).withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                        ),
                        child: SwitchListTile(
                          value: setAsActive,
                          activeColor: const Color(0xFF003DA5),
                          title: const Text(
                            'Set as active term',
                            style: TextStyle(
                              color: Color(0xFF003DA5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'This term will be used as the current default',
                            style: TextStyle(fontSize: 11),
                          ),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setSheetState(() {
                                    setAsActive = value;
                                  });
                                },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF003DA5),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF003DA5,
                                  ).withOpacity(0.18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final academicYear = yearController.text
                                          .trim();
                                      if (!_isValidAcademicYear(academicYear)) {
                                        setSheetState(() {
                                          yearErrorText =
                                              'Use YYYY-YYYY format (ex: 2026-2027).';
                                        });
                                        return;
                                      }

                                      setSheetState(() {
                                        isSaving = true;
                                        yearErrorText = null;
                                      });

                                      try {
                                        await AcademicTermService.createTerm(
                                          academicYear: academicYear,
                                          semester: selectedSemester,
                                          setActive: setAsActive,
                                        );

                                        if (sheetContext.mounted) {
                                          Navigator.of(sheetContext).pop(true);
                                        }
                                      } catch (error) {
                                        setSheetState(() {
                                          isSaving = false;
                                        });
                                        _showErrorMessage(
                                          _academicTermErrorMessage(error),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF003DA5),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF003DA5,
                                ).withOpacity(0.35),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isSaving ? 'Saving...' : 'Save Term',
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
              ),
            );
          },
        );
      },
    );

    yearController.dispose();
    return result == true;
  }

  Future<bool> _showSetActiveAcademicTermDialog() async {
    if (_academicTerms.isEmpty) {
      _showErrorMessage('No academic terms available yet.');
      return false;
    }

    int selectedTermId = (_activeAcademicTerm ?? _academicTerms.first).id;
    bool isSaving = false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            final isSameAsActive = _activeAcademicTerm?.id == selectedTermId;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Set Active Term',
                      style: TextStyle(
                        color: Color(0xFF003DA5),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select which term should be active for admin operations.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(sheetContext).size.height * 0.46,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _academicTerms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final term = _academicTerms[index];
                          final isSelected = selectedTermId == term.id;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: isSaving
                                  ? null
                                  : () {
                                      setSheetState(() {
                                        selectedTermId = term.id;
                                      });
                                    },
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF003DA5,
                                        ).withOpacity(0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF003DA5)
                                        : const Color(
                                            0xFF003DA5,
                                          ).withOpacity(0.14),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            term.semester,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF003DA5)
                                                  : Colors.black87,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'A.Y. ${term.academicYear}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (term.isActive)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF003DA5,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: Color(0xFF003DA5),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    Icon(
                                      isSelected
                                          ? Ionicons.radio_button_on
                                          : Ionicons.radio_button_off,
                                      color: isSelected
                                          ? const Color(0xFF003DA5)
                                          : Colors.black38,
                                      size: 18,
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
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(sheetContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF003DA5),
                              side: BorderSide(
                                color: const Color(
                                  0xFF003DA5,
                                ).withOpacity(0.18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving || isSameAsActive
                                ? null
                                : () async {
                                    setSheetState(() {
                                      isSaving = true;
                                    });

                                    try {
                                      await AcademicTermService.setActiveTerm(
                                        termId: selectedTermId,
                                      );

                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop(true);
                                      }
                                    } catch (error) {
                                      setSheetState(() {
                                        isSaving = false;
                                      });
                                      _showErrorMessage(
                                        _academicTermErrorMessage(error),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF003DA5),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF003DA5,
                              ).withOpacity(0.35),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isSaving
                                  ? 'Saving...'
                                  : isSameAsActive
                                  ? 'Already Active'
                                  : 'Set Active',
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
            );
          },
        );
      },
    );

    return result == true;
  }

  bool _isValidAcademicYear(String value) {
    if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value)) {
      return false;
    }

    final parts = value.split('-');
    if (parts.length != 2) {
      return false;
    }

    final startYear = int.tryParse(parts[0]);
    final endYear = int.tryParse(parts[1]);
    if (startYear == null || endYear == null) {
      return false;
    }

    return endYear == startYear + 1;
  }

  String _suggestedAcademicYear() {
    final activeYear = _activeAcademicTerm?.academicYear ?? '';
    if (_isValidAcademicYear(activeYear)) {
      final years = activeYear.split('-');
      final startYear = int.tryParse(years.first) ?? DateTime.now().year;
      final endYear = int.tryParse(years.last) ?? (startYear + 1);
      return '${startYear + 1}-${endYear + 1}';
    }

    final now = DateTime.now();
    final startYear = now.month >= 6 ? now.year : now.year - 1;
    return '$startYear-${startYear + 1}';
  }

  String _suggestedSemester() {
    final currentSemester = _activeAcademicTerm?.semester.trim();
    if (currentSemester == '1st Semester') {
      return '2nd Semester';
    }
    if (currentSemester == '2nd Semester') {
      return 'Summer';
    }
    return _semesterOptions.first;
  }

  Widget _buildSemesterChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF003DA5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF003DA5)
                  : const Color(0xFF003DA5).withOpacity(0.18),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF003DA5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF003DA5).withOpacity(0.03)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF003DA5).withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFF003DA5).withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 18,
                  color: enabled ? const Color(0xFF003DA5) : Colors.black38,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled
                            ? const Color(0xFF003DA5)
                            : Colors.black38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: enabled ? Colors.black54 : Colors.black38,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                size: 16,
                color: enabled ? const Color(0xFF003DA5) : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _academicTermErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'This academic year and semester already exists.';
      }
      return error.message;
    }

    return 'Unable to save academic term. Please try again.';
  }

  void _showInfoMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showProgramPicker() async {
    final selectedProgram = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [_allProgramsLabel, ..._facetPrograms];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Filter by Program',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a FACET program',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final program = options[index];
                      final isSelected = _selectedProgram == program;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(program),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF003DA5).withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF003DA5)
                                    : const Color(0xFF003DA5).withOpacity(0.14),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    program,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF003DA5)
                                          : Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Ionicons.checkmark_circle,
                                    color: Color(0xFF003DA5),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
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

    if (selectedProgram == null || selectedProgram == _selectedProgram) {
      return;
    }

    setState(() => _selectedProgram = selectedProgram);
  }

  Widget _buildProgramDropdownChip() {
    final isDefault = _selectedProgram == _allProgramsLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _showProgramPicker,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDefault ? Colors.white : const Color(0xFF003DA5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDefault
                  ? const Color(0xFF003DA5).withOpacity(0.18)
                  : const Color(0xFF003DA5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  _selectedProgram,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDefault ? const Color(0xFF003DA5) : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Ionicons.chevron_down,
                color: isDefault ? const Color(0xFF003DA5) : Colors.white,
                size: 14,
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
    final filteredStudents = _filteredStudents;

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
              bottom: 260,
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
            RefreshIndicator(
              onRefresh: _refreshScreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionHeader(
                      title: 'Academic Term',
                      subtitle: _isLoadingAcademicTerms
                          ? 'Loading current academic term...'
                          : _activeAcademicTerm == null
                          ? 'Set your active academic term first'
                          : 'Active term: ${_activeAcademicTerm!.label}',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF003DA5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Ionicons.calendar_outline,
                                color: Color(0xFF003DA5),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isLoadingAcademicTerms
                                    ? 'Loading...'
                                    : (_activeAcademicTerm?.label ??
                                          'No active term set'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildHeaderActionButton(
                              label: 'Manage',
                              icon: Ionicons.settings_outline,
                              onTap: _isLoadingAcademicTerms
                                  ? null
                                  : _openAcademicTermActions,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      title: 'Search & Filter',
                      subtitle: 'Find students by name, ID, or program',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 58),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(
                              Ionicons.search,
                              color: Color(0xFF003DA5),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search students',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                onPressed: () => _searchController.clear(),
                                icon: const Icon(
                                  Ionicons.close_circle,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                splashRadius: 20,
                                visualDensity: VisualDensity.compact,
                              )
                            else
                              const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildProgramDropdownChip(),
                            ),
                            ...[
                              'All',
                              'Active',
                              'Frozen',
                              _clearedTabLabel,
                            ].map((tab) {
                              final isSelected = _selectedTab == tab;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        setState(() => _selectedTab = tab),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 140,
                                      ),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF003DA5)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF003DA5)
                                              : const Color(
                                                  0xFF003DA5,
                                                ).withOpacity(0.18),
                                        ),
                                      ),
                                      child: Text(
                                        tab,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF003DA5),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStudentListHeader(filteredStudents),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildStudentListPanel(filteredStudents),
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

  Widget _buildStudentListHeader(List<StudentEntity> filteredStudents) {
    final statusLabel = _selectedTab == 'All' ? 'all statuses' : _selectedTab;
    final subtitle =
        '${filteredStudents.length} result(s) in $statusLabel • ${_selectedProgram == _allProgramsLabel ? 'all programs' : _selectedProgram}';
    final allVisibleSelected = _allVisibleStudentsSelected(filteredStudents);
    final hasSelectedStudents = _selectedStudentIds.isNotEmpty;
    final isFrozenTab = _selectedTab == 'Frozen';
    final isClearedTab = _selectedTab == _clearedTabLabel;
    final usesStampAction = isFrozenTab || isClearedTab;
    final isStampLocked = usesStampAction && !_isAdminActivityCardStamped;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Student List',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_isSelectionMode)
                _buildHeaderActionButton(
                  label: 'Select Student',
                  icon: Ionicons.checkmark_done_outline,
                  onTap: _isLoadingStudents ? null : _startSelectionMode,
                )
              else
                _buildHeaderActionButton(
                  label: 'Cancel',
                  icon: Ionicons.close_outline,
                  onTap: _isBulkActionRunning ? null : _cancelSelectionMode,
                ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_isSelectionMode) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003DA5).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedStudentIds.length} selected',
                    style: const TextStyle(
                      color: Color(0xFF003DA5),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_isSelectionMode) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF003DA5).withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF003DA5).withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isBulkActionRunning
                        ? 'Applying changes to selected students...'
                        : isStampLocked
                        ? 'Stamp action is locked until admin activity card is stamped.'
                        : 'Choose students, then select an action.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectionChoiceButton(
                          label: allVisibleSelected
                              ? 'Unselect All'
                              : 'Select All',
                          icon: allVisibleSelected
                              ? Ionicons.remove_circle_outline
                              : Ionicons.checkmark_circle_outline,
                          onPressed:
                              filteredStudents.isEmpty || _isBulkActionRunning
                              ? null
                              : () => _toggleSelectAllVisible(filteredStudents),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSelectionChoiceButton(
                          label: 'Cancel Selection',
                          icon: Ionicons.close_circle_outline,
                          onPressed: _isBulkActionRunning
                              ? null
                              : _cancelSelectionMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBulkChoiceButton(
                          label: usesStampAction
                              ? 'Stamp Selected'
                              : 'Freeze Selected',
                          icon: usesStampAction
                              ? Ionicons.ribbon_outline
                              : Ionicons.snow_outline,
                          onPressed:
                              hasSelectedStudents &&
                                  !_isBulkActionRunning &&
                                  (!usesStampAction ||
                                      _isAdminActivityCardStamped)
                              ? (usesStampAction
                                    ? _stampSelectedStudents
                                    : _freezeSelectedStudents)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBulkChoiceButton(
                          label: 'Delete Selected',
                          icon: Ionicons.trash_outline,
                          onPressed:
                              hasSelectedStudents && !_isBulkActionRunning
                              ? _deleteSelectedStudents
                              : null,
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.black.withOpacity(0.04)
                : const Color(0xFF003DA5).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDisabled
                  ? Colors.black.withOpacity(0.08)
                  : const Color(0xFF003DA5).withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isDisabled ? Colors.black38 : const Color(0xFF003DA5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDisabled ? Colors.black38 : const Color(0xFF003DA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionChoiceButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF003DA5),
        side: BorderSide(color: const Color(0xFF003DA5).withOpacity(0.18)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBulkChoiceButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final baseColor = isDestructive
        ? const Color(0xFFC62828)
        : const Color(0xFF003DA5);

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: baseColor.withOpacity(0.35),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStudentListPanel(List<StudentEntity> students) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoadingStudents
          ? _buildLoadingState()
          : _studentsLoadError != null
          ? _buildLoadErrorState()
          : students.isEmpty
          ? _buildEmptyState(isEmbedded: true)
          : Column(
              children: List.generate(
                students.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == students.length - 1 ? 0 : 12,
                  ),
                  child: _buildStudentCard(
                    students[index],
                    isSelected: _selectedStudentIds.contains(
                      students[index].studentId,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _buildLoadErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Ionicons.alert_circle_outline,
            color: const Color(0xFF003DA5).withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            _studentsLoadError ?? 'Unable to load students.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _loadStudents, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isEmbedded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEmbedded
            ? const Color(0xFF003DA5).withOpacity(0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Ionicons.people_outline,
            color: const Color(0xFF003DA5).withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            'No students found',
            style: TextStyle(
              color: Color(0xFF003DA5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different search term or filter',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentEntity student, {required bool isSelected}) {
    final statusColor = _getStatusColor(student.status);
    final isViewOnlyStudent =
        student.status == 'Active' || student.status == 'Frozen';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _isSelectionMode
            ? () => _toggleStudentSelection(student.studentId)
            : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isSelectionMode && isSelected
                ? const Color(0xFF003DA5).withOpacity(0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isSelectionMode && isSelected
                  ? const Color(0xFF003DA5)
                  : const Color(0xFF003DA5).withOpacity(0.1),
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF003DA5).withOpacity(0.12),
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        color: Color(0xFF003DA5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: Color(0xFF003DA5),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          student.program,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          student.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_isSelectionMode) ...[
                        const SizedBox(height: 6),
                        Icon(
                          isSelected
                              ? Ionicons.checkmark_circle
                              : Ionicons.ellipse_outline,
                          color: isSelected
                              ? const Color(0xFF003DA5)
                              : Colors.black38,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStudentMetaChip(
                    icon: Ionicons.card_outline,
                    text: 'ID: ${student.studentId}',
                  ),
                  _buildStudentMetaChip(
                    icon: Ionicons.mail_outline,
                    text: student.email,
                  ),
                ],
              ),
              if (!_isSelectionMode) ...[
                const SizedBox(height: 12),
                if (isViewOnlyStudent)
                  SizedBox(
                    width: double.infinity,
                    child: _buildViewButton(student),
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildViewButton(student)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildManageButton(student)),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(StudentEntity student) {
    return OutlinedButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StudentProfileAdminScreen(
              studentName: student.name,
              studentId: student.studentId,
              email: student.email,
              program: student.program,
              avatarPath: student.avatarUrl,
              studentStatus: student.status,
            ),
          ),
        );

        if (!mounted) {
          return;
        }

        await _loadStudents();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: const Color(0xFF003DA5).withOpacity(0.24)),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: const Color(0xFF003DA5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.eye_outline, size: 16),
          SizedBox(width: 6),
          Text('View', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildManageButton(StudentEntity student) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manage ${student.name} tapped')),
        );
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF003DA5),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.settings_outline, size: 16),
          SizedBox(width: 6),
          Text(
            'Manage',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF003DA5)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF4CAF50);
      case 'Pending':
        return const Color(0xFFFFC107);
      case 'Frozen':
        return const Color(0xFF455A64);
      default:
        return const Color(0xFF003DA5);
    }
  }
}
