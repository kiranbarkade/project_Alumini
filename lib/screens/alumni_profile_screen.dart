import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/alumni_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/referral_provider.dart';
import '../providers/mentorship_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'package:go_router/go_router.dart';

class AlumniProfileScreen extends StatefulWidget {
  final String userId;

  const AlumniProfileScreen({super.key, required this.userId});

  @override
  State<AlumniProfileScreen> createState() => _AlumniProfileScreenState();
}

class _AlumniProfileScreenState extends State<AlumniProfileScreen> {
  bool _isImageUploading = false;

  Future<void> _pickAndUploadImage(AuthProvider auth) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isImageUploading = true;
      });

      final bytes = await image.readAsBytes();
      final String base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final success = await auth.uploadProfileImage(base64Image);

      if (success && mounted) {
        await Provider.of<AlumniProvider>(context, listen: false).fetchAlumnusById(widget.userId);
      }

      setState(() {
        _isImageUploading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.error ?? 'Failed to upload profile image')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isImageUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error choosing/uploading image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlumniProvider>(context, listen: false).fetchAlumnusById(widget.userId);
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (currentUser != null) {
        Provider.of<MentorshipProvider>(context, listen: false).fetchSessions(studentId: currentUser.id);
      }
    });
  }

  @override
  void dispose() {
    // Avoid stale selections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AlumniProvider>(context, listen: false).clearSelectedAlumnus();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alumniProvider = Provider.of<AlumniProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final mp = Provider.of<MentorshipProvider>(context);
    final theme = Theme.of(context);
    
    final alumnus = alumniProvider.selectedAlumnus;
    final currentUser = authProvider.currentUser;

    // Determine connection status
    String connectionStatus = 'none'; // 'none', 'pending', 'connected'
    if (currentUser != null && alumnus != null) {
      final sessions = mp.sessions.where((s) {
        final studentIdVal = s.studentId is Map<String, dynamic>
            ? s.studentId['_id'] ?? s.studentId['id'] ?? ''
            : s.studentId.toString();
        final alumniIdVal = s.alumniId is Map<String, dynamic>
            ? s.alumniId['_id'] ?? s.alumniId['id'] ?? ''
            : s.alumniId.toString();
        return studentIdVal == currentUser.id && alumniIdVal == alumnus.id;
      }).toList();

      if (sessions.any((s) => s.status == 'approved' || s.status == 'completed')) {
        connectionStatus = 'connected';
      } else if (sessions.any((s) => s.status == 'pending')) {
        connectionStatus = 'pending';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(alumnus?.name ?? 'Alumni Profile'),
        actions: [
          if (currentUser != null && currentUser.id == alumnus?.id)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditAlumniProfileDialog(alumnus, authProvider),
            ),
        ],
      ),
      body: alumniProvider.isLoading
          ? LoadingShimmer.profileShimmer()
          : alumniProvider.error != null
              ? Center(child: Text('Error: ${alumniProvider.error}'))
              : alumnus == null
                  ? const Center(child: Text('Alumnus profile not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Card
                          _buildHeaderCard(alumnus, theme, authProvider),
                          const SizedBox(height: 24),

                          // 2. Action Buttons (Only visible to student role)
                          if (currentUser != null && currentUser.role == 'student') ...[
                            Row(
                              children: [
                                if (connectionStatus == 'none') ...[
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Connect',
                                      icon: Icons.person_add,
                                      onPressed: () => _sendConnectionRequest(alumnus, currentUser.id),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Referral',
                                      isSecondary: true,
                                      icon: Icons.shortcut,
                                      onPressed: () => _showReferralModal(alumnus, currentUser.id, theme),
                                    ),
                                  ),
                                ] else if (connectionStatus == 'pending') ...[
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Pending Request',
                                      icon: Icons.hourglass_top,
                                      onPressed: null,
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Connected',
                                      icon: Icons.check,
                                      onPressed: null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Message',
                                      icon: Icons.message,
                                      isSecondary: true,
                                      onPressed: () {
                                        if (alumnus != null) {
                                          context.push('/chat/${alumnus.id}');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 3. About
                          const Text(
                            'About Me',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            alumnus.about.isNotEmpty
                                ? alumnus.about
                                : 'No description provided.',
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // 4. Skills
                          const Text(
                            'Skills',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          alumnus.skills.isEmpty
                              ? const Text('No skills listed.')
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: alumnus.skills
                                      .map((s) => Chip(
                                            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                            side: BorderSide.none,
                                            label: Text(
                                              s,
                                              style: TextStyle(
                                                color: theme.colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                          const SizedBox(height: 24),

                          // 5. Bio and Background
                          const Text(
                            'Education & Batch',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.school, color: theme.colorScheme.primary),
                            title: Text(alumnus.college),
                            subtitle: Text('Graduation Year: ${alumnus.graduationYear} • ${alumnus.branch}'),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeaderCard(dynamic alum, ThemeData theme, AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    final isOwnProfile = currentUser != null && currentUser.id == alum.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: alum.profileImage.isNotEmpty
                    ? NetworkImage(alum.profileImage)
                    : null,
                child: alum.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 45)
                    : null,
              ),
              if (isOwnProfile)
                if (_isImageUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _pickAndUploadImage(authProvider),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                alum.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (alum.isVerified == true) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${alum.designation} at ${alum.company}',
            style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (alum.linkedinUrl.isNotEmpty)
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening LinkedIn Profile: ${alum.linkedinUrl}')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0A66C2).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, color: Color(0xFF0A66C2), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'LinkedIn Profile',
                      style: TextStyle(
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showReferralModal(dynamic alumni, String studentId, ThemeData theme) {
    final jobs = Provider.of<JobProvider>(context, listen: false)
        .jobs
        .where((j) => j.type == 'referral' || j.postedBy is String 
            ? j.postedBy == alumni.id 
            : (j.postedBy?.id == alumni.id))
        .toList();

    final messageController = TextEditingController();
    String? selectedJobId = jobs.isNotEmpty ? jobs.first.id : null;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Referral',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (jobs.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Note: This alumnus has not posted specific job openings. You are requesting a general company referral.',
                        style: TextStyle(fontSize: 12, color: Colors.brown),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    const Text('Select Job Listing:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedJobId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: jobs
                          .map((j) => DropdownMenuItem(
                                value: j.id,
                                child: Text('${j.title} (${j.company})'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedJobId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomTextField(
                    controller: messageController,
                    label: 'Pitch Message',
                    hint: 'Why are you qualified? Highlight relevant skills and projects.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Consumer<ReferralProvider>(
                    builder: (context, rp, _) {
                      return CustomButton(
                        text: 'Send Request',
                        isLoading: rp.isLoading,
                        onPressed: () async {
                          if (messageController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please write a message')),
                            );
                            return;
                          }
                          
                          // If there's no job posted, we use a general placeholder jobId or query all jobs
                          final allJobs = Provider.of<JobProvider>(context, listen: false).jobs;
                          final jobId = selectedJobId ?? (allJobs.isNotEmpty ? allJobs.first.id : '');

                          final success = await rp.sendReferralRequest({
                            'studentId': studentId,
                            'alumniId': alumni.id,
                            'jobId': jobId,
                            'message': messageController.text.trim(),
                          });

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Referral request sent to ${alumni.name}!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(rp.error ?? 'Failed to send request')),
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
      },
    );
  }

  void _showMentorshipModal(dynamic alumni, String studentId, ThemeData theme) {
    final topicController = TextEditingController(text: 'Resume Review and Off-Campus Strategies');
    final timeController = TextEditingController(text: '7:00 PM - 7:30 PM');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Mentorship Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: topicController,
                    label: 'Session Topic',
                    hint: 'e.g., Mock interview, Career path coaching',
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: timeController,
                    label: 'Preferred Time Slot',
                    hint: 'e.g., 6:00 PM - 6:45 PM',
                  ),
                  const SizedBox(height: 24),
                  Consumer<MentorshipProvider>(
                    builder: (context, mp, _) {
                      return CustomButton(
                        text: 'Book Session',
                        isLoading: mp.isLoading,
                        onPressed: () async {
                          if (topicController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a topic')),
                            );
                            return;
                          }

                          final success = await mp.requestSession({
                            'studentId': studentId,
                            'alumniId': alumni.id,
                            'topic': topicController.text.trim(),
                            'date': selectedDate.toIso8601String(),
                            'timeSlot': timeController.text.trim(),
                          });

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Mentorship request booked with ${alumni.name}!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mp.error ?? 'Failed to book session')),
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
      },
    );
  }

  void _showEditAlumniProfileDialog(dynamic alumnus, AuthProvider auth) {
    final aboutController = TextEditingController(text: alumnus.about);
    final skillsController = TextEditingController(text: (alumnus.skills as List<String>).join(', '));
    final resumeController = TextEditingController(text: alumnus.resumeUrl);
    final branchController = TextEditingController(text: alumnus.branch);
    final gradYearController = TextEditingController(text: alumnus.graduationYear.toString());
    final linkedinController = TextEditingController(text: alumnus.linkedinUrl);
    final companyController = TextEditingController(text: alumnus.company);
    final designationController = TextEditingController(text: alumnus.designation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Alumni Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: companyController,
                  label: 'Company',
                  hint: 'Enter current company',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: designationController,
                  label: 'Designation',
                  hint: 'Enter your role',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: branchController,
                  label: 'Engineering Branch',
                  hint: 'e.g. Computer Engineering',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: gradYearController,
                  label: 'Graduation Year',
                  hint: 'e.g. 2024',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: linkedinController,
                  label: 'LinkedIn URL',
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
                  'company': companyController.text.trim(),
                  'designation': designationController.text.trim(),
                  'about': aboutController.text.trim(),
                  'skills': skillsList,
                  'resumeUrl': resumeController.text.trim(),
                  'branch': branchController.text.trim(),
                  'graduationYear': int.tryParse(gradYearController.text.trim()) ?? 0,
                  'linkedinUrl': linkedinController.text.trim(),
                });
                if (mounted) {
                  Navigator.pop(context);
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

  Future<void> _sendConnectionRequest(dynamic alumnus, String studentId) async {
    final mp = Provider.of<MentorshipProvider>(context, listen: false);
    final success = await mp.requestSession({
      'studentId': studentId,
      'alumniId': alumnus.id,
      'topic': 'Connection Request',
      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'timeSlot': 'Anytime',
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection request sent to ${alumnus.name}!')),
        );
        // Refresh sessions list
        mp.fetchSessions(studentId: studentId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mp.error ?? 'Failed to send request')),
        );
      }
    }
  }
}
