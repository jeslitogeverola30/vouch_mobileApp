import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class StudentProfileAdminScreen extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String institution;
  final String email;
  final String program;
  final String avatarPath;
  final bool isActive;

  const StudentProfileAdminScreen({
    Key? key,
    this.studentName = 'Jeslito G. Geverola',
    this.studentId = '2023-0222',
    this.institution = 'DOrSU Student',
    this.email = 'jeslito.geverola@dorsu.edu.ph',
    this.program = 'BS - Information Technology',
    this.avatarPath = 'https://via.placeholder.com/150',
    this.isActive = true,
  }) : super(key: key);

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
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE3F2FD).withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFEB3B).withOpacity(0.3),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Text(
                    'Student Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003DA5),
                    ),
                  ),
                ),
                // Royal blue header banner
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Color(0xFF003DA5),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(0),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Gold diagonal stripe
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: 80,
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Container(
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ),
                          // Vouch branding icons
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    color: Color(0xFF003DA5),
                                  ),
                                  child: Icon(
                                    Ionicons.shield_checkmark,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    color: Color(0xFF003DA5),
                                  ),
                                  child: Icon(
                                    Ionicons.checkmark_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile avatar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -40,
                      child: Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              avatarPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Color(0xFFE0E0E0),
                                  child: Icon(
                                    Ionicons.person,
                                    size: 50,
                                    color: Color(0xFF999999),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                // Student information
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003DA5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        studentId,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        institution,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Active status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFC8E6C9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Action cards
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionCard(
                        icon: Ionicons.school,
                        label: 'Program',
                        value: program,
                      ),
                      SizedBox(height: 16),
                      _buildActionCard(
                        icon: Ionicons.calendar,
                        label: 'Event Attendance',
                        value: 'View Event Attendance',
                        isClickable: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('View Event Attendance'),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildActionCard(
                        icon: Ionicons.wallet,
                        label: 'Payments',
                        value: 'View Payments',
                        isClickable: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('View Payments'),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildActionCard(
                        icon: Ionicons.card,
                        label: 'Activity Card',
                        value: 'View Activity Card',
                        isClickable: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('View Activity Card'),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF003DA5),
          unselectedItemColor: Color(0xFF999999),
          currentIndex: 1,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Ionicons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.calendar),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.card),
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE3F2FD),
              ),
              child: Icon(
                icon,
                color: Color(0xFF003DA5),
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF003DA5),
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(
                Ionicons.chevron_forward,
                color: Color(0xFF999999),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
