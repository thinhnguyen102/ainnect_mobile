import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/search_service.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> with SingleTickerProviderStateMixin {
  final SearchService _searchService = SearchService();
  late TabController _tabController;
  
  Map<String, dynamic>? _receivedRequests;
  Map<String, dynamic>? _sentRequests;
  bool _isLoadingReceived = true;
  bool _isLoadingSent = true;
  int _receivedPage = 0;
  int _sentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReceivedRequests();
    _loadSentRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReceivedRequests() async {
    setState(() => _isLoadingReceived = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      if (token != null) {
        final data = await _searchService.fetchFriendRequests(page: _receivedPage, size: _pageSize, token: token);
        setState(() {
          _receivedRequests = data;
          _isLoadingReceived = false;
        });
      }
    } catch (e) {
      print('Error loading received requests: $e');
      setState(() => _isLoadingReceived = false);
    }
  }

  Future<void> _loadSentRequests() async {
    setState(() => _isLoadingSent = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      if (token != null) {
        final data = await _searchService.fetchSentFriendRequests(page: _sentPage, size: _pageSize, token: token);
        setState(() {
          _sentRequests = data;
          _isLoadingSent = false;
        });
      }
    } catch (e) {
      print('Error loading sent requests: $e');
      setState(() => _isLoadingSent = false);
    }
  }

  Future<void> _acceptFriendRequest(int userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      if (token != null) {
        await _searchService.acceptFriendRequest(userId, token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chấp nhận lời mời kết bạn'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadReceivedRequests(); // Reload the list
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chấp nhận lời mời kết bạn'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _rejectFriendRequest(int userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      if (token != null) {
        await _searchService.rejectFriendRequest(userId, token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối lời mời kết bạn'),
            backgroundColor: Color(0xFF6B7280),
          ),
        );
        _loadReceivedRequests(); // Reload the list
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể từ chối lời mời kết bạn'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _cancelFriendRequest(int userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      if (token != null) {
        await _searchService.cancelFriendRequest(userId, token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thu hồi lời mời kết bạn'),
            backgroundColor: Color(0xFF6B7280),
          ),
        );
        _loadSentRequests(); // Reload the list
      }
    } catch (e) {
      print('Error canceling friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thu hồi lời mời kết bạn'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Lời mời kết bạn',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Nhận được'),
            Tab(text: 'Đã gửi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_isLoadingReceived) {
      return const Center(child: CircularProgressIndicator());
    }

    final friendships = _receivedRequests?['data']?['friendships'] as List<dynamic>? ?? [];
    
    if (friendships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có lời mời kết bạn',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReceivedRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendships.length,
        itemBuilder: (context, index) {
          final request = friendships[index];
          return _buildReceivedRequestCard(request);
        },
      ),
    );
  }

  Widget _buildSentTab() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    final friendships = _sentRequests?['data']?['friendships'] as List<dynamic>? ?? [];
    
    if (friendships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa gửi lời mời nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSentRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendships.length,
        itemBuilder: (context, index) {
          final request = friendships[index];
          return _buildSentRequestCard(request);
        },
      ),
    );
  }

  Widget _buildReceivedRequestCard(dynamic request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: request['userId']),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: request['avatarUrl'] != null
                    ? NetworkImage(request['avatarUrl'])
                    : null,
                backgroundColor: const Color(0xFF6366F1),
                child: request['avatarUrl'] == null
                    ? Text(
                        (request['displayName'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: request['userId']),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['displayName'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${request['username'] ?? ''}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _acceptFriendRequest(request['userId']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(90, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Chấp nhận', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _rejectFriendRequest(request['userId']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    minimumSize: const Size(90, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestCard(dynamic request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: request['userId']),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: request['avatarUrl'] != null
                    ? NetworkImage(request['avatarUrl'])
                    : null,
                backgroundColor: const Color(0xFF1E88E5),
                child: request['avatarUrl'] == null
                    ? Text(
                        (request['displayName'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: request['userId']),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['displayName'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${request['username'] ?? ''}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Đang chờ',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _cancelFriendRequest(request['userId']),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thu hồi', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}