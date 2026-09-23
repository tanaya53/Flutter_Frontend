import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final _studentIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _admissionNoController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String _selectedGender = 'MALE';
  String _selectedClass = 'Class 8';
  String _selectedDivision = 'A';
  String _selectedBloodGroup = 'O+';
  bool _isSaving = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _admissionNoController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _api.post(ApiConstants.students, {
        'student_id': _studentIdController.text.trim().toUpperCase(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'gender': _selectedGender,
        'grade_class': _selectedClass,
        'division': _selectedDivision,
        'blood_group': _selectedBloodGroup,
        'admission_number': _admissionNoController.text.trim(),
        'emergency_contact': _emergencyContactController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student enrolled successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.translate('add_student')),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _studentIdController,
                    label: 'Student Roll / Registration ID',
                    hint: 'e.g. ASH001-S05',
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          hint: 'First name',
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          hint: 'Surname',
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: const [
                                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedGender = v);
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Class', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedClass,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: const [
                                DropdownMenuItem(value: 'Class 6', child: Text('Class 6')),
                                DropdownMenuItem(value: 'Class 7', child: Text('Class 7')),
                                DropdownMenuItem(value: 'Class 8', child: Text('Class 8')),
                                DropdownMenuItem(value: 'Class 9', child: Text('Class 9')),
                                DropdownMenuItem(value: 'Class 10', child: Text('Class 10')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedClass = v);
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedBloodGroup,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: const [
                                DropdownMenuItem(value: 'A+', child: Text('A+')),
                                DropdownMenuItem(value: 'B+', child: Text('B+')),
                                DropdownMenuItem(value: 'O+', child: Text('O+')),
                                DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                                DropdownMenuItem(value: 'A-', child: Text('A-')),
                                DropdownMenuItem(value: 'B-', child: Text('B-')),
                                DropdownMenuItem(value: 'O-', child: Text('O-')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedBloodGroup = v);
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _emergencyContactController,
                          label: 'Emergency Contact',
                          hint: 'Guardian Mobile',
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: _addressController,
                    label: 'Village / Home Address',
                    hint: 'At Post, Taluka',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Save Student Enrollment',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
