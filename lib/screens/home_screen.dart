import 'package:flutter/material.dart';
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
      final response = _isAuthenticated
          ? await _postService.getUserFeed(_authToken!, page: _currentPage)
          : await _postService.getPublicFeed(page: _currentPage);

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
      }
    } catch (e) {
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

  Future<void> _handleLike(Post post) async {
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
    if (isCurrentlyLiked) {
      success = await _postService.removeReaction(_authToken!, post.id);
    } else {
      success = await _postService.reactToPost(_authToken!, post.id, 'like');
    }

    if (success) {
      await _loadPosts(refresh: true);
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'ainnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF1877F2),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            onPressed: () {
              // TODO: Implement messages
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon:                 GestureDetector(
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
                    radius: 16,
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
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Text(authProvider.user?.displayName ?? 'Người dùng'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
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
                            radius: 20,
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
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F2F5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text(
                              "Bạn đang nghĩ gì?",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _posts.length) {
                    final post = _posts[index];
                    return Column(
                      children: [
                        PostCard(
                          post: post,
                          isLiked: post.reactions.currentUserReacted,
                          onLike: () => _handleLike(post),
                          onComment: () => _handleComment(post),
                          onShare: () => _handleShare(post),
                        ),
                        if (index == _posts.length - 1 && _isLoading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (index == _posts.length - 1 && !_hasMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'Không còn bài viết nào để tải',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
                childCount: _posts.length + (_isLoading || !_hasMore ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
