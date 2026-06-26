import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _descController = TextEditingController();
  final _applyLinkController = TextEditingController();
  final _skillsController = TextEditingController();

  String _selectedTitle = 'Software Engineer';
  String _selectedCompany = 'Google';
  String _selectedJobType = 'Full Time';
  String _selectedLocation = 'Pune';
  String _selectedExperience = 'Fresher';

  bool _isCustomTitle = false;
  bool _isCustomCompany = false;
  bool _isCustomLocation = false;

  final List<String> _titleOptions = ['Software Engineer', 'Frontend Developer', 'Data Analyst', 'Other (Specify)'];
  final List<String> _companyOptions = ['Google', 'Microsoft', 'TCS', 'Other (Specify)'];
  final List<String> _jobTypes = ['Full Time', 'Internship', 'Part Time'];
  final List<String> _locations = ['Pune', 'Mumbai', 'Remote', 'Other (Specify)'];
  final List<String> _experienceOptions = ['Fresher', '1-2 Years', '3+ Years'];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _deadlineController.dispose();
    _descController.dispose();
    _applyLinkController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      setState(() {
        _deadlineController.text = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Opportunity', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Job Title Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedTitle,
                        decoration: const InputDecoration(
                          labelText: 'Job Title',
                          border: OutlineInputBorder(),
                        ),
                        items: _titleOptions
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedTitle = val!;
                            _isCustomTitle = val == 'Other (Specify)';
                          });
                        },
                      ),
                      if (_isCustomTitle) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _titleController,
                          label: 'Specify Job Title',
                          hint: 'e.g. Flutter Developer',
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Company Name Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCompany,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                        ),
                        items: _companyOptions
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCompany = val!;
                            _isCustomCompany = val == 'Other (Specify)';
                          });
                        },
                      ),
                      if (_isCustomCompany) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _companyController,
                          label: 'Specify Company Name',
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Job Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedJobType,
                        decoration: const InputDecoration(
                          labelText: 'Job Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _jobTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedJobType = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        items: _locations
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedLocation = val!;
                            _isCustomLocation = val == 'Other (Specify)';
                          });
                        },
                      ),
                      if (_isCustomLocation) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _locationController,
                          label: 'Specify Location',
                          hint: 'e.g. Hyderabad / Remote',
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Experience Required Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedExperience,
                        decoration: const InputDecoration(
                          labelText: 'Experience Required',
                          border: OutlineInputBorder(),
                        ),
                        items: _experienceOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedExperience = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Salary Field
                      CustomTextField(
                        controller: _salaryController,
                        label: 'Salary/Stipend',
                        hint: 'e.g. ₹8 LPA or ₹15,000/month',
                      ),
                      const SizedBox(height: 16),

                      // Deadline Field
                      TextFormField(
                        controller: _deadlineController,
                        readOnly: true,
                        onTap: () => _selectDeadline(context),
                        decoration: const InputDecoration(
                          labelText: 'Application Deadline',
                          hintText: 'Select last date to apply',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed Description',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _skillsController,
                        label: 'Skills Required (comma separated)',
                        hint: 'e.g. React, JavaScript, HTML/CSS',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descController,
                        label: 'Job Description',
                        maxLines: 5,
                        hint: 'Looking for React developers. Good knowledge of JavaScript and React. Freshers can apply.',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _applyLinkController,
                        label: 'Apply Link',
                        hint: 'https://company.com/careers',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Consumer<JobProvider>(
                builder: (context, jobProvider, _) {
                  return CustomButton(
                    text: 'Post Job',
                    isLoading: jobProvider.isLoading,
                    onPressed: () async {
                      if (_descController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add a job description')),
                        );
                        return;
                      }

                      final finalTitle = _isCustomTitle
                          ? _titleController.text.trim()
                          : _selectedTitle;
                      final finalCompany = _isCustomCompany
                          ? _companyController.text.trim()
                          : _selectedCompany;
                      final finalLocation = _isCustomLocation
                          ? _locationController.text.trim()
                          : _selectedLocation;

                      if (finalTitle.isEmpty || finalCompany.isEmpty || finalLocation.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter title, company, and location')),
                        );
                        return;
                      }

                      final skillsList = _skillsController.text.trim().isEmpty
                          ? <String>[]
                          : _skillsController.text.split(',').map((s) => s.trim()).toList();

                      // Map human readable Job Type to system keys: 'fulltime', 'internship', 'referral'
                      String sysType = 'fulltime';
                      if (_selectedJobType == 'Internship') {
                        sysType = 'internship';
                      } else if (_selectedJobType == 'Part Time') {
                        sysType = 'referral'; // map part time or referral
                      }

                      await jobProvider.postJob({
                        'title': finalTitle,
                        'company': finalCompany,
                        'location': finalLocation,
                        'type': sysType,
                        'salary': _salaryController.text.trim(),
                        'experienceRequired': _selectedExperience,
                        'deadline': _deadlineController.text.trim(),
                        'applyLink': _applyLinkController.text.trim(),
                        'description': _descController.text.trim(),
                        'skillsRequired': skillsList,
                        'postedBy': user?.id ?? '',
                      });

                      if (mounted) {
                        if (jobProvider.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job posted successfully!')),
                          );
                          // Reset form
                          _formKey.currentState?.reset();
                          _titleController.clear();
                          _companyController.clear();
                          _locationController.clear();
                          _salaryController.clear();
                          _deadlineController.clear();
                          _descController.clear();
                          _applyLinkController.clear();
                          _skillsController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(jobProvider.error ?? 'Failed to post job')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
