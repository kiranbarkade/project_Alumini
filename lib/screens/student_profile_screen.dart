import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/referral_provider.dart';
import '../providers/mentorship_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      Provider.of<ReferralProvider>(context, listen: false).fetchReferrals(studentId: user.id);
      Provider.of<MentorshipProvider>(context, listen: false).fetchSessions(studentId: user.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final rp = Provider.of<ReferralProvider>(context);
    final mp = Provider.of<MentorshipProvider>(context);
    final theme = Theme.of(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Student Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfileDialog(user, auth),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Profile Summary Card
          _buildProfileCard(user, theme),
          
          // 2. Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Referrals Sent'),
              Tab(text: 'Mentorship Sessions'),
            ],
          ),

          // 3. Tab contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReferralsList(rp, theme),
                _buildMentorshipList(mp, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: user.profileImage.isNotEmpty ? NetworkImage(user.profileImage) : null,
                child: user.profileImage.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.college,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '${user.branch} • Batch of ${user.graduationYear}',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user.about.isNotEmpty) ...[
            Text(
              user.about,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          if (user.skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (user.skills as List<String>)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (user.resumeUrl.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening Resume Document: ${user.resumeUrl}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description, size: 14, color: theme.colorScheme.onSecondaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          'View Resume',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (user.linkedinUrl.isNotEmpty)
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening LinkedIn Profile: ${user.linkedinUrl}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A66C2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0A66C2).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, color: Color(0xFF0A66C2), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'LinkedIn',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A66C2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Log Out', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralsList(ReferralProvider rp, ThemeData theme) {
    if (rp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rp.referrals.isEmpty) {
      return const Center(child: Text('No referral requests sent yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rp.referrals.length,
      itemBuilder: (context, idx) {
        final ref = rp.referrals[idx];
        
        final jobTitle = ref.jobId is dynamic && ref.jobId != null && ref.jobId.title != null 
            ? ref.jobId.title 
            : 'SDE Opportunity';
        final company = ref.jobId is dynamic && ref.jobId != null && ref.jobId.company != null 
            ? ref.jobId.company 
            : 'Partner Corporation';
        final alumniName = ref.alumniId is dynamic && ref.alumniId != null && ref.alumniId.name != null 
            ? ref.alumniId.name 
            : 'Alumnus';

        Color statusColor;
        switch (ref.status) {
          case 'accepted':
            statusColor = Colors.green;
            break;
          case 'rejected':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.orange;
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        jobTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ref.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Referrer: $alumniName',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  'Message: "${ref.message}"',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7), fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMentorshipList(MentorshipProvider mp, ThemeData theme) {
    if (mp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mp.sessions.isEmpty) {
      return const Center(child: Text('No mentorship sessions booked yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mp.sessions.length,
      itemBuilder: (context, idx) {
        final sess = mp.sessions[idx];
        final alumniName = sess.alumniId is dynamic && sess.alumniId != null && sess.alumniId.name != null 
            ? sess.alumniId.name 
            : 'Mentor';
        final alumniRole = sess.alumniId is dynamic && sess.alumniId != null && sess.alumniId.designation != null 
            ? '${sess.alumniId.designation} at ${sess.alumniId.company}' 
            : 'Alumnus';

        Color statusColor;
        switch (sess.status) {
          case 'approved':
            statusColor = Colors.blue;
            break;
          case 'completed':
            statusColor = Colors.green;
            break;
          case 'rejected':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.orange;
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          color: theme.colorScheme.surfaceContainerLow,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sess.topic,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sess.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Mentor: $alumniName ($alumniRole)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${sess.date.day}/${sess.date.month}/${sess.date.year}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      sess.timeSlot,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                if (sess.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes: "${sess.notes}"',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(dynamic user, AuthProvider auth) {
    final aboutController = TextEditingController(text: user.about);
    final skillsController = TextEditingController(text: (user.skills as List<String>).join(', '));
    final resumeController = TextEditingController(text: user.resumeUrl);
    final branchController = TextEditingController(text: user.branch);
    final gradYearController = TextEditingController(text: user.graduationYear.toString());
    final linkedinController = TextEditingController(text: user.linkedinUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: branchController,
                  label: 'Engineering Branch',
                  hint: 'e.g. Computer Engineering',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: gradYearController,
                  label: 'Graduation Year',
                  hint: 'e.g. 2027',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: linkedinController,
                  label: 'LinkedIn Profile URL',
                  hint: 'https://linkedin.com/in/username',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: aboutController,
                  label: 'About Me',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: skillsController,
                  label: 'Skills (comma separated)',
                  hint: 'Flutter, Node.js, Python',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: resumeController,
                  label: 'Resume PDF URL',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final skillsList = skillsController.text.trim().isEmpty
                    ? <String>[]
                    : skillsController.text.split(',').map((s) => s.trim()).toList();

                await auth.updateProfile({
                  'about': aboutController.text.trim(),
                  'skills': skillsList,
                  'resumeUrl': resumeController.text.trim(),
                  'branch': branchController.text.trim(),
                  'graduationYear': int.tryParse(gradYearController.text.trim()) ?? 0,
                  'linkedinUrl': linkedinController.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
