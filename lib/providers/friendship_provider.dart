import 'package:flutter/foundation.dart';
import '../models/friendship_models.dart';
import '../services/friendship_service.dart';
import '../utils/logger.dart';

class FriendshipProvider with ChangeNotifier {
  final FriendshipService _friendshipService = FriendshipService();
  
  List<FriendshipResponse> _friendRequests = [];
  Map<int, SocialStats> _socialStatsCache = {}; // Cache full social stats
  bool _isLoading = false;
  String? _error;
  
  int _currentPage = 0;
  bool _hasMore = true;
  
  List<FriendshipResponse> get friendRequests => _friendRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  int get pendingRequestsCount {
    return _friendRequests.where((req) => req.isPending).length;
  }
  
  // Get social stats for a user
  SocialStats? getSocialStats(int userId) {
    return _socialStatsCache[userId];
  }
  
  // Check if users are friends
  bool isFriend(int userId) {
    return _socialStatsCache[userId]?.friend ?? false;
  }

  // Check if can send friend request
  bool canSendFriendRequest(int userId) {
    return _socialStatsCache[userId]?.canSendFriendRequest ?? true;
  }

  // Check if following
  bool isFollowing(int userId) {
    return _socialStatsCache[userId]?.following ?? false;
  }

  // Get friends count
  int getFriendsCount(int userId) {
    return _socialStatsCache[userId]?.friendsCount ?? 0;
  }

  // Load social stats for a specific user
  Future<SocialStats?> loadSocialStats(int userId) async {
    try {
      final stats = await _friendshipService.getSocialStats(userId);
      if (stats != null) {
        _socialStatsCache[userId] = stats;
        notifyListeners();
      }
      return stats;
    } catch (e) {
      Logger.error('Error loading social stats: $e');
      return null;
    }
  }

  // Legacy method for backward compatibility
  Future<bool> loadFriendshipStatus(int userId) async {
    final stats = await loadSocialStats(userId);
    return stats?.friend ?? false;
  }

  // Send friend request
  Future<bool> sendFriendRequest(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _friendshipService.sendFriendRequest(userId);
      
      // Reload social stats after sending request
      await loadSocialStats(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error sending friend request: $e');
      return false;
    }
  }

  // Unfriend
  Future<bool> unfriend(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _friendshipService.unfriend(userId);
      
      // Reload social stats after unfriending
      await loadSocialStats(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error unfriending: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _friendshipService.acceptFriendRequest(userId);
      
      // Reload social stats after accepting
      await loadSocialStats(userId);
      
      // Remove from friend requests list
      _friendRequests.removeWhere((req) => req.userId == userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _friendshipService.rejectFriendRequest(userId);
      
      // Reload social stats after rejecting
      await loadSocialStats(userId);
      
      // Remove from friend requests list
      _friendRequests.removeWhere((req) => req.userId == userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error rejecting friend request: $e');
      return false;
    }
  }

  // Load friend requests
  Future<void> loadFriendRequests({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _friendRequests.clear();
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _friendshipService.getFriendRequests(
        page: _currentPage,
        size: 10,
      );
      
      if (refresh) {
        _friendRequests = response.friendships;
      } else {
        _friendRequests.addAll(response.friendships);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error loading friend requests: $e');
    }
  }

  Future<void> refreshFriendRequests() async {
    await loadFriendRequests(refresh: true);
  }
}
