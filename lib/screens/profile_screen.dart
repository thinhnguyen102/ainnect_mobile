import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ScrollController _scrollController = ScrollController();

  Profile? _profile;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFriends();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      final currentUser = context.read<AuthProvider>().user;
      _isCurrentUser = currentUser?.id == widget.userId;

      debugPrint('Loading profile for userId: ${widget.userId}');
      final authProvider = context.read<AuthProvider>();
      final accessToken = await authProvider.getAccessToken();
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đăng nhập để xem thông tin'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final profile = await _profileService.getProfile(accessToken, widget.userId);
      
      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin người dùng'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _profile = profile;
        _isLoading = false;
        _hasMore = profile.posts.hasNext;
        _currentPage = profile.posts.currentPage;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final accessToken = await authProvider.getAccessToken();
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đăng nhập để xem bài viết'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final postsResponse = await _profileService.getUserPosts(
        accessToken,
        widget.userId,
        page: _currentPage + 1,
      );

      if (postsResponse != null && mounted) {
        setState(() {
          _profile = _profile?.copyWith(
            posts: PostsResponse(
              posts: [..._profile!.posts.posts, ...postsResponse.posts],
              currentPage: postsResponse.currentPage,
              pageSize: postsResponse.pageSize,
              totalElements: postsResponse.totalElements,
              totalPages: postsResponse.totalPages,
              hasNext: postsResponse.hasNext,
              hasPrevious: postsResponse.hasPrevious,
            ),
          );
          _currentPage = postsResponse.currentPage;
          _hasMore = postsResponse.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải thêm bài viết: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFriends() async {
    final authProvider = context.read<AuthProvider>();
    final accessToken = await authProvider.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để xem danh sách bạn bè'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final friendsData = await _profileService.fetchFriends(widget.userId.toString(), token: accessToken);

    if (friendsData.isNotEmpty && mounted) {
      setState(() {
        // Assuming friendsData['data']['friendships'] contains a list of relationships
        final friendships = (friendsData['data']['friendships'] as List<dynamic>)
            .map((friend) => Relationship.fromJson(friend as Map<String, dynamic>))
            .toList();

        // Update the profile's relationship data if needed
        _profile = _profile?.copyWith(
          relationship: friendships.isNotEmpty ? friendships.first : _profile?.relationship,
        );
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _loadMorePosts();
      }
    }
  }

  void _handleEditProfile() {
    // TODO: Navigate to edit profile screen
  }

  void _handleAddFriend() {
    // TODO: Implement add friend
  }

  void _handleFollow() {
    // TODO: Implement follow
  }

  void _handleMessage() {
    // TODO: Navigate to chat screen
  }

  void _handleEditCover() {
    // TODO: Implement edit cover photo
  }

  void _handleEditAvatar() {
    // TODO: Implement edit avatar
  }

  void _handleEditEducation() {
    // TODO: Navigate to edit education screen
  }

  void _handleEditWork() {
    // TODO: Navigate to edit work experience screen
  }

  void _handleEditLocation() {
    // TODO: Navigate to edit location screen
  }

  void _handleEditInterest() {
    // TODO: Navigate to edit interests screen
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.logout();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất thành công'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to login screen and clear navigation stack
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng xuất thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 0,
              title: Text(_profile!.displayName),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header with Cover and Avatar
                  ProfileHeader(
                    profile: _profile!,
                    isCurrentUser: _isCurrentUser,
                    onEditCover: _handleEditCover,
                    onEditAvatar: _handleEditAvatar,
                  ),

                  // Profile Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Bio
                        Text(
                          _profile!.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        ProfileActionButton(
                          profile: _profile!,
                          isCurrentUser: _isCurrentUser,
                          onEdit: _handleEditProfile,
                          onAddFriend: _handleAddFriend,
                          onFollow: _handleFollow,
                          onMessage: _handleMessage,
                          onLogout: _handleLogout,
                        ),

                        const SizedBox(height: 16),

                        // Profile Info Sections
                        ProfileInfoSection(
                          profile: _profile!,
                          isCurrentUser: _isCurrentUser,
                          onEditEducation: _handleEditEducation,
                          onEditWork: _handleEditWork,
                          onEditLocation: _handleEditLocation,
                          onEditInterest: _handleEditInterest,
                        ),

                        // Posts Header
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Bài viết',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _profile!.posts.posts.length) {
                    final post = _profile!.posts.posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PostCard(
                        post: Post(
                          id: post.id,
                          authorId: _profile!.userId,
                          authorUsername: _profile!.username,
                          authorDisplayName: _profile!.displayName,
                          authorAvatarUrl: _profile!.avatarUrl,
                          content: post.content,
                          visibility: 'public_',
                          commentCount: post.commentsCount,
                          reactionCount: post.likesCount,
                          shareCount: post.sharesCount,
                          reactions: PostReactions(
                            totalCount: post.likesCount,
                            reactionCounts: [],
                            recentReactions: [],
                            currentUserReacted: post.liked,
                            currentUserReactionType: post.liked ? 'like' : null,
                          ),
                          media: post.media,
                          createdAt: post.createdAt,
                          updatedAt: post.createdAt,
                        ),
                        isLiked: post.liked,
                        onLike: ([type]) {}, // TODO: Implement like
                        onComment: () {}, // TODO: Implement comment
                        onShare: () {}, // TODO: Implement share
                      ),
                    );
                  }
                  if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!_hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Không còn bài viết nào để tải',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                childCount: _profile!.posts.posts.length + (_isLoading || !_hasMore ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}