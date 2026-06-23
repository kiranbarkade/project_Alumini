import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _branchController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _resumeController = TextEditingController();
  final _skillsController = TextEditingController();
  final _companyController = TextEditingController();
  final _designationController = TextEditingController();
  final _aboutController = TextEditingController();

  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _branchController.dispose();
    _gradYearController.dispose();
    _linkedinController.dispose();
    _resumeController.dispose();
    _skillsController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final skillsList = _skillsController.text.isEmpty
        ? <String>[]
        : _skillsController.text.split(',').map((s) => s.trim()).toList();

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'role': _selectedRole,
      'branch': _branchController.text.trim(),
      'graduationYear': int.tryParse(_gradYearController.text.trim()) ?? 0,
      'linkedinUrl': _linkedinController.text.trim(),
      'resumeUrl': _resumeController.text.trim(),
      'skills': skillsList,
      'about': _aboutController.text.trim(),
      if (_selectedRole == 'alumni') 'company': _companyController.text.trim(),
      if (_selectedRole == 'alumni') 'designation': _designationController.text.trim(),
      'profileImage': 'https://api.dicebear.com/7.x/adventurer/svg?seed=${_nameController.text.trim().replaceAll(' ', '')}',
    };

    final success = await auth.signUp(data);
    if (success) {
      if (mounted) {
        context.go('/');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Failed to register account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join CareerBridge',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with Zeal classmates, alumni, and access career pipelines.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Core Fields
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'e.g. Yuraj Patil',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g. yuraj.patil@zeal.edu.in',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Min 6 characters',
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Password is required';
                    if (val.trim().length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Register As',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'alumni', child: Text('Alumnus (Graduate)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Common fields
                CustomTextField(
                  controller: _branchController,
                  label: 'Engineering Branch',
                  hint: 'e.g. Computer Engineering',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Branch is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _gradYearController,
                  label: 'Graduation Year',
                  hint: 'e.g. 2027',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Graduation year is required';
                    if (int.tryParse(val) == null) return 'Please enter a valid year';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Conditionally visible fields for Alumni only
                if (_selectedRole == 'alumni') ...[
                  CustomTextField(
                    controller: _companyController,
                    label: 'Current Company',
                    hint: 'e.g. Google',
                    validator: (val) {
                      if (_selectedRole == 'alumni' && (val == null || val.trim().isEmpty)) {
                        return 'Company is required for alumni';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _designationController,
                    label: 'Job Role / Designation',
                    hint: 'e.g. Software Engineer III',
                    validator: (val) {
                      if (_selectedRole == 'alumni' && (val == null || val.trim().isEmpty)) {
                        return 'Role designation is required for alumni';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Career Info
                CustomTextField(
                  controller: _skillsController,
                  label: 'Skills (Comma separated)',
                  hint: 'e.g. Flutter, Node.js, Python, SQL',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn Profile URL',
                  hint: 'e.g. https://linkedin.com/in/username',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _resumeController,
                  label: 'Resume Document URL',
                  hint: 'e.g. https://domain.com/my_resume.pdf',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _aboutController,
                  label: 'About Me',
                  hint: 'Brief summary of your career focus...',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
