import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/event_attendance_seed_data.dart';
import '../../domain/event_attendance.dart';

class EventRecordScreen extends StatefulWidget {
  const EventRecordScreen({Key? key}) : super(key: key);

  @override
  State<EventRecordScreen> createState() => _EventRecordScreenState();
}

class _EventRecordScreenState extends State<EventRecordScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<StudentAttendance> _filteredStudents;
  late List<StudentAttendance> _allStudents;

  @override
  void initState() {
    super.initState();
    _initializeStudents();
  }

  void _initializeStudents() {
    _allStudents = List<StudentAttendance>.from(
      EventAttendanceSeedData.students,
    );
    _filteredStudents = _allStudents;
  }

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = EventAttendanceDomain.filterStudents(
        _allStudents,
        query,
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return const Color(0xFF4CAF50);
      case 'ABSENT':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFFFC107);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8FB4E8).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC107).withOpacity(0.2),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Ionicons.chevron_back,
                          color: Color(0xFF003DA5),
                          size: 24,
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Event ',
                              style: TextStyle(
                                color: Color(0xFF003DA5),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Record',
                              style: TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Ionicons.create,
                        color: Color(0xFF003DA5),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                // Event Details Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003DA5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OFFICIAL RECORD',
                                style: TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'ID #EV-2023-0824',
                              style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'General Assembly 2023',
                          style: TextStyle(
                            color: Color(0xFF003DA5),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Ionicons.location,
                              size: 16,
                              color: Color(0xFF999999),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'University Gymnasium',
                              style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Ionicons.calendar,
                              size: 16,
                              color: Color(0xFF999999),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Oct 24, 2023',
                              style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Statistics Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Attendees
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: 0.79,
                                      strokeWidth: 6,
                                      backgroundColor: const Color(0xFFE0E0E0),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF4CAF50),
                                          ),
                                    ),
                                  ),
                                  const Text(
                                    '79%',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'ATTENDEES',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '1,240',
                                style: TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'of 1,500',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Absent
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: 0.21,
                                      strokeWidth: 6,
                                      backgroundColor: const Color(0xFFE0E0E0),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFF44336),
                                          ),
                                    ),
                                  ),
                                  const Text(
                                    '21%',
                                    style: TextStyle(
                                      color: Color(0xFFF44336),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'ABSENT',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '260',
                                style: TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'of 1,500',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterStudents,
                          decoration: InputDecoration(
                            hintText: 'Search student name,id...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFBDBDBD),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Ionicons.search,
                              color: Color(0xFF999999),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Ionicons.options,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Student List
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF003DA5),
          unselectedItemColor: const Color(0xFF999999),
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            // Handle navigation
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Ionicons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.calendar),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.wallet),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendance student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(student.avatarUrl),
                backgroundColor: const Color(0xFFE0E0E0),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.program,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
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
                  color: _getStatusColor(student.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  student.status,
                  style: TextStyle(
                    color: _getStatusColor(student.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (student.timeIn != null) ...[
                const Icon(Ionicons.log_in, size: 16, color: Color(0xFF4CAF50)),
                const SizedBox(width: 6),
                Text(
                  student.timeIn!,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: 16),
              if (student.timeOut != null) ...[
                const Icon(
                  Ionicons.log_out,
                  size: 16,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(width: 6),
                Text(
                  student.timeOut!,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'ID: ${student.id}',
                style: const TextStyle(color: Color(0xFF999999), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
