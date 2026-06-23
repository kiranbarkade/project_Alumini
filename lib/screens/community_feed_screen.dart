import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/referral_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  String _selectedCategoryFilter = 'All';
  final List<String> _selectedTags = [];
  bool _showCompanyInput = false;

  final List<String> _availableTags = [
    '#Job',
    '#Referral',
    '#Internship',
    '#Placement',
    '#Event'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).fetchPosts();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _submitPost(String userId) async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    final company = _companyController.text.trim();

    await Provider.of<FeedProvider>(context, listen: false).createPost(
      userId, 
      text,
      tags: List<String>.from(_selectedTags),
      company: company,
    );

    _postController.clear();
    _companyController.clear();
    setState(() {
      _selectedTags.clear();
      _showCompanyInput = false;
    });

    FocusScope.of(context).unfocus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final theme = Theme.of(context);

    final showCreatePost = currentUser != null;

    // Local filtering by category
    var posts = feedProvider.posts;
    if (_selectedCategoryFilter != 'All') {
      String tagToFilter = '';
      if (_selectedCategoryFilter == 'Jobs') tagToFilter = '#Job';
      if (_selectedCategoryFilter == 'Referrals') tagToFilter = '#Referral';
      if (_selectedCategoryFilter == 'Internships') tagToFilter = '#Internship';
      if (_selectedCategoryFilter == 'Events') tagToFilter = '#Event';
      if (_selectedCategoryFilter == 'Placements') tagToFilter = '#Placement';

      posts = feedProvider.posts.where((p) => p.tags.contains(tagToFilter)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => feedProvider.fetchPosts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Post Creator Panel
          if (showCreatePost) ...[
            _buildPostCreator(currentUser, theme),
            const Divider(height: 1),
          ],

          // 2. Category Filter chips
          _buildCategoryFilterRow(theme),
          const Divider(height: 1),

          // 3. Timeline Feed
          Expanded(
            child: feedProvider.isLoading && feedProvider.posts.isEmpty
                ? LoadingShimmer.cardList()
                : feedProvider.error != null
                    ? EmptyStateView(
                        icon: Icons.error_outline,
                        title: 'Error loading feed',
                        description: feedProvider.error!,
                        actionText: 'Retry',
                        onActionPressed: () => feedProvider.fetchPosts(),
                      )
                    : posts.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.dynamic_feed,
                            title: 'No Updates Found',
                            description: 'Try choosing another filter or write the first post!',
                          )
                        : RefreshIndicator(
                            onRefresh: () => feedProvider.fetchPosts(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return _buildPostCard(post, currentUser?.id ?? '', theme);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterRow(ThemeData theme) {
    final categories = ['All', 'Jobs', 'Referrals', 'Internships', 'Events', 'Placements'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategoryFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
              onSelected: (val) {
                setState(() {
                  _selectedCategoryFilter = cat;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCreator(dynamic user, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user.profileImage.isNotEmpty
                ? NetworkImage(user.profileImage)
                : null,
            child: user.profileImage.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _postController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: user.role == 'student' 
                        ? 'Ask a question or seek career advice...' 
                        : 'Share an update, referral opportunity, or advice...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 8),

                // Tags selection list
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedTags.add(tag);
                            if (tag == '#Referral' || tag == '#Job') {
                              _showCompanyInput = true;
                            }
                          } else {
                            _selectedTags.remove(tag);
                            if (!_selectedTags.contains('#Referral') && !_selectedTags.contains('#Job')) {
                              _showCompanyInput = false;
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                if (_showCompanyInput) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      hintText: 'Company Name (e.g. Google, Tesla)',
                      hintStyle: TextStyle(fontSize: 12),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.send, size: 16),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () => _submitPost(user.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post, String currentUserId, ThemeData theme) {
    final author = post.userId;
    final isLiked = post.likes.contains(currentUserId);
    
    final authorName = author is dynamic && author.name != null ? author.name : 'Alumni Member';
    final authorRole = author is dynamic && author.role != null ? author.role.toString().toUpperCase() : 'USER';
    final authorCompany = author is dynamic && author.company != null && author.company.isNotEmpty 
        ? ' (${author.company})' 
        : '';
    final authorImage = author is dynamic && author.profileImage != null ? author.profileImage : '';
    final isVerified = author is dynamic && author.isVerified == true;

    final hasReferralTag = post.tags.contains('#Referral');
    final isAuthorAlumni = author is dynamic && author.role == 'alumni';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            // Header Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: authorImage.isNotEmpty ? NetworkImage(authorImage) : null,
                  child: authorImage.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '$authorRole$authorCompany',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category tags / Company Logo row
            if (post.tags.isNotEmpty || post.company.isNotEmpty) ...[
              Row(
                children: [
                  if (post.company.isNotEmpty) ...[
                    _buildCompanyLogo(post.company, theme),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (post.tags as List<dynamic>).map<Widget>((tag) {
                        Color tagColor;
                        switch (tag.toString()) {
                          case '#Referral':
                            tagColor = Colors.green;
                            break;
                          case '#Job':
                            tagColor = Colors.blue;
                            break;
                          case '#Internship':
                            tagColor = Colors.orange;
                            break;
                          case '#Placement':
                            tagColor = Colors.purple;
                            break;
                          default:
                            tagColor = Colors.grey;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: tagColor.withOpacity(0.3), width: 0.5),
                          ),
                          child: Text(
                            tag.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Post Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (post.image.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],

            // Request Referral Action Box (if applicable)
            if (hasReferralTag && isAuthorAlumni && author.id != currentUserId) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need a referral at ${post.company.isNotEmpty ? post.company : "their company"}?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Apply directly using your profile details.',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showPostReferralModal(post, currentUserId, theme),
                      child: const Text('Apply Now'),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Interactions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                        size: 20,
                      ),
                      onPressed: () {
                        Provider.of<FeedProvider>(context, listen: false).toggleLike(post.id, currentUserId);
                      },
                    ),
                    Text(
                      '${post.likes.length}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: Text('${post.comments.length} Comments'),
                  onPressed: () => _showCommentsSheet(post, currentUserId, theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String companyName, ThemeData theme) {
    final cleanName = companyName.toLowerCase().replaceAll(' ', '');
    final logoUrl = 'https://logo.clearbit.com/$cleanName.com';

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        logoUrl,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Colored circle fallback
          final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}';
  }

  void _showPostReferralModal(dynamic post, String studentId, ThemeData theme) {
    final messageController = TextEditingController();

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Request Referral from ${post.userId.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position details: Referral request for ${post.company}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: messageController,
                    label: 'Pitch Message',
                    hint: 'Explain briefly why you are a good fit for this role.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  Consumer<ReferralProvider>(
                    builder: (context, rp, _) {
                      return CustomButton(
                        text: 'Send Referral Application',
                        isLoading: rp.isLoading,
                        onPressed: () async {
                          if (messageController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a message explaining your background.')),
                            );
                            return;
                          }

                          final success = await rp.sendReferralRequest({
                            'studentId': studentId,
                            'alumniId': post.userId.id,
                            'companyName': post.company,
                            'jobTitle': 'Referral Candidate',
                            'message': messageController.text.trim(),
                          });

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Referral application sent to ${post.userId.name}!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(rp.error ?? 'Failed to apply')),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCommentsSheet(dynamic post, String currentUserId, ThemeData theme) {
    final commentController = TextEditingController();

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discussion Comments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${post.comments.length}',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Comment list
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: post.comments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No comments yet. Start the conversation!'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: post.comments.length,
                            itemBuilder: (context, idx) {
                              final comment = post.comments[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: comment.userImage.isNotEmpty ? NetworkImage(comment.userImage) : null,
                                      child: comment.userImage.isEmpty ? const Icon(Icons.person, size: 14) : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.userName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.content,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Write Comment box
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.send, size: 18),
                          onPressed: () async {
                            final text = commentController.text.trim();
                            if (text.isEmpty) return;

                            await Provider.of<FeedProvider>(context, listen: false)
                                .addComment(post.id, currentUserId, text);

                            // Refresh local modal list view
                            commentController.clear();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment published')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
