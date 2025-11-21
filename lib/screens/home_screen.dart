import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../utils/url_helper.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../screens/profile_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showGuestBanner;

  const HomeScreen({
    super.key,
    this.showGuestBanner = false,
  });

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
      
      final response = await _postService.getPublicFeed(
        page: _currentPage,
        token: _authToken, 
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

  bool get _shouldShowGuestBanner => widget.showGuestBanner && !_isAuthenticated;

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushNamed(context, '/login');
  }

  void _navigateToRegister() {
    if (!mounted) return;
    Navigator.pushNamed(context, '/register');
  }

  Future<void> _openCreatePost() async {
    if (!_isAuthenticated) {
      _showAuthRequiredSheet();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(),
      ),
    );

    if (result == true && mounted) {
      _loadPosts(refresh: true);
    }
  }

  void _showAuthRequiredSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bạn cần đăng nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Đăng nhập hoặc tạo tài khoản để đăng bài, tương tác và tham gia cộng đồng Ainnect.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _navigateToLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _navigateToRegister();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng đến Ainnect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cùng chia sẽ câu chuyện thường ngày của bạn.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E88E5),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _navigateToRegister,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    if (!_isAuthenticated) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chia sẻ câu chuyện của bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để tạo bài viết, bình luận và tương tác cùng cộng đồng.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _navigateToRegister,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

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
              Builder(
                builder: (context) {
                  final avatarUrl = UrlHelper.fixImageUrl(authProvider.user?.avatarUrl);
                  return Row(
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
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
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
                          onTap: () => _openCreatePost(),
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
                  );
                },
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
                    onTap: () => _openCreatePost(),
                  ),
                  _buildActionButton(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    color: const Color(0xFFEF4444),
                    onTap: () => _openCreatePost(),
                  ),
                  _buildActionButton(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'Cảm xúc',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _openCreatePost(),
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
                if (_isAuthenticated) ...[
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF6366F1), size: 20),
                    ),
                    onPressed: () => _openCreatePost(),
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
                          child: Builder(
                            builder: (context) {
                              final avatarUrl = UrlHelper.fixImageUrl(authProvider.user?.avatarUrl);
                              return CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF6366F1),
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null
                                    ? Text(
                                        (authProvider.user?.displayName ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              );
                            },
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
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                        itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
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
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout_outlined, color: Colors.red),
                                const SizedBox(width: 12),
                                const Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                        },
                      );
                    },
                  ),
                ],
                if (!_isAuthenticated) ...[
                  TextButton(
                    onPressed: _navigateToLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _navigateToRegister,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
              if (_shouldShowGuestBanner)
                SliverToBoxAdapter(
                  child: _buildGuestBanner(),
                ),
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
