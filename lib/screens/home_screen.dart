import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/post.dart';
import '../models/reaction.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../utils/url_helper.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../screens/profile_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _totalPages = 0;
  String? _authToken;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthToken() async {
    _authToken = await _authService.getStoredToken();
    setState(() {
      _isAuthenticated = _authToken != null;
    });
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _posts = [];
      }
    });

    try {
      print('🔄 Loading posts: authenticated=$_isAuthenticated, page=$_currentPage, refresh=$refresh');
      
      // Use public feed with authentication for personalized content
      final response = await _postService.getPublicFeed(
        page: _currentPage,
        token: _authToken, // Send token if available
      );

      print('📥 Received ${response.content.length} posts');
      print('📊 Page info: current=${response.page.number}, total=${response.page.totalPages}, totalElements=${response.page.totalElements}');
      
      if (response.content.isEmpty) {
        print('⚠️ No posts in response!');
      } else {
        print('✅ Posts received:');
        for (var post in response.content) {
          print('  - Post ${post.id}: "${post.content.substring(0, post.content.length > 30 ? 30 : post.content.length)}..."');
        }
      }

      if (mounted) {
        setState(() {
          if (refresh) {
            _posts = response.content;
          } else {
            _posts = [..._posts, ...response.content];
          }
          _currentPage = response.page.number + 1;
          _totalPages = response.page.totalPages;
          _hasMore = _currentPage < _totalPages;
          _isLoading = false;
        });
        
        print('📱 UI updated: total posts in list = ${_posts.length}');
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải bài viết: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      if (_hasMore && !_isLoading) {
        _loadPosts();
      }
    }
  }

  Future<void> _handleLike(Post post, [String? reactionType]) async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isCurrentlyLiked = post.reactions.currentUserReacted;
    final currentReactionType = post.reactions.currentUserReactionType;

    bool success;
    if (isCurrentlyLiked && (reactionType == null || reactionType.toUpperCase() == (currentReactionType?.toUpperCase() ?? 'LIKE'))) {
      print('Gọi removeReaction cho postId: \\${post.id}');
      success = await _postService.removeReaction(_authToken!, post.id);
      if (success) {
        setState(() {
          post.reactions.currentUserReacted = false;
          post.reactions.currentUserReactionType = null;
          post.reactions.totalCount = (post.reactions.totalCount - 1).clamp(0, 999999);
        });
      }
    } else {
      final type = (reactionType ?? 'LIKE').toUpperCase();
      print('Gọi reactToPost cho postId: \\${post.id}, type: \\${type}');
      success = await _postService.reactToPost(_authToken!, post.id, type);
      if (success) {
        setState(() {
          post.reactions.currentUserReacted = true;
          post.reactions.currentUserReactionType = type;
          if (!isCurrentlyLiked) {
            post.reactions.totalCount++;
          }
        });
      }
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thực hiện thao tác. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleComment(Post post) async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CommentBottomSheet(post: post),
      ),
    );
  }

  Future<void> _handleShare(Post post) async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _postService.sharePost(_authToken!, post.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chia sẻ bài viết thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadPosts(refresh: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chia sẻ bài viết. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPostComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (authProvider.user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: authProvider.user!.id),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF6366F1),
                      backgroundImage: authProvider.user?.avatarUrl != null
                          ? NetworkImage(UrlHelper.fixImageUrl(authProvider.user!.avatarUrl))
                          : null,
                      child: authProvider.user?.avatarUrl == null
                          ? Text(
                              (authProvider.user?.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePostScreen(),
                          ),
                        );
                        
                        // Refresh feed if post was created
                        if (result == true) {
                          print('🔄 Refreshing feed after creating post...');
                          _loadPosts(refresh: true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          "Bạn đang nghĩ gì hôm nay?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Ảnh',
                    color: const Color(0xFF10B981),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadPosts(refresh: true);
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    color: const Color(0xFFEF4444),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadPosts(refresh: true);
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'Cảm xúc',
                    color: const Color(0xFFF59E0B),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePostScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadPosts(refresh: true);
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(innerBoxIsScrolled ? 1.0 : 0.95),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: innerBoxIsScrolled 
                    ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                    : ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ainnect',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tìm bạn bè, cộng đồng, bài viết...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF6366F1), size: 20),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadPosts(refresh: true);
                    }
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF6366F1), size: 20),
                  ),
                  onPressed: () {
                    // TODO: Implement messages
                  },
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF6366F1),
                          backgroundImage: authProvider.user?.avatarUrl != null
                              ? NetworkImage(UrlHelper.fixImageUrl(authProvider.user!.avatarUrl))
                              : null,
                          child: authProvider.user?.avatarUrl == null
                              ? Text(
                                  (authProvider.user?.displayName ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      onSelected: (value) async {
                        if (value == 'profile' && authProvider.user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(userId: authProvider.user!.id),
                            ),
                          );
                        } else if (value == 'logout') {
                          final success = await authProvider.logout();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã đăng xuất'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đăng xuất thất bại'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, color: Color(0xFF6366F1)),
                              const SizedBox(width: 12),
                              Text(
                                authProvider.user?.displayName ?? 'Người dùng',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_outlined, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => _loadPosts(refresh: true),
          color: const Color(0xFF6366F1),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Post Composer
              SliverToBoxAdapter(
                child: _buildPostComposer(),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              
              // Posts List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _posts.length) {
                      final post = _posts[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PostCard(
                            post: post,
                            isLiked: post.reactions.currentUserReacted,
                            onLike: ([type]) => _handleLike(post, type),
                            onComment: () => _handleComment(post),
                            onShare: () => _handleShare(post),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  childCount: _posts.length,
                ),
              ),
              
              // Loading Indicator
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ),
              
              // End of List Message
              if (!_hasMore && _posts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bạn đã xem hết tất cả bài viết',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
