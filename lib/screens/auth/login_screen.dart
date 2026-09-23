import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/language_toggle.dart';
import 'school_registration_screen.dart';
import 'user_registration_screen.dart';
import '../principal/principal_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../warden/warden_dashboard.dart';
import '../parent/parent_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateForRole(String role) {
    Widget destination;
    switch (role.toLowerCase()) {
      case 'principal':
        destination = const PrincipalDashboard();
        break;
      case 'teacher':
        destination = const TeacherDashboard();
        break;
      case 'warden':
        destination = const WardenDashboard();
        break;
      case 'parent':
        destination = const ParentDashboard();
        break;
      default:
        destination = const PrincipalDashboard();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted && auth.currentUser != null) {
      _navigateForRole(auth.currentUser!.role);
    }
  }

  Future<void> _handleQuickDemo(String role, {String school = 'ASH001'}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.quickDemoLogin(role, school: school);
    if (success && mounted && auth.currentUser != null) {
      _navigateForRole(auth.currentUser!.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('माझी शाळा - MAZI SHALA'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: LanguageToggle(isDark: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Institutional header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr.translate('app_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr.translate('app_tagline'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Multi-school data isolation security banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr.translate('school_data_isolated'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Banner
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _usernameController,
                          label: tr.translate('username'),
                          hint: 'Enter your username or email',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => (v == null || v.isEmpty) ? 'Username is required' : null,
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          label: tr.translate('password'),
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 6),
                        CustomButton(
                          text: tr.translate('login'),
                          isLoading: auth.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Quick Demo Selector for Evaluators
                  Text(
                    tr.translate('quick_demo_login'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRoleChip('Palghar Principal (ASH001)', () => _handleQuickDemo('principal', school: 'ASH001'), AppColors.primary),
                      _buildRoleChip('Palghar Teacher (ASH001)', () => _handleQuickDemo('teacher', school: 'ASH001'), AppColors.secondary),
                      _buildRoleChip('Palghar Warden (ASH001)', () => _handleQuickDemo('warden', school: 'ASH001'), AppColors.warning),
                      _buildRoleChip('Palghar Parent (ASH001)', () => _handleQuickDemo('parent', school: 'ASH001'), AppColors.info),
                      _buildRoleChip('Nandurbar Principal (ASH002)', () => _handleQuickDemo('principal', school: 'ASH002'), Colors.deepPurple),
                      _buildRoleChip('Nandurbar Teacher (ASH002)', () => _handleQuickDemo('teacher', school: 'ASH002'), Colors.teal),
                      _buildRoleChip('Nandurbar Warden (ASH002)', () => _handleQuickDemo('warden', school: 'ASH002'), Colors.brown),
                      _buildRoleChip('Nandurbar Parent (ASH002)', () => _handleQuickDemo('parent', school: 'ASH002'), Colors.blueGrey),
                    ],
                  ),

                  const SizedBox(height: 28),
                  // Register Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SchoolRegistrationScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            tr.translate('register_school'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const UserRegistrationScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            tr.translate('join_school'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, VoidCallback onTap, Color color) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.08),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onPressed: onTap,
    );
  }
}
