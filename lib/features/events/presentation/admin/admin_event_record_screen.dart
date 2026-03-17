import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../auth/domain/faculty_catalog.dart';
import '../../data/event_attendance_query_service.dart';
import '../../domain/event_attendance.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color lightGray = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF666666);

class EventRecordScreen extends StatefulWidget {
  final int? eventId;
  final String eventName;
  final String eventDate;
  final String? eventDateRaw;
  final bool? isEventDone;
  final String eventLocation;
  final String eventTimeIn;
  final String eventTimeOut;
  final String eventImage;
  final bool isObligatory;
  final List<StudentAttendance>? students;

  const EventRecordScreen({
    super.key,
    this.eventId,
    this.eventName = 'General Assembly 2023',
    this.eventDate = 'Oct 24, 2023',
    this.eventDateRaw,
    this.isEventDone,
    this.eventLocation = 'University Gymnasium',
    this.eventTimeIn = '-',
    this.eventTimeOut = '-',
    this.eventImage = 'assets/images/event-siglakas.jpg',
    this.isObligatory = false,
    this.students,
  });

  @override
  State<EventRecordScreen> createState() => _EventRecordScreenState();
}

class _EventRecordScreenState extends State<EventRecordScreen> {
  static const String _allFilter = 'ALL';
  static const String _allProgramsFilter = 'All Programs';
  static const String _facetFacultyKey =
      'Faculty of Criminal Justice Education (FCJE)';
  static const List<String> _fallbackFacetPrograms = [
    'Bachelor of Science in Criminology',
  ];

  final TextEditingController _searchController = TextEditingController();

  List<StudentAttendance> _allStudents = const <StudentAttendance>[];
  late final List<String> _programOptions;
  List<StudentAttendance> _filteredStudents = const <StudentAttendance>[];
  String _activeFilter = _allFilter;
  String _selectedProgram = _allProgramsFilter;
  bool _isLoadingStudents = true;
  String? _studentsLoadError;

  int get _presentCount => _allStudents
      .where((student) => student.status == EventAttendanceStatus.present)
      .length;

  int get _absentCount => _allStudents
      .where((student) => student.status == EventAttendanceStatus.absent)
      .length;

  int get _totalCount => _allStudents.length;

  @override
  void initState() {
    super.initState();
    final configuredPrograms =
        FacultyCatalog.programsByFaculty[_facetFacultyKey] ??
        _fallbackFacetPrograms;
    _programOptions = [_allProgramsFilter, ...configuredPrograms];

    _loadAttendanceRecords();
  }

  bool _isEventDoneResolved() {
    final explicit = widget.isEventDone;
    if (explicit != null) {
      return explicit;
    }

    final rawDate = widget.eventDateRaw?.trim() ?? '';
    if (rawDate.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return false;
    }

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final eventDateOnly = DateTime(parsed.year, parsed.month, parsed.day);

    return eventDateOnly.isBefore(todayDateOnly);
  }

  Future<void> _loadAttendanceRecords() async {
    final fallbackStudents = List<StudentAttendance>.from(
      widget.students ?? const <StudentAttendance>[],
    );
    final eventId = widget.eventId;

    if (eventId == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _allStudents = fallbackStudents;
        _isLoadingStudents = false;
        _studentsLoadError = null;
        _applyFilters();
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingStudents = true;
        _studentsLoadError = null;
      });
    }

    try {
      final students = await EventAttendanceQueryService.fetchEventStudents(
        eventId: eventId,
        isEventDone: _isEventDoneResolved(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _allStudents = students;
        _isLoadingStudents = false;
        _studentsLoadError = null;
        _applyFilters();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _allStudents = fallbackStudents;
        _isLoadingStudents = false;
        _studentsLoadError =
            'Unable to load event attendance from server. Pull down and retry.';
        _applyFilters();
      });
    }
  }

  void _onSearchChanged(String _) {
    setState(_applyFilters);
  }

  void _setFilter(String filter) {
    if (filter == _activeFilter) {
      return;
    }

    setState(() {
      _activeFilter = filter;
      _applyFilters();
    });
  }

  void _setProgramFilter(String program) {
    if (program == _selectedProgram) {
      return;
    }

    setState(() {
      _selectedProgram = program;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final searched = EventAttendanceDomain.filterStudents(
      _allStudents,
      _searchController.text,
    );

    final statusFiltered = _activeFilter == _allFilter
        ? searched
        : searched.where((student) => student.status == _activeFilter).toList();

    _filteredStudents = statusFiltered.where(_matchesProgramFilter).toList();
  }

  bool _matchesProgramFilter(StudentAttendance student) {
    if (_selectedProgram == _allProgramsFilter) {
      return true;
    }

    final normalizedProgram = student.program.toLowerCase();
    final tokens = _programTokens(_selectedProgram);

    if (tokens.isEmpty) {
      return true;
    }

    return tokens.every(normalizedProgram.contains);
  }

  List<String> _programTokens(String program) {
    const ignoredWords = {'bachelor', 'of', 'science', 'in', 'with', 'major'};

    return program
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty && !ignoredWords.contains(token))
        .toList();
  }

  String _programFilterLabel() {
    if (_selectedProgram == _allProgramsFilter) {
      return 'All';
    }

    if (_selectedProgram.contains('Information Technology')) {
      return 'BSIT';
    }

    if (_selectedProgram.contains('Civil Engineering')) {
      return 'Civil Eng';
    }

    if (_selectedProgram.contains('Industrial Technology')) {
      return 'Ind Tech';
    }

    if (_selectedProgram.contains('Mathematics')) {
      return 'Math & Stats';
    }

    return 'Program';
  }

  Future<void> _openProgramChoicesSheet() async {
    final selectedProgram = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: royalBlue.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: royalBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: royalBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Ionicons.library_outline,
                            size: 15,
                            color: royalBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Choose Program',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: lightGray),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.58,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _programOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      itemBuilder: (context, index) {
                        final option = _programOptions[index];
                        final isSelected = option == _selectedProgram;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.pop(context, option),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? royalBlue.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? royalBlue.withOpacity(0.25)
                                      : royalBlue.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Ionicons.checkmark_circle
                                        : Ionicons.ellipse_outline,
                                    size: 17,
                                    color: isSelected
                                        ? royalBlue
                                        : darkGray.withOpacity(0.55),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? royalBlue
                                            : darkGray,
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
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
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedProgram == null) {
      return;
    }

    _setProgramFilter(selectedProgram);
  }

  Color _statusColor(String status) {
    switch (status) {
      case EventAttendanceStatus.present:
        return const Color(0xFF2E7D32);
      case EventAttendanceStatus.absent:
        return const Color(0xFFC62828);
      default:
        return gold;
    }
  }

  double _ratio(int value) {
    if (_totalCount == 0) {
      return 0;
    }

    return value / _totalCount;
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
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 240,
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
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                      child: Column(
                        children: [
                          _buildEventCard(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatsCard(
                                  title: 'Present',
                                  count: _presentCount,
                                  progress: _ratio(_presentCount),
                                  color: const Color(0xFF2E7D32),
                                  icon: Ionicons.checkmark_circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatsCard(
                                  title: 'Absent',
                                  count: _absentCount,
                                  progress: _ratio(_absentCount),
                                  color: const Color(0xFFC62828),
                                  icon: Ionicons.close_circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSearchAndFilters(),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _isLoadingStudents
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _studentsLoadError != null &&
                                      _allStudents.isEmpty
                                ? _buildStudentsErrorState()
                                : RefreshIndicator(
                                    color: royalBlue,
                                    onRefresh: _loadAttendanceRecords,
                                    child: _filteredStudents.isEmpty
                                        ? ListView(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            children: [
                                              const SizedBox(height: 48),
                                              _buildEmptyStudentsState(),
                                            ],
                                          )
                                        : ListView.separated(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: _filteredStudents.length,
                                            separatorBuilder: (_, _) =>
                                                const SizedBox(height: 10),
                                            itemBuilder: (context, index) {
                                              return _buildStudentCard(
                                                _filteredStudents[index],
                                              );
                                            },
                                          ),
                                  ),
                          ),
                        ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: SizedBox(
        height: 34,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
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
                    text: 'Event ',
                    style: TextStyle(color: royalBlue),
                  ),
                  TextSpan(
                    text: 'Record',
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

  Widget _buildEventCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.1)),
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
          SizedBox(
            height: 98,
            width: double.infinity,
            child: _buildEventImage(widget.eventImage),
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
                        widget.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: royalBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (widget.isObligatory)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OBLIGATORY',
                          style: TextStyle(
                            color: royalBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
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
                      size: 13,
                      color: darkGray,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.eventDate,
                        style: const TextStyle(
                          color: darkGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'ID ${_eventCode()}',
                      style: TextStyle(
                        color: darkGray.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Ionicons.location_outline,
                      size: 13,
                      color: darkGray,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.eventLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: darkGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeChip(
                        icon: Ionicons.log_in_outline,
                        label: 'In',
                        value: widget.eventTimeIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeChip(
                        icon: Ionicons.log_out_outline,
                        label: 'Out',
                        value: widget.eventTimeOut,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: royalBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: royalBlue),
          const SizedBox(width: 4),
          Text(
            '$label:',
            style: const TextStyle(
              color: darkGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: royalBlue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required int count,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    final totalLabel = _totalCount.toString();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: royalBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: darkGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count of $totalLabel',
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

  Widget _buildSearchAndFilters() {
    final hasSearch = _searchController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(color: royalBlue, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search student name or ID',
            hintStyle: const TextStyle(color: darkGray, fontSize: 13),
            prefixIcon: const Icon(
              Ionicons.search_outline,
              color: darkGray,
              size: 18,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: hasSearch
                ? IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(_applyFilters);
                    },
                    icon: const Icon(
                      Ionicons.close_circle,
                      color: darkGray,
                      size: 18,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: royalBlue.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: royalBlue.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: royalBlue),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildProgramFilterChip(),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Present',
              value: EventAttendanceStatus.present,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Absent',
              value: EventAttendanceStatus.absent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgramFilterChip() {
    final isProgramAll = _selectedProgram == _allProgramsFilter;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _openProgramChoicesSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isProgramAll ? royalBlue.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isProgramAll ? royalBlue : royalBlue.withOpacity(0.14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.school_outline,
                  size: 12,
                  color: isProgramAll ? royalBlue : darkGray,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _programFilterLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isProgramAll ? royalBlue : darkGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Ionicons.chevron_down,
                  size: 12,
                  color: isProgramAll ? royalBlue : darkGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String value}) {
    final isActive = _activeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? royalBlue.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? royalBlue : royalBlue.withOpacity(0.14),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? royalBlue : darkGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendance student) {
    final statusColor = _statusColor(student.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(student),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: royalBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.program,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  student.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMiniTime(
                icon: Ionicons.log_in_outline,
                color: const Color(0xFF2E7D32),
                value: student.timeIn,
              ),
              const SizedBox(width: 14),
              _buildMiniTime(
                icon: Ionicons.log_out_outline,
                color: const Color(0xFFE65100),
                value: student.timeOut,
              ),
              const Spacer(),
              Text(
                'ID ${student.id}',
                style: const TextStyle(
                  color: darkGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTime({
    required IconData icon,
    required Color color,
    required String? value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          value?.isNotEmpty == true ? value! : '-',
          style: const TextStyle(
            color: royalBlue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(StudentAttendance student) {
    final initials = _initialsFromName(student.name);

    if (student.avatarUrl.trim().isEmpty) {
      return _buildInitialAvatar(initials);
    }

    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          student.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initials) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: royalBlue.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: royalBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStudentsErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Ionicons.cloud_offline_outline,
              color: darkGray,
              size: 44,
            ),
            const SizedBox(height: 10),
            Text(
              _studentsLoadError ?? 'Unable to load attendance records.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadAttendanceRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: royalBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStudentsState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Ionicons.people_outline, color: darkGray, size: 44),
            SizedBox(height: 10),
            Text(
              'No attendance records found',
              style: TextStyle(
                color: darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: lightGray,
          alignment: Alignment.center,
          child: const Icon(Ionicons.image_outline, color: darkGray),
        ),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: lightGray,
        alignment: Alignment.center,
        child: const Icon(Ionicons.image_outline, color: darkGray),
      ),
    );
  }

  String _initialsFromName(String name) {
    final segments = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return 'ST';
    }

    final first = segments.first.substring(0, 1);
    final second = segments.length > 1 ? segments[1].substring(0, 1) : '';

    return (first + second).toUpperCase();
  }

  String _eventCode() {
    final id = widget.eventId;
    if (id == null) {
      return '#----';
    }

    return '#${id.toString().padLeft(4, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
