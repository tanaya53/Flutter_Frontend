import 'package:flutter/foundation.dart';

class ApiConstants {
  // For Android Emulator, use '10.0.2.2'
  // For Physical Device over Wi-Fi, use your PC's IP: e.g. '192.168.0.111'
  // For Physical Device over USB with `adb reverse tcp:8000 tcp:8000`, use '127.0.0.1'
  static const String customHost = '10.0.2.2';

  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      return 'http://$host:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$customHost:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // Auth endpoints
  static String get login => '$baseUrl/auth/login/';
  static String get registerSchool => '$baseUrl/auth/register-school/';
  static String get registerUser => '$baseUrl/auth/register-user/';
  static String get userProfile => '$baseUrl/auth/profile/';
  static String get joinRequests => '$baseUrl/auth/join-requests/';
  static String approveUser(int id) => '$baseUrl/auth/approve-user/$id/';
  static String get staffList => '$baseUrl/auth/staff/';

  // School endpoints
  static String get verifySchoolId => '$baseUrl/schools/verify-id/';
  static String get currentSchool => '$baseUrl/schools/current/';

  // Student endpoints
  static String get students => '$baseUrl/students/';
  static String studentDetail(int id) => '$baseUrl/students/$id/';
  static String get myStudents => '$baseUrl/students/my-students/';
  static String get myChild => '$baseUrl/students/my-child/';
  static String get remarks => '$baseUrl/students/remarks/';
  static String get concerns => '$baseUrl/students/concerns/';

  // Attendance endpoints
  static String get attendance => '$baseUrl/attendance/';
  static String get bulkAttendance => '$baseUrl/attendance/bulk/';
  static String get attendanceSummary => '$baseUrl/attendance/summary/';
  static String get repeatedAbsentees => '$baseUrl/attendance/repeated-absentees/';
  static String studentAttendanceHistory(int id) => '$baseUrl/attendance/student/$id/';
  static String get hostelAttendance => '$baseUrl/attendance/hostel/';

  // Health endpoints
  static String get healthProfiles => '$baseUrl/health/profiles/';
  static String get healthCheckups => '$baseUrl/health/checkups/';
  static String get healthVaccinations => '$baseUrl/health/vaccinations/';
  static String get healthAlerts => '$baseUrl/health/alerts/';
  static String get healthSummary => '$baseUrl/health/summary/';
  static String studentHealthDetail(int id) => '$baseUrl/health/student/$id/';

  // Hostel endpoints
  static String get hostels => '$baseUrl/hostel/';
  static String get hostelRooms => '$baseUrl/hostel/rooms/';
  static String get allocateBed => '$baseUrl/hostel/allocate-bed/';
  static String get hostelLeaves => '$baseUrl/hostel/leaves/';
  static String processLeave(int id) => '$baseUrl/hostel/process-leave/$id/';
  static String get hostelIncidents => '$baseUrl/hostel/incidents/';
  static String get hostelMeals => '$baseUrl/hostel/meals/';
  static String get foodStocks => '$baseUrl/hostel/food-stocks/';
  static String get hostelSummary => '$baseUrl/hostel/summary/';

  // Scholarships endpoints
  static String get scholarships => '$baseUrl/scholarships/';
  static String get welfareSchemes => '$baseUrl/scholarships/schemes/';
  static String get scholarshipSummary => '$baseUrl/scholarships/summary/';

  // Inventory endpoints
  static String get inventory => '$baseUrl/inventory/';
  static String get inventoryTransactions => '$baseUrl/inventory/transactions/';
  static String get issueStock => '$baseUrl/inventory/issue/';
  static String get returnStock => '$baseUrl/inventory/return/';
  static String get inventorySummary => '$baseUrl/inventory/summary/';

  // Announcements endpoints
  static String get announcements => '$baseUrl/announcements/';
  static String markAnnouncementRead(int id) => '$baseUrl/announcements/mark-read/$id/';

  // Reports endpoints
  static String get principalAnalytics => '$baseUrl/reports/analytics/';
  static String get reportAttendance => '$baseUrl/reports/attendance/';
  static String get reportStudents => '$baseUrl/reports/students/';
  static String get reportHostel => '$baseUrl/reports/hostel/';
  static String get reportInventory => '$baseUrl/reports/inventory/';
  static String get reportScholarships => '$baseUrl/reports/scholarships/';
}
