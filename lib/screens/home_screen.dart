import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/alumni_provider.dart';
import '../providers/mentorship_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/loading_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    Provider.of<JobProvider>(context, listen: false).fetchJobs();
    Provider.of<AlumniProvider>(context, listen: false).fetchAlumni();
    if (user != null) {
      if (user.role == 'student') {
        Provider.of<MentorshipProvider>(context, listen: false)
            .fetchSessions(studentId: user.id);
      } else if (user.role == 'alumni') {
        Provider.of<MentorshipProvider>(context, listen: false)
            .fetchSessions(alumniId: user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);

    // Refresh layout if user role changes
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CareerBridge',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Consumer<NotificationProvider>(
                  builder: (context, np, _) {
                    if (np.unreadCount == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${np.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Banner
                    _buildWelcomeBanner(user, theme),
                    const SizedBox(height: 20),

                    // 2. Search Bar
                    _buildSearchBar(theme),
                    const SizedBox(height: 24),

                    // 3. Mentorship Sessions Preview
                    _buildMentorshipPreview(user, theme),

                    // 4. Featured Alumni
                    _buildFeaturedAlumni(theme),
                    const SizedBox(height: 24),

                    // 5. Latest Jobs
                    _buildLatestJobs(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeBanner(dynamic user, ThemeData theme) {
    String greeting = 'Hello,';
    String desc = 'Connect with alumni & fast-track your career.';
    if (user.role == 'alumni') {
      greeting = 'Welcome Back,';
      desc = 'Help students with referrals & mentorship.';
    } else if (user.role == 'admin') {
      greeting = 'Admin Console,';
      desc = 'Manage portal metrics and alumni relations.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: user.profileImage.isNotEmpty
                    ? NetworkImage(user.profileImage)
                    : null,
                child: user.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        readOnly: true,
        onTap: () {
          // Go to alumni directory
          context.go('/directory');
        },
        decoration: InputDecoration(
          hintText: 'Search alumni, skills, or companies...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMentorshipPreview(dynamic user, ThemeData theme) {
    final mentorshipProvider = Provider.of<MentorshipProvider>(context);
    final sessions = mentorshipProvider.sessions
        .where((s) => s.status == 'approved')
        .toList();

    if (sessions.isEmpty) return const SizedBox.shrink();

    final nextSession = sessions.first;
    final displayUser = user.role == 'student' ? nextSession.alumniId : nextSession.studentId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.tertiaryContainer.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: theme.colorScheme.tertiary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Next Scheduled Session',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: displayUser.profileImage.isNotEmpty
                    ? NetworkImage(displayUser.profileImage)
                    : null,
                child: displayUser.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayUser.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      nextSession.topic,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${nextSession.date.day}/${nextSession.date.month}/${nextSession.date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    nextSession.timeSlot,
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedAlumni(ThemeData theme) {
    final alumniProvider = Provider.of<AlumniProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Alumni',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go('/directory'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        alumniProvider.isLoading
            ? SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, idx) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: LoadingShimmer(width: 140, height: 160, borderRadius: 16),
                  ),
                ),
              )
            : alumniProvider.error != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    child: Text('Failed to load: ${alumniProvider.error}'),
                  )
                : alumniProvider.alumni.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No alumni found'),
                      )
                    : SizedBox(
                        height: 175,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alumniProvider.alumni.length,
                          itemBuilder: (context, idx) {
                            final alum = alumniProvider.alumni[idx];
                            return _buildAlumniCard(alum, theme);
                          },
                        ),
                      ),
      ],
    );
  }

  Widget _buildAlumniCard(dynamic alum, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        context.push('/alumni/${alum.id}');
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: alum.profileImage.isNotEmpty
                  ? NetworkImage(alum.profileImage)
                  : null,
              child: alum.profileImage.isEmpty
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              alum.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              alum.designation,
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                alum.company,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestJobs(ThemeData theme) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Job Opportunities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go('/jobs'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        jobProvider.isLoading
            ? SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 2,
                  itemBuilder: (context, idx) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: LoadingShimmer(width: 260, height: 110, borderRadius: 16),
                  ),
                ),
              )
            : jobProvider.error != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    child: Text('Failed to load jobs: ${jobProvider.error}'),
                  )
                : jobProvider.jobs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No job postings available'),
                      )
                    : SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: jobProvider.jobs.take(5).length,
                          itemBuilder: (context, idx) {
                            final job = jobProvider.jobs[idx];
                            return _buildJobCard(job, theme);
                          },
                        ),
                      ),
      ],
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

    return GestureDetector(
      onTap: () {
        context.push('/jobs/${job.id}');
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${job.company} • ${job.location}',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.type.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
