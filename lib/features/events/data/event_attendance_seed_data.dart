import '../domain/event_attendance.dart';

class EventAttendanceSeedData {
  EventAttendanceSeedData._();

  static const List<StudentAttendance> students = [
    StudentAttendance(
      id: '2020-1234',
      name: 'Juan Dela Cruz',
      program: 'BS Information Technology',
      timeIn: '07:45 AM',
      timeOut: '04:30 PM',
      status: EventAttendanceStatus.present,
      avatarUrl: 'https://via.placeholder.com/50/003DA5/FFFFFF?text=JDC',
    ),
    StudentAttendance(
      id: '2020-1234',
      name: 'Juan Dela Cruz',
      program: 'BS Information Technology',
      timeIn: '07:45 AM',
      timeOut: '04:30 PM',
      status: EventAttendanceStatus.present,
      avatarUrl: 'https://via.placeholder.com/50/003DA5/FFFFFF?text=JDC',
    ),
    StudentAttendance(
      id: '2020-5678',
      name: 'Maria Santos',
      program: 'BS Computer Science',
      timeIn: '08:15 AM',
      timeOut: '03:45 PM',
      status: EventAttendanceStatus.present,
      avatarUrl: 'https://via.placeholder.com/50/F44336/FFFFFF?text=MS',
    ),
    StudentAttendance(
      id: '2021-2345',
      name: 'Roberto Lopez',
      program: 'BS Engineering',
      timeIn: null,
      timeOut: null,
      status: EventAttendanceStatus.absent,
      avatarUrl: 'https://via.placeholder.com/50/9C27B0/FFFFFF?text=RL',
    ),
  ];
}
