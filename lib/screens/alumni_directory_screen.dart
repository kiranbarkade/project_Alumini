import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/alumni_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/custom_textfield.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSkill = '';
  String _selectedCompany = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlumniProvider>(context, listen: false).fetchAlumni();
    });
  }

  void _onSearch() {
    Provider.of<AlumniProvider>(context, listen: false).fetchAlumni(
      search: _searchController.text,
      skills: _selectedSkill,
      company: _selectedCompany,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedSkill = '';
      _selectedCompany = '';
    });
    Provider.of<AlumniProvider>(context, listen: false).fetchAlumni();
  }

  @override
  Widget build(BuildContext context) {
    final alumniProvider = Provider.of<AlumniProvider>(context);
    final theme = Theme.of(context);

    // Dynamic extraction of skills and companies to populate filter dropdowns
    final allSkills = <String>{};
    final allCompanies = <String>{};
    for (var a in alumniProvider.alumni) {
      if (a.company.isNotEmpty) allCompanies.add(a.company);
      for (var s in a.skills) {
        if (s.isNotEmpty) allSkills.add(s);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alumni Registry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _onSearch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search by name, company...',
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
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showFilterSheet(allSkills.toList(), allCompanies.toList(), theme),
                ),
              ],
            ),
          ),

          // 2. Active filters display
          if (_selectedSkill.isNotEmpty || _selectedCompany.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'Active Filters: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (_selectedSkill.isNotEmpty)
                          Chip(
                            label: Text(_selectedSkill),
                            onDeleted: () {
                              setState(() => _selectedSkill = '');
                              _onSearch();
                            },
                          ),
                        if (_selectedCompany.isNotEmpty)
                          Chip(
                            label: Text(_selectedCompany),
                            onDeleted: () {
                              setState(() => _selectedCompany = '');
                              _onSearch();
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // 3. Alumni Registry List
          Expanded(
            child: alumniProvider.isLoading
                ? LoadingShimmer.cardList()
                : alumniProvider.error != null
                    ? EmptyStateView(
                        icon: Icons.error_outline,
                        title: 'Error loading directory',
                        description: alumniProvider.error!,
                        actionText: 'Retry',
                        onActionPressed: () => _onSearch(),
                      )
                    : alumniProvider.alumni.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.search_off,
                            title: 'No Alumni Found',
                            description: 'Try adjusting your search criteria or filters.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: alumniProvider.alumni.length,
                            itemBuilder: (context, index) {
                              final alum = alumniProvider.alumni[index];
                              return _buildAlumniCard(alum, theme);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniCard(dynamic alum, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/alumni/${alum.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: alum.profileImage.isNotEmpty
                    ? NetworkImage(alum.profileImage)
                    : null,
                child: alum.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alum.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alum.designation} at ${alum.company}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Batch: ${alum.graduationYear} • ${alum.branch}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    if (alum.skills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (alum.skills as List<String>)
                            .take(3)
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(List<String> skills, List<String> companies, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Alumni',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Skill Filter Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Skill',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSkill.isEmpty ? null : _selectedSkill,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Skills')),
                  ...skills.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (val) {
                  setState(() => _selectedSkill = val ?? '');
                },
              ),
              const SizedBox(height: 16),
              // Company Filter Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Company',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCompany.isEmpty ? null : _selectedCompany,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Companies')),
                  ...companies.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (val) {
                  setState(() => _selectedCompany = val ?? '');
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
  }
}
