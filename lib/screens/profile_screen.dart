import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../models/post.dart';
import '../models/messaging_models.dart';
import '../providers/auth_provider.dart';
import '../providers/friendship_provider.dart';
import '../providers/messaging_provider.dart';
import '../services/profile_service.dart';
import '../services/search_service.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/bottom_nav_bar.dart';
import 'friends_list_screen.dart';
import 'qr_scanner_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final SearchService _searchService = SearchService();
  final ScrollController _scrollController = ScrollController();

  Profile? _profile;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  bool _isCurrentUser = false;
  int _friendsCount = 0;

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
    final accessToken = await authProvider.token;

    if (accessToken == null) {
      return;
    }

    try {
      final friendsData = await _searchService.fetchFriends(
        widget.userId.toString(),
        token: accessToken,
        size: 1, // Chỉ cần lấy metadata để biết số lượng
      );

      if (friendsData['result'] == 'SUCCESS' && 
          friendsData['data'] != null && 
          mounted) {
        setState(() {
          _friendsCount = friendsData['data']['totalElements'] ?? 0;
        });
      }
    } catch (e) {
      // Ignore error, just don't show friends count
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

  Future<void> _handleAddFriend() async {
    final friendshipProvider = context.read<FriendshipProvider>();
    final success = await friendshipProvider.sendFriendRequest(widget.userId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lời mời kết bạn'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendshipProvider.error ?? 'Không thể gửi lời mời kết bạn'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleFollow() {
    // TODO: Implement follow
  }

  Future<void> _handleMessage() async {
    // Navigate to chat screen - create or get conversation
    final messagingProvider = context.read<MessagingProvider>();
    
    try {
      // Try to find existing conversation or create new one
      final conversation = await messagingProvider.createConversation(
        CreateConversationRequest(
          type: ConversationType.direct,
          participantIds: [widget.userId],
        ),
      );
      
      if (mounted) {
        // Import ChatScreen at the top of the file
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 0,
              title: Text(_profile!.displayName),
              actions: _isCurrentUser
                  ? [
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Đăng nhập QR',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QrScannerScreen(),
                            ),
                          );
                        },
                      ),
                    ]
                  : null,
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

                        // Friends Section
                        if (_friendsCount > 0)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsListScreen(
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.people,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Bạn bè',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_friendsCount bạn bè',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),

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
    );
  }
}