import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  bool get isMarathi => locale.languageCode == 'mr';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Mazi Shala',
      'app_tagline': 'Residential Welfare & Management Platform for Government Ashram Schools',
      'login': 'Login',
      'logout': 'Logout',
      'username': 'Username',
      'password': 'Password',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Mobile Number',
      'role': 'Role',
      'school_id': 'School ID',
      'school_name': 'School Name',
      'district': 'District',
      'state': 'State',
      'address': 'Address',
      'dashboard': 'Dashboard',
      'students': 'Students',
      'teachers': 'Teachers',
      'wardens': 'Wardens',
      'parents': 'Parents',
      'attendance': 'Attendance',
      'hostel': 'Hostel',
      'health': 'Health',
      'scholarships': 'Scholarships',
      'inventory': 'Inventory',
      'announcements': 'Announcements',
      'reports': 'Reports',
      'settings': 'Settings',
      'register_school': 'Register New School',
      'join_school': 'Join Existing School',
      'pending_approval': 'Pending Approval',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'present': 'Present',
      'absent': 'Absent',
      'on_leave': 'On Leave',
      'total_students': 'Total Students',
      'total_teachers': 'Total Teachers',
      'total_wardens': 'Total Wardens',
      'hostel_occupancy': 'Hostel Occupancy',
      'attendance_rate': 'Attendance Rate',
      'health_alerts': 'Health Alerts',
      'low_stock_alerts': 'Low Stock Alerts',
      'emergency_cases': 'Emergency Cases',
      'save': 'Save',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'mark_attendance': 'Mark Attendance',
      'add_student': 'Add Student',
      'room_allocation': 'Bed Allocation',
      'meal_tracking': 'Nutrition & Meals',
      'leave_requests': 'Leave Requests',
      'academic_remarks': 'Academic Remarks',
      'student_concerns': 'Student Concerns',
      'export_pdf': 'Download PDF',
      'export_excel': 'Download Excel',
      'quick_demo_login': 'Quick Demo Access (Select Role):',
      'switch_to_marathi': 'मराठी मध्ये बदला',
      'switch_to_english': 'Switch to English',
      'school_data_isolated': 'Strict Multi-School Data Isolation Active',
      'offline_mode': 'Offline Mode: Data saved locally. Syncs when connected.',
      'online_mode': 'Online - Live Database Connected',
      'repeated_absence_alert': 'Repeated Absence Warning',
      'bed': 'Bed',
      'room': 'Room',
      'roll_number': 'Roll No / ID',
      'class': 'Class',
      'division': 'Division',
      'gender': 'Gender',
      'blood_group': 'Blood Group',
      'emergency_contact': 'Emergency Contact',
    },
    'mr': {
      'app_title': 'माझी शाळा',
      'app_tagline': 'शासकीय आश्रमशाळा निवासी कल्याण व संस्थात्मक व्यवस्थापन प्रणाली',
      'login': 'लॉगिन करा',
      'logout': 'लॉगआउट',
      'username': 'वापरकर्ता नाव (Username)',
      'password': 'पासवर्ड (Password)',
      'full_name': 'पूर्ण नाव',
      'email': 'ईमेल पत्ता',
      'phone': 'मोबाईल क्रमांक',
      'role': 'भूमिका (Role)',
      'school_id': 'शाळा सांकेतांक (School ID)',
      'school_name': 'शाळेचे नाव',
      'district': 'जिल्हा',
      'state': 'राज्य',
      'address': 'पत्ता',
      'dashboard': 'डॅशबोर्ड',
      'students': 'विद्यार्थी',
      'teachers': 'शिक्षक',
      'wardens': 'गृहप्रमुख / अधीक्षक',
      'parents': 'पालक',
      'attendance': 'उपस्थिती',
      'hostel': 'वसतिगृह',
      'health': 'आरोग्य',
      'scholarships': 'शिष्यवृत्ती व योजना',
      'inventory': 'वस्तू साठा',
      'announcements': 'सूचना फलक',
      'reports': 'अहवाल',
      'settings': 'सेटिंग्ज',
      'register_school': 'नवीन शाळा नोंदणी करा',
      'join_school': 'शाळेत सामील व्हा',
      'pending_approval': 'मुख्याध्यापक मंजुरी प्रलंबित',
      'approved': 'मंजूर',
      'rejected': 'नाकारले',
      'present': 'हजर',
      'absent': 'गैरहजर',
      'on_leave': 'रजेवर',
      'total_students': 'एकूण विद्यार्थी',
      'total_teachers': 'एकूण शिक्षक',
      'total_wardens': 'एकूण अधीक्षक',
      'hostel_occupancy': 'वसतिगृह भरती',
      'attendance_rate': 'उपस्थिती टक्केवारी',
      'health_alerts': 'आरोग्य सूचना / इशारे',
      'low_stock_alerts': 'कमी साठा सूचना',
      'emergency_cases': 'तातडीचे / आपत्कालीन प्रसंग',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'submit': 'सादर करा',
      'mark_attendance': 'उपस्थिती नोंदवा',
      'add_student': 'विद्यार्थी जोडा',
      'room_allocation': 'खोली व खाट वाटप',
      'meal_tracking': 'आहार व भोजन नोंद',
      'leave_requests': 'विद्यार्थी रजा अर्ज',
      'academic_remarks': 'शैक्षणिक शेरे',
      'student_concerns': 'विद्यार्थी समस्या नोंद',
      'export_pdf': 'PDF अहवाल डाउनलोड',
      'export_excel': 'Excel अहवाल डाउनलोड',
      'quick_demo_login': 'जलद डेमो प्रवेश (भूमिका निवडा):',
      'switch_to_marathi': 'मराठी मध्ये बदला',
      'switch_to_english': 'Switch to English',
      'school_data_isolated': 'कठोर बहु-शाळा डेटा अलगीकरण सक्रिय',
      'offline_mode': 'ऑफलाईन मोड: डेटा स्थानिक पातळीवर जतन केला आहे.',
      'online_mode': 'ऑनलाईन - थेट डेटाबेस जोडलेला आहे',
      'repeated_absence_alert': 'वारंवार गैरहजरी इशारा',
      'bed': 'खाट',
      'room': 'खोली',
      'roll_number': 'हजेरी क्रमांक / आयडी',
      'class': 'इयत्ता',
      'division': 'तुकडी',
      'gender': 'लिंग',
      'blood_group': 'रक्तगट',
      'emergency_contact': 'तातडीचा संपर्क',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
