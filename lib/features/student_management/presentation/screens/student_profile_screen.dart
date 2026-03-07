import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/supabase_student_management_impl.dart';
import '../../domain/student_management_repository.dart';
import '../../../profile/presentation/admin/student_activity_card_screen.dart';

class StudentProfileAdminScreen extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String institution;
  final String email;
  final String program;
  final String avatarPath;
  final String studentStatus;

  const StudentProfileAdminScreen({
    super.key,
    this.studentName = 'Jeslito G. Geverola',
    this.studentId = '2023-0222',
    this.institution = 'DOrSU Student',
    this.email = 'jeslito.geverola@dorsu.edu.ph',
    this.program = 'BS Information Technology',
    this.avatarPath = 'https://via.placeholder.com/150',
    this.studentStatus = 'Active',
  });

  @override
  State<StudentProfileAdminScreen> createState() =>
      _StudentProfileAdminScreenState();
}

class _StudentProfileAdminScreenState extends State<StudentProfileAdminScreen> {
  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _mutedText = Color(0xFF6B7280);
  final StudentManagementRepository _studentRepository =
      SupabaseStudentManagementImpl.instance;

  late String _currentStatus;
  bool _isUpdatingStatus = false;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.studentStatus;
  }

  Color _statusBackgroundColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFF8E1);
      case 'Frozen':
        return const Color(0xFFECEFF1);
      case 'Active':
      default:
        return const Color(0xFFC8E6C9);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF8F00);
      case 'Frozen':
        return const Color(0xFF455A64);
      case 'Active':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Widget _buildAvatarImage() {
    final avatarPath = widget.avatarPath.trim();
    if (avatarPath.isEmpty) {
      return _buildAvatarFallback();
    }

    final isAssetImage = avatarPath.startsWith('assets/');

    if (isAssetImage) {
      return Image.asset(
        avatarPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarFallback();
        },
      );
    }

    return Image.network(
      avatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildAvatarFallback();
      },
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(Ionicons.person, size: 40, color: Color(0xFF9CA3AF)),
    );
  }

  void _showActionToast(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _setStatus(String status) async {
    if (_currentStatus == status || _isUpdatingStatus || _isDeletingAccount) {
      return;
    }

    final studentId = widget.studentId.trim();
    if (studentId.isEmpty) {
      _showActionToast('Missing student ID');
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      if (status == 'Active') {
        await _studentRepository.activateStudents([studentId]);
      } else if (status == 'Frozen') {
        await _studentRepository.freezeStudents([studentId]);
      } else {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() => _currentStatus = status);
      _showActionToast('Account status set to $status');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showActionToast('Unable to update account status');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Account',
            style: TextStyle(
              color: _royalBlue,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Delete ${widget.studentName} account? This action cannot be undone.',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: _royalBlue)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final studentId = widget.studentId.trim();
    if (studentId.isEmpty) {
      _showActionToast('Missing student ID');
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await _studentRepository.deleteStudents([studentId]);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Color(0xFFB3261E),
        ),
      );

      Navigator.of(context).pop({'deleted': true, 'studentId': studentId});
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showActionToast('Unable to delete account');
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
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
                  color: _gold.withOpacity(0.15),
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
                  color: _royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: 'Student Overview',
                            subtitle: 'Profile, account and status information',
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryCard(),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Details',
                            subtitle: 'Primary student information',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Ionicons.card_outline,
                            label: 'Student ID',
                            value: widget.studentId,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Ionicons.school_outline,
                            label: 'Institution',
                            value: widget.institution,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Ionicons.mail_outline,
                            label: 'Email Address',
                            value: widget.email,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Ionicons.book_outline,
                            label: 'Program',
                            value: widget.program,
                          ),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Actions',
                            subtitle: 'Quick access student modules',
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Ionicons.card_outline,
                            title: 'Activity Card',
                            subtitle: 'View student activity card details',
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StudentActivityCardScreen(
                                    studentName: widget.studentName,
                                    studentId: widget.studentId,
                                    email: widget.email,
                                    program: widget.program,
                                    avatarUrl: widget.avatarPath,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Account Controls',
                            subtitle:
                                'Set status to Active/Frozen or delete account',
                          ),
                          const SizedBox(height: 12),
                          _buildAccountControls(),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: _royalBlue),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(
                    text: 'Student ',
                    style: TextStyle(color: _royalBlue),
                  ),
                  TextSpan(
                    text: 'Profile',
                    style: TextStyle(color: _gold),
                  ),
                ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _royalBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _royalBlue.withOpacity(0.12),
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildAvatarImage()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.studentName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _royalBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusBackgroundColor(_currentStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusTextColor(_currentStatus),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.studentId,
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _royalBlue.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _royalBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _royalBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _royalBlue.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _royalBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _royalBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Ionicons.chevron_forward,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountControls() {
    final isActive = _currentStatus == 'Active';
    final isFrozen = _currentStatus == 'Frozen';
    final isBusy = _isUpdatingStatus || _isDeletingAccount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _royalBlue.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => _setStatus('Active'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _royalBlue,
                    backgroundColor: isActive
                        ? _royalBlue.withOpacity(0.08)
                        : Colors.white,
                    side: BorderSide(
                      color: isActive
                          ? _royalBlue
                          : _royalBlue.withOpacity(0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => _setStatus('Frozen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF455A64),
                    backgroundColor: isFrozen
                        ? const Color(0xFFECEFF1)
                        : Colors.white,
                    side: BorderSide(
                      color: isFrozen
                          ? const Color(0xFF455A64)
                          : _royalBlue.withOpacity(0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Frozen',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : _confirmDeleteAccount,
              icon: const Icon(Ionicons.trash_outline, size: 18),
              label: const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
