import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/custom_button.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../widgets/custom_textfield.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _selectedLocation = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
    });
  }

  void _onSearch() {
    Provider.of<JobProvider>(context, listen: false).fetchJobs(
      search: _searchController.text,
      type: _selectedType,
      location: _selectedLocation,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedType = 'All';
      _selectedLocation = '';
    });
    Provider.of<JobProvider>(context, listen: false).fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final theme = Theme.of(context);

    final showPostFab = currentUser != null && (currentUser.role == 'alumni' || currentUser.role == 'admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Opportunities Board',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _onSearch(),
          ),
        ],
      ),
      floatingActionButton: showPostFab
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.add),
              onPressed: () => _showAddJobModal(currentUser.id, theme),
            )
          : null,
      body: Column(
        children: [
          // 1. Filter Chips and search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search jobs, company, skills...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showFilterSheet(theme),
                ),
              ],
            ),
          ),

          // Active filters preview
          if (_selectedType != 'All' || _selectedLocation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 8),
              child: Row(
                children: [
                  const Text('Active: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (_selectedType != 'All')
                          Chip(
                            label: Text(_selectedType.toUpperCase()),
                            onDeleted: () {
                              setState(() => _selectedType = 'All');
                              _onSearch();
                            },
                          ),
                        if (_selectedLocation.isNotEmpty)
                          Chip(
                            label: Text(_selectedLocation),
                            onDeleted: () {
                              setState(() => _selectedLocation = '');
                              _onSearch();
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // 2. Opportunities List
          Expanded(
            child: jobProvider.isLoading
                ? LoadingShimmer.cardList()
                : jobProvider.error != null
                    ? EmptyStateView(
                        icon: Icons.error_outline,
                        title: 'Error loading jobs',
                        description: jobProvider.error!,
                        actionText: 'Retry',
                        onActionPressed: () => _onSearch(),
                      )
                    : jobProvider.jobs.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.work_off_outlined,
                            title: 'No Listings Found',
                            description: 'Be the first to post a job or internship opportunity!',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            itemCount: jobProvider.jobs.length,
                            itemBuilder: (context, index) {
                              final job = jobProvider.jobs[index];
                              return _buildJobCard(job, theme);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(dynamic job, ThemeData theme) {
    IconData typeIcon;
    Color typeColor;
    switch (job.type) {
      case 'internship':
        typeIcon = Icons.card_membership;
        typeColor = Colors.orange;
        break;
      case 'referral':
        typeIcon = Icons.shortcut;
        typeColor = Colors.green;
        break;
      default:
        typeIcon = Icons.work;
        typeColor = Colors.blue;
    }

    final experience = job is JobModel ? (job as JobModel).experienceRequired : (job.experienceRequired ?? 'Fresher');
    final deadline = job is JobModel ? (job as JobModel).deadline : (job.deadline ?? 'N/A');
    final applyLink = job is JobModel ? (job as JobModel).applyLink : (job.applyLink ?? '');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.location,
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.salary.isNotEmpty ? job.salary : 'Unspecified Pay',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (deadline.toString().isNotEmpty)
                  Text(
                    'Deadline: $deadline',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/jobs/${job.id}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                if (applyLink.toString().isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening Application URL: $applyLink')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Opportunities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Job Type
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Job/Opportunity Type'),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Types')),
                      DropdownMenuItem(value: 'fulltime', child: Text('Full-time')),
                      DropdownMenuItem(value: 'internship', child: Text('Internship')),
                      DropdownMenuItem(value: 'referral', child: Text('Referral Opportunity')),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedType = val ?? 'All');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Location Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Pune, Remote',
                    ),
                    onChanged: (val) {
                      setModalState(() => _selectedLocation = val.trim());
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearFilters();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _onSearch();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddJobModal(String postedById, ThemeData theme) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final descController = TextEditingController();
    final skillsController = TextEditingController();
    String jobType = 'fulltime';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post Opportunity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(controller: titleController, label: 'Job Title', hint: 'e.g., Flutter Intern'),
                    const SizedBox(height: 12),
                    CustomTextField(controller: companyController, label: 'Company Name'),
                    const SizedBox(height: 12),
                    CustomTextField(controller: locationController, label: 'Location', hint: 'e.g., Pune / Remote'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: jobType,
                      decoration: const InputDecoration(labelText: 'Opportunity Type'),
                      items: const [
                        DropdownMenuItem(value: 'fulltime', child: Text('Full-time Job')),
                        DropdownMenuItem(value: 'internship', child: Text('Internship')),
                        DropdownMenuItem(value: 'referral', child: Text('Referral Opportunity')),
                      ],
                      onChanged: (val) {
                        setModalState(() => jobType = val ?? 'fulltime');
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(controller: salaryController, label: 'Salary/Compensation', hint: 'e.g., ₹25,000/mo or 12 LPA'),
                    const SizedBox(height: 12),
                    CustomTextField(controller: skillsController, label: 'Skills Required (comma separated)', hint: 'Flutter, Dart, Git'),
                    const SizedBox(height: 12),
                    CustomTextField(controller: descController, label: 'Job Description', maxLines: 4),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Post Listing',
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            companyController.text.isEmpty ||
                            descController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill title, company, and description')),
                          );
                          return;
                        }

                        final skillsList = skillsController.text.isEmpty
                            ? <String>[]
                            : skillsController.text.split(',').map((s) => s.trim()).toList();

                        await Provider.of<JobProvider>(context, listen: false).postJob({
                          'title': titleController.text.trim(),
                          'company': companyController.text.trim(),
                          'location': locationController.text.trim(),
                          'type': jobType,
                          'salary': salaryController.text.trim(),
                          'description': descController.text.trim(),
                          'postedBy': postedById,
                          'skillsRequired': skillsList,
                        });

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opportunity posted successfully!')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
