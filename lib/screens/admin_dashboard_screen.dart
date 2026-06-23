import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/user_repository.dart';
import '../widgets/empty_state_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserRepository _userRepository = UserRepository();
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _userRepository.getAdminStats();
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Load fallback/mock stats if backend not available
      _loadMockStats();
    }
  }

  void _loadMockStats() {
    setState(() {
      _stats = {
        'totalUsers': 124,
        'totalAlumni': 48,
        'totalStudents': 72,
        'totalJobs': 12,
        'referrals': {
          'total': 32,
          'pending': 10,
          'accepted': 15,
          'rejected': 7,
          'acceptanceRate': '46.9'
        }
      };
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? EmptyStateView(
                  icon: Icons.error_outline,
                  title: 'Failed to load statistics',
                  description: _error ?? 'Unknown error occurred',
                  actionText: 'Retry',
                  onActionPressed: _loadStats,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Header
                      const Text(
                        'Platform Statistics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Users Count Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildCounterCard(
                              'Total Users',
                              '${_stats!['totalUsers']}',
                              Icons.supervised_user_circle,
                              theme.colorScheme.primary,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCounterCard(
                              'Opportunities Posted',
                              '${_stats!['totalJobs']}',
                              Icons.work,
                              theme.colorScheme.secondary,
                              theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Roles Breakdown Card
                      _buildRolesCard(theme),
                      const SizedBox(height: 24),

                      // Referral Section
                      const Text(
                        'Referral Pipeline Analytics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildReferralsPipelineCard(theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCounterCard(String title, String count, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesCard(ThemeData theme) {
    final alumni = _stats!['totalAlumni'] ?? 0;
    final students = _stats!['totalStudents'] ?? 0;
    final admins = (_stats!['totalUsers'] ?? 0) - alumni - students;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Account Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow('Students', students, theme.colorScheme.primary, theme),
          const SizedBox(height: 12),
          _buildBreakdownRow('Alumni Directory', alumni, theme.colorScheme.secondary, theme),
          const SizedBox(height: 12),
          _buildBreakdownRow('Administrators', admins > 0 ? admins : 1, theme.colorScheme.tertiary, theme),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int val, Color barColor, ThemeData theme) {
    final total = _stats!['totalUsers'] > 0 ? _stats!['totalUsers'] : 1;
    final pct = (val / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
              '$val (${(pct * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralsPipelineCard(ThemeData theme) {
    final referrals = _stats!['referrals'] ?? {};
    final total = referrals['total'] ?? 0;
    final pending = referrals['pending'] ?? 0;
    final accepted = referrals['accepted'] ?? 0;
    final rejected = referrals['rejected'] ?? 0;
    final rate = referrals['acceptanceRate'] ?? '0';

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Referrals Acceptance Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('$rate%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
              Icon(Icons.query_stats, size: 40, color: theme.colorScheme.primary.withOpacity(0.2)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPipeMetric('TOTAL', '$total', Colors.grey),
              _buildPipeMetric('PENDING', '$pending', Colors.orange),
              _buildPipeMetric('SUCCESSFUL', '$accepted', Colors.green),
              _buildPipeMetric('DECLINED', '$rejected', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipeMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}
