import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _schoolIdController = TextEditingController(text: 'ASH001');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'teacher';
  bool _registrationSubmitted = false;
  String? _successMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _schoolIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final msg = await auth.registerUser(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      schoolId: _schoolIdController.text.trim().toUpperCase(),
    );

    if (msg != null && mounted) {
      setState(() {
        _registrationSubmitted = true;
        _successMessage = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);

    if (_registrationSubmitted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(tr.translate('join_school')),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Application Submitted!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _successMessage ??
                        'Your account has been submitted and is currently pending approval by the School Principal. Once approved, you can log in.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Return to Login',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr.translate('join_school')),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Teachers, Wardens, and Parents must specify their School ID. The Principal reviews and approves all join requests.',
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

                    CustomTextField(
                      controller: _schoolIdController,
                      label: 'Target School ID',
                      hint: 'e.g. ASH001 or ASH002',
                      validator: (v) => (v == null || v.isEmpty) ? 'School ID required' : null,
                    ),

                    const Text(
                      'Your Role in the Ashram School',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2D3748)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: const [
                        DropdownMenuItem(value: 'teacher', child: Text('Teacher / Mentor (शिक्षक)')),
                        DropdownMenuItem(value: 'warden', child: Text('Hostel Warden (गृहप्रमुख / अधीक्षक)')),
                        DropdownMenuItem(value: 'parent', child: Text('Parent / Guardian (पालक)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _fullNameController,
                      label: tr.translate('full_name'),
                      hint: 'Enter your full name',
                      validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                    ),
                    CustomTextField(
                      controller: _phoneController,
                      label: tr.translate('phone'),
                      hint: '9823012345',
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Phone required' : null,
                    ),
                    CustomTextField(
                      controller: _emailController,
                      label: tr.translate('email'),
                      hint: 'name@example.com (optional)',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: _usernameController,
                      label: tr.translate('username'),
                      hint: 'Create username',
                      validator: (v) => (v == null || v.isEmpty) ? 'Username required' : null,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      label: tr.translate('password'),
                      hint: 'Min 6 characters',
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters required' : null,
                    ),

                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Submit Join Request',
                      isLoading: auth.isLoading,
                      onPressed: _handleSubmit,
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
}
