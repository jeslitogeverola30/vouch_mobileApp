import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/data/local/database_helper.dart';
import '../../../../core/services/avatar_sync_service.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../data/supabase_profile_repository_impl.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);

class ActivityCardScreen extends StatefulWidget {
  const ActivityCardScreen({super.key});

  @override
  State<ActivityCardScreen> createState() => _ActivityCardScreenState();
}

class _ActivityCardScreenState extends State<ActivityCardScreen> {
  String _studentName = 'Jeslito G. Geverola';
  String _studentProgram = 'BS - Information Technology';
  String _studentId = '2023-0222';
  String _avatarUrl = '';

  static const _rowOneActivities = [
    //7 max items
    ('General Cleaning', false),
    ('ACES Membership Fee', false),
    ('CB Membership Fee', true),
    ('Panaghigalaay', false),
    ('Siglakas Fee', false),
    ('Panaghigalaay', false),
    ('Siglakas Fee', false),
    ('Panaghigalaay', false),
  ];

  static const _rowTwoActivities = [
    //7 max items
    ('General Meeting', false),
    ('Siglakas Attendance', false),
    ('FaCETLABAN', true),
    ('Community Service', false),
    ('Skills Training', false),
    ('Community Service', false),
    ('Skills Training', false),
    ('Skills Training', false),
  ];

  @override
  void initState() {
    super.initState();

    final syncedAvatar = AvatarSyncService.notifier.value;
    if (syncedAvatar.email == _normalizedCurrentEmail() &&
        syncedAvatar.avatarUrl != null) {
      _avatarUrl = syncedAvatar.avatarUrl!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentProfile();
    });
  }

  Future<void> _loadStudentProfile() async {
    final email = SupabaseAuthService.currentUser?.email;

    Map<String, dynamic>? student;
    try {
      student =
          (await SupabaseProfileRepositoryImpl.instance.getCurrentUserProfile())
              ?.toMap();
    } catch (_) {
      student = null;
    }

    if (student == null && email != null && email.isNotEmpty) {
      student = await DatabaseHelper.instance.getStudentByEmail(email);
    }

    if (student == null || !mounted) {
      return;
    }

    setState(() {
      _studentName = (student!['full_name'] as String? ?? _studentName).trim();
      _studentProgram = (student['program'] as String? ?? _studentProgram)
          .trim();
      _studentId = (student['student_id'] as String? ?? _studentId).trim();
      _avatarUrl = (student['profile_photo_url'] as String? ?? _avatarUrl)
          .trim();
    });

    AvatarSyncService.setAvatar(
      email: (student['email'] as String?) ?? email,
      avatarUrl: _avatarUrl,
    );
  }

  String? _normalizedCurrentEmail() {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    return email.toLowerCase();
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
            Positioned(
              left: -60,
              bottom: 12,
              child: Transform.rotate(
                angle: 1.57079632679,
                child: _buildOfficiallyClearedTab(),
              ),
            ),
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
              child: const SizedBox(
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(
                      '                      Semester 2 • A.Y. 2026-2027',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
