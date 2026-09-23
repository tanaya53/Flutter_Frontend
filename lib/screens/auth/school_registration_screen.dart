import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../principal/principal_dashboard.dart';

class SchoolRegistrationScreen extends StatefulWidget {
  const SchoolRegistrationScreen({super.key});

  @override
  State<SchoolRegistrationScreen> createState() => _SchoolRegistrationScreenState();
}

class _SchoolRegistrationScreenState extends State<SchoolRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _schoolNameController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _principalNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolIdController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _principalNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerSchool(
      schoolName: _schoolNameController.text.trim(),
      schoolId: _schoolIdController.text.trim().toUpperCase(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      principalName: _principalNameController.text.trim(),
      principalEmail: _emailController.text.trim(),
      principalPhone: _phoneController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('School and Principal registered successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrincipalDashboard()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr.translate('register_school')),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Registering a new Ashram School automatically creates the Principal / School Administrator account with full isolation.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (auth.errorMessage != null) ...[
                      Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                    ],

                    const Text(
                      '1. Institutional Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _schoolNameController,
                      label: tr.translate('school_name'),
                      hint: 'e.g. Government Ashram School Manor',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    CustomTextField(
                      controller: _schoolIdController,
                      label: 'Unique School ID (e.g. ASH003)',
                      hint: 'e.g. ASH003',
                      validator: (v) => (v == null || v.isEmpty) ? 'Unique School ID is required' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _districtController,
                            label: tr.translate('district'),
                            hint: 'e.g. Palghar / Nandurbar',
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _stateController,
                            label: tr.translate('state'),
                            hint: 'Maharashtra',
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: _addressController,
                      label: tr.translate('address'),
                      hint: 'School postal address & taluka',
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      '2. Principal / Administrator Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _principalNameController,
                      label: 'Principal Full Name',
                      hint: 'e.g. Rajesh Patil',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    CustomTextField(
                      controller: _emailController,
                      label: tr.translate('email'),
                      hint: 'principal@school.mah.gov.in',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    CustomTextField(
                      controller: _phoneController,
                      label: tr.translate('phone'),
                      hint: '9823012345',
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Principal Username',
                      hint: 'e.g. principal_ash003',
                      validator: (v) => (v == null || v.isEmpty) ? 'Username required' : null,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      label: tr.translate('password'),
                      hint: 'Minimum 6 characters',
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                    ),

                    const SizedBox(height: 16),
                    CustomButton(
                      text: tr.translate('register_school'),
                      isLoading: auth.isLoading,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
