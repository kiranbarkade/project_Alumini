import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/referral_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobDetails(widget.jobId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<JobProvider>(context, listen: false).clearSelectedJob();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    final job = jobProvider.selectedJob;
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(job?.title ?? 'Opportunity Details'),
      ),
      body: jobProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobProvider.error != null
              ? Center(child: Text('Error: ${jobProvider.error}'))
              : job == null
                  ? const Center(child: Text('Opportunity not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Information
                          _buildHeaderCard(job, theme),
                          const SizedBox(height: 24),

                          // 2. Action buttons (Referral Request shortcut for Students)
                          if (currentUser != null && currentUser.role == 'student') ...[
                            CustomButton(
                              text: 'Request Referral for this Role',
                              icon: Icons.shortcut,
                              onPressed: () => _showReferralModal(job, currentUser.id, theme),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 3. Description
                          const Text(
                            'Description',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.description,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // 4. Skills required
                          if (job.skillsRequired.isNotEmpty) ...[
                            const Text(
                              'Key Skills Required',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (job.skillsRequired as List<String>)
                                  .map((s) => Chip(
                                        label: Text(s),
                                        backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 5. Posted By profile
                          _buildPosterSection(job, theme),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeaderCard(dynamic job, ThemeData theme) {
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      job.company,
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Icons.location_on_outlined, 'Location', job.location, theme),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.currency_rupee, 'Salary', job.salary.isNotEmpty ? job.salary : 'Unspecified Pay', theme),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined, 'Opportunity Type', job.type.toString().toUpperCase(), theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPosterSection(dynamic job, ThemeData theme) {
    final poster = job.postedBy;
    if (poster == null) return const SizedBox.shrink();

    final isUserModel = poster is dynamic && poster.id != null;
    final name = isUserModel ? poster.name : 'College Coordinator';
    final desc = isUserModel ? '${poster.designation} at ${poster.company}' : 'Placement Cell Admin';
    final image = isUserModel ? poster.profileImage : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posted By',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      desc,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (isUserModel)
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    context.push('/alumni/${poster.id}');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReferralModal(dynamic job, String studentId, ThemeData theme) {
    final messageController = TextEditingController();
    final alumniId = job.postedBy != null && job.postedBy.id != null ? job.postedBy.id : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Referral - ${job.company}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'You are requesting a referral for the position of "${job.title}". A request will be sent to the job coordinator.',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: messageController,
                label: 'Pitch Message',
                hint: 'Briefly write why you are an excellent fit for this role. Highlight key projects.',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Consumer<ReferralProvider>(
                builder: (context, rp, _) {
                  return CustomButton(
                    text: 'Submit Request',
                    isLoading: rp.isLoading,
                    onPressed: () async {
                      if (messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a message')),
                        );
                        return;
                      }

                      if (alumniId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot find post author to request referral')),
                        );
                        return;
                      }

                      final success = await rp.sendReferralRequest({
                        'studentId': studentId,
                        'alumniId': alumniId,
                        'jobId': job.id,
                        'message': messageController.text.trim(),
                      });

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral request successfully submitted!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(rp.error ?? 'Failed to request referral')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
