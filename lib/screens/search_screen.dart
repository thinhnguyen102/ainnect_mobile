import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import 'friends_list_screen.dart';
import 'friend_requests_screen.dart';
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final AuthService _authService = AuthService();
  List<dynamic> _results = [];
  List<dynamic> _friends = [];
  List<dynamic> _friendRequests = [];
  bool _isLoading = false;
  String _keyword = '';
  String? _authToken;

  void _performSearch() async {
    if (_keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final data = await _searchService.search(_keyword, token: _authToken);
    setState(() {
      _results = data['users'] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _fetchFriends() async {
    setState(() {
      _isLoading = true;
    });

    final userId = 'currentUserId'; 
    final data = await _searchService.fetchFriends(userId, token: _authToken);

    setState(() {
      _friends = data['data']?['friendships'] ?? [];
      _isLoading = false;
    });
  }

  void _navigateToFriendsList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsListScreen(friends: _friends),
      ),
    );
  }

  void _navigateToFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendRequestsScreen(friendRequests: _friendRequests),
      ),
    );
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    FriendRequestsScreen(friendRequests: []), // Replace with actual data
    Text('Groups Screen'),
    Text('Profile Screen'),
    Text('Notifications Screen'),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _keyword = _searchController.text;
      });
    });
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    _authToken = await _authService.getStoredToken();
    Logger.debug('Loaded auth token for search screen: $_authToken');
  }

  Future<void> _fetchFriendRequests() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _searchService.fetchFriendRequests(token: _authToken);

    setState(() {
      _friendRequests = data['data']?['friendships'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for users, groups, or posts...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onSubmitted: (value) {
                  Logger.debug('Search submitted with keyword: $value');
                  _performSearch();
                },
              ),
            ),
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Search', style: TextStyle(color: Colors.white)),
            ),
            
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: null,
    );
  }
}