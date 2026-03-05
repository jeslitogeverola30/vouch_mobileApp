import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/data/local/database_helper.dart';
import '../../data/supabase_profile_repository_impl.dart';

class StudentsDatabaseScreen extends StatefulWidget {
  const StudentsDatabaseScreen({super.key});

  @override
  State<StudentsDatabaseScreen> createState() => _StudentsDatabaseScreenState();
}

class _StudentsDatabaseScreenState extends State<StudentsDatabaseScreen> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _loadStudents();
  }

  Future<void> _refresh() async {
    setState(() {
      _studentsFuture = _loadStudents();
    });
  }

  Future<List<Map<String, dynamic>>> _loadStudents() async {
    try {
      final profiles = await SupabaseProfileRepositoryImpl.instance
          .getAllProfiles();
      if (profiles.isNotEmpty) {
        return profiles.map((profile) => profile.toMap()).toList();
      }
    } catch (_) {}

    return DatabaseHelper.instance.getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Students Database'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF003DA5),
          elevation: 0,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Failed to load students: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              );
            }

            final students = snapshot.data ?? const <Map<String, dynamic>>[];
            if (students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No student records found.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                itemCount: students.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final student = students[index];
                  final fullName = student['full_name'] as String? ?? '-';
                  final email = student['email'] as String? ?? '-';
                  final studentId = student['student_id'] as String? ?? '-';
                  final faculty = student['faculty'] as String? ?? '-';
                  final program = student['program'] as String? ?? '-';

                  return Container(
                    padding: const EdgeInsets.all(14),
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003DA5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Email: $email'),
                        Text('Student ID: $studentId'),
                        Text('Faculty: $faculty'),
                        Text('Program: $program'),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
