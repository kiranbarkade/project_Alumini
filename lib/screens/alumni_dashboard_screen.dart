import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/referral_provider.dart';
import '../providers/mentorship_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AlumniDashboardScreen extends StatefulWidget {
  const AlumniDashboardScreen({super.key});

  @override
  State<AlumniDashboardScreen> createState() => _AlumniDashboardScreenState();
}

class _AlumniDashboardScreenState extends State<AlumniDashboardScreen> with SingleTickerProviderStateMixin {
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
      Provider.of<ReferralProvider>(context, listen: false).fetchReferrals(alumniId: user.id);
      Provider.of<MentorshipProvider>(context, listen: false).fetchSessions(alumniId: user.id);
      Provider.of<AuthProvider>(context, listen: false).refreshProfile();
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

    // Calculated metrics
    final totalReferrals = rp.referrals.length;
    final pendingReferrals = rp.referrals.where((r) => r.status == 'pending').length;
    final totalMentorships = mp.sessions.length;
    final pendingMentorships = mp.sessions.where((s) => s.status == 'pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Grid of Stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('Total Referrals', '$totalReferrals', Icons.shortcut, Colors.green, theme),
                _buildStatCard('Pending Referrals', '$pendingReferrals', Icons.hourglass_top, Colors.orange, theme),
                _buildStatCard('Mentorship Slots', '$totalMentorships', Icons.calendar_month, Colors.blue, theme),
                _buildStatCard('Session Requests', '$pendingMentorships', Icons.notifications_active, Colors.indigo, theme),
              ],
            ),
          ),

          // 2. Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Referral Requests'),
              Tab(text: 'Mentorship Bookings'),
            ],
          ),

          // 3. Tab contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReferralRequestQueue(rp, theme),
                _buildMentorshipBookingQueue(mp, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralRequestQueue(ReferralProvider rp, ThemeData theme) {
    if (rp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pending = rp.referrals.where((r) => r.status == 'pending').toList();
    final other = rp.referrals.where((r) => r.status != 'pending').toList();
    final sorted = [...pending, ...other];

    if (sorted.isEmpty) {
      return const Center(child: Text('No referral requests found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, idx) {
        final ref = sorted[idx];
        final isPending = ref.status == 'pending';
        
        final studentName = ref.studentId is dynamic && ref.studentId != null && ref.studentId.name != null 
            ? ref.studentId.name 
            : 'Student';
        final studentDetails = ref.studentId is dynamic && ref.studentId != null && ref.studentId.branch != null 
            ? '${ref.studentId.branch} • Batch of ${ref.studentId.graduationYear}' 
            : 'Pre-final Year';
        final jobTitle = ref.jobId is dynamic && ref.jobId != null && ref.jobId.title != null 
            ? ref.jobId.title 
            : 'SDE Intern';
        final company = ref.jobId is dynamic && ref.jobId != null && ref.jobId.company != null 
            ? ref.jobId.company 
            : 'Cognizant';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            studentDetails,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (!isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (ref.status == 'accepted' ? Colors.green : Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ref.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: ref.status == 'accepted' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Applying for: $jobTitle at $company',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Message: "${ref.message}"',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8), fontStyle: FontStyle.italic),
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            rp.updateReferralStatus(ref.id, 'rejected');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            rp.updateReferralStatus(ref.id, 'accepted');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Accept & Refer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMentorshipBookingQueue(MentorshipProvider mp, ThemeData theme) {
    if (mp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pending = mp.sessions.where((s) => s.status == 'pending').toList();
    final other = mp.sessions.where((s) => s.status != 'pending').toList();
    final sorted = [...pending, ...other];

    if (sorted.isEmpty) {
      return const Center(child: Text('No mentorship bookings found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, idx) {
        final sess = sorted[idx];
        final isPending = sess.status == 'pending';
        
        final studentName = sess.studentId is dynamic && sess.studentId != null && sess.studentId.name != null 
            ? sess.studentId.name 
            : 'Student';
        final studentDetails = sess.studentId is dynamic && sess.studentId != null && sess.studentId.branch != null 
            ? '${sess.studentId.branch} • Batch of ${sess.studentId.graduationYear}' 
            : 'Pre-final Year';

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
            borderRadius: BorderRadius.circular(14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sess.topic,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Requested by: $studentName ($studentDetails)',
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (!isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sess.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${sess.date.day}/${sess.date.month}/${sess.date.year}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      sess.timeSlot,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (sess.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Session Details: "${sess.notes}"',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            mp.updateSessionStatus(sess.id, 'rejected');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApproveSessionDialog(sess.id, mp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (sess.status == 'approved') ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Mark as Completed',
                    isSecondary: true,
                    onPressed: () {
                      mp.updateSessionStatus(sess.id, 'completed');
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApproveSessionDialog(String sessionId, MentorshipProvider mp) {
    final notesController = TextEditingController(text: 'Google Meet link: meet.google.com/abc-defg-hij');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Mentorship Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add session details (e.g. video call link, notes):', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              CustomTextField(
                controller: notesController,
                label: 'Notes / Video Link',
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                mp.updateSessionStatus(sessionId, 'approved', notes: notesController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mentorship session approved!')),
                );
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }
}
