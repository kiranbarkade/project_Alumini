import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/mentorship_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AlumniRequestsScreen extends StatefulWidget {
  const AlumniRequestsScreen({super.key});

  @override
  State<AlumniRequestsScreen> createState() => _AlumniRequestsScreenState();
}

class _AlumniRequestsScreenState extends State<AlumniRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserRepository _userRepository = UserRepository();
  List<UserModel> _students = [];
  bool _isStudentsLoading = false;
  String _searchQuery = '';
  String? _selectedBranch = 'All';
  final List<String> _branches = [
    'All',
    'Computer Engineering',
    'Information Technology',
    'Electronics & Telecommunication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      Provider.of<MentorshipProvider>(context, listen: false).fetchSessions(alumniId: user.id);
    }
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() {
      _isStudentsLoading = true;
    });
    try {
      final branchQuery = (_selectedBranch == null || _selectedBranch == 'All') ? null : _selectedBranch;
      final list = await _userRepository.getStudents(
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        branch: branchQuery,
      );
      if (mounted) {
        setState(() {
          _students = list;
          _isStudentsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStudentsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MentorshipProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Connections', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Find Students'),
            Tab(text: 'Pending Requests'),
            Tab(text: 'My Connections'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentDirectory(mp, theme),
          _buildPendingQueue(mp, theme),
          _buildConnectedQueue(mp, theme),
        ],
      ),
    );
  }

  Widget _buildStudentDirectory(MentorshipProvider mp, ThemeData theme) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.currentUser;

    if (_isStudentsLoading && _students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Search & Filters Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students (e.g. name, skills)',
                    hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLowest,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _fetchStudents();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Branch filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  color: theme.colorScheme.surfaceContainerLowest,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBranch,
                    icon: const Icon(Icons.filter_list, size: 18),
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                    items: _branches.map((String b) {
                      return DropdownMenuItem<String>(
                        value: b,
                        child: Text(b == 'All' ? 'All Branches' : (b.length > 20 ? '${b.substring(0, 17)}...' : b)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBranch = val;
                      });
                      _fetchStudents();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isStudentsLoading)
          const LinearProgressIndicator(),
        
        // Students List
        Expanded(
          child: _students.isEmpty && !_isStudentsLoading
              ? const Center(child: Text('No students found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, idx) {
                    final student = _students[idx];
                    
                    // Determine connection status with current Alumnus
                    String connectionStatus = 'none';
                    String sessionId = '';
                    if (currentUser != null) {
                      final sessions = mp.sessions.where((s) {
                        final sId = s.studentId is Map<String, dynamic>
                            ? s.studentId['_id'] ?? s.studentId['id'] ?? ''
                            : s.studentId.toString();
                        final aId = s.alumniId is Map<String, dynamic>
                            ? s.alumniId['_id'] ?? s.alumniId['id'] ?? ''
                            : s.alumniId.toString();
                        return sId == student.id && aId == currentUser.id;
                      }).toList();

                      if (sessions.any((s) => s.status == 'approved' || s.status == 'completed')) {
                        connectionStatus = 'connected';
                      } else if (sessions.any((s) => s.status == 'pending')) {
                        connectionStatus = 'pending';
                        final pendingSession = sessions.firstWhere((s) => s.status == 'pending');
                        sessionId = pendingSession.id;
                      }
                    }

                      // Skip rendering if already connected
                      if (connectionStatus == 'connected') {
                        return const SizedBox.shrink();
                      }

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      color: theme.colorScheme.surfaceContainerLow,
                      child: InkWell(
                        onTap: () => _showStudentDetailsSheet(student, connectionStatus, sessionId, mp, theme),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage: student.profileImage.isNotEmpty ? NetworkImage(student.profileImage) : null,
                                    child: student.profileImage.isEmpty ? const Icon(Icons.person, size: 26) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          student.college,
                                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                                        ),
                                        Text(
                                          '${student.branch} • Batch of ${student.graduationYear}',
                                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (student.skills.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: student.skills
                                      .take(4) // Show top 4 skills on card
                                      .map((s) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: theme.colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => _showStudentDetailsSheet(student, connectionStatus, sessionId, mp, theme),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'View Full Profile',
                                          style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                        Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                  _buildConnectionButton(student, connectionStatus, sessionId, mp, theme),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }  Widget _buildConnectionButton(UserModel student, String status, String sessionId, MentorshipProvider mp, ThemeData theme) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.currentUser;

    if (currentUser == null) return const SizedBox();

    // Design colors
    const Color connectBlue = Color(0xFF2563EB);
    const Color requestedGrey = Color(0xFFB0B0B0);
    const Color connectedGreen = Color(0xFF22C55E);

    switch (status) {
      case 'connected':
        return ElevatedButton.icon(
          onPressed: () {
            // Open chat with connected student
            context.push('/chat/${student.id}');
          },
          icon: const Icon(Icons.check_circle, size: 14),
          label: const Text('Connected ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: connectedGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      case 'pending':
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.hourglass_top, size: 12, color: Colors.white),
          label: const Text('Requested', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: requestedGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      default:
        return ElevatedButton.icon(
          onPressed: () async {
            final success = await mp.requestSession({
              'studentId': student.id,
              'alumniId': currentUser.id,
              'topic': 'Connection Request (Initiated by Mentor)',
              'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
              'timeSlot': 'Anytime',
              'status': 'pending', // Create pending request
              'notes': 'Connection established by Alumnus.',
            });

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Connection request sent to ${student.name}!')),
              );
              _loadData();
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mp.error ?? 'Failed to connect')),
              );
            }
          },
          icon: const Icon(Icons.person_add, size: 14),
          label: const Text('Connect', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: connectBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
    }
}

  void _showStudentDetailsSheet(UserModel student, String status, String sessionId, MentorshipProvider mp, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: student.profileImage.isNotEmpty ? NetworkImage(student.profileImage) : null,
                    child: student.profileImage.isEmpty ? const Icon(Icons.person, size: 35) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.college,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          '${student.branch} • Batch of ${student.graduationYear}',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (student.about.isNotEmpty) ...[
                const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  student.about,
                  style: TextStyle(fontSize: 13, height: 1.4, color: theme.colorScheme.onSurface.withOpacity(0.9)),
                ),
                const SizedBox(height: 16),
              ],
              if (student.skills.isNotEmpty) ...[
                const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: student.skills
                      .map((s) => Chip(
                            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            side: BorderSide.none,
                            label: Text(
                              s,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (student.linkedinUrl.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening LinkedIn: ${student.linkedinUrl}')),
                          );
                        },
                        icon: const Icon(Icons.link, color: Color(0xFF0A66C2), size: 16),
                        label: const Text('LinkedIn', style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0A66C2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (student.resumeUrl.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening Resume: ${student.resumeUrl}')),
                          );
                        },
                        icon: Icon(Icons.description, color: theme.colorScheme.primary, size: 16),
                        label: Text('Resume', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildConnectionButton(student, status, sessionId, mp, theme),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingQueue(MentorshipProvider mp, ThemeData theme) {
    if (mp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pending = mp.sessions.where((s) => s.status == 'pending').toList();

    if (pending.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No pending requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'When students request to connect with you, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, idx) {
        final sess = pending[idx];
        final studentName = sess.studentId is Map<String, dynamic>
            ? sess.studentId['name'] ?? 'Student'
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.name != null)
                ? sess.studentId.name
                : 'Student';
        final studentDetails = sess.studentId is Map<String, dynamic>
            ? '${sess.studentId['branch'] ?? ''} • Batch of ${sess.studentId['graduationYear'] ?? ''}'
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.branch != null)
                ? '${sess.studentId.branch} • Batch of ${sess.studentId.graduationYear}'
                : 'Pre-final Year';
        final profileImage = sess.studentId is Map<String, dynamic>
            ? sess.studentId['profileImage'] ?? ''
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.profileImage != null)
                ? sess.studentId.profileImage
                : '';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
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
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                      child: profileImage.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            studentDetails,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Topic: ${sess.topic}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                if (sess.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Notes: "${sess.notes}"',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8), fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          mp.updateSessionStatus(sess.id, 'rejected');
                          _loadData();
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
                        onPressed: () => _showApproveDialog(sess.id, mp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept Connection'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedQueue(MentorshipProvider mp, ThemeData theme) {
    if (mp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final approved = mp.sessions.where((s) => s.status == 'approved' || s.status == 'completed').toList();

    if (approved.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No connections yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'When you accept connection requests, connected students will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approved.length,
      itemBuilder: (context, idx) {
        final sess = approved[idx];
        final studentName = sess.studentId is Map<String, dynamic>
            ? sess.studentId['name'] ?? 'Student'
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.name != null)
                ? sess.studentId.name
                : 'Student';
        final studentDetails = sess.studentId is Map<String, dynamic>
            ? '${sess.studentId['branch'] ?? ''} • Batch of ${sess.studentId['graduationYear'] ?? ''}'
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.branch != null)
                ? '${sess.studentId.branch} • Batch of ${sess.studentId.graduationYear}'
                : 'Pre-final Year';
        final profileImage = sess.studentId is Map<String, dynamic>
            ? sess.studentId['profileImage'] ?? ''
            : (sess.studentId is dynamic && sess.studentId != null && sess.studentId.profileImage != null)
                ? sess.studentId.profileImage
                : '';
        final studentIdVal = sess.studentId is Map<String, dynamic>
            ? sess.studentId['_id'] ?? sess.studentId['id'] ?? ''
            : (sess.studentId is dynamic && sess.studentId != null)
                ? sess.studentId.id
                : '';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          color: theme.colorScheme.surfaceContainerLow,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
              child: profileImage.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(
              studentName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentDetails, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                Text('Connected since: ${sess.date.day}/${sess.date.month}/${sess.date.year}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
              onPressed: () {
                if (studentIdVal.isNotEmpty) {
                  context.push('/chat/$studentIdVal');
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showApproveDialog(String sessionId, MentorshipProvider mp) {
    final notesController = TextEditingController(text: 'Approved connection request! Let\'s connect here.');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accept Connection Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a message or guidance note for the student:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              CustomTextField(
                controller: notesController,
                label: 'Introductory Message',
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
                  const SnackBar(content: Text('Connection request accepted!')),
                );
                _loadData();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }
}
