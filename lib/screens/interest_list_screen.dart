import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/url_helper.dart';
import 'manage_interest_screen.dart';

class InterestListScreen extends StatefulWidget {
  const InterestListScreen({Key? key}) : super(key: key);

  @override
  State<InterestListScreen> createState() => _InterestListScreenState();
}

class _InterestListScreenState extends State<InterestListScreen> {
  final ProfileService _profileService = ProfileService();
  List<Interest> _interests = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }
      final interests = await _profileService.getInterests(token);
      if (mounted) {
        setState(() {
          _interests = interests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToManage([Interest? interest]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageInterestScreen(interest: interest),
      ),
    );
    if (result == true) {
      _hasChanges = true;
      _loadInterests();
    }
  }

  void _closeScreen() {
    Navigator.pop(context, _hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closeScreen();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sở thích'),
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeScreen,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _interests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.interests, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có sở thích nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final interest = _interests[index];
                      final imageUrl = UrlHelper.fixImageUrl(interest.imageUrl);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                imageUrl != null ? NetworkImage(imageUrl) : null,
                            backgroundColor:
                                imageUrl == null ? const Color(0xFF1E88E5) : null,
                            child: imageUrl == null
                                ? const Icon(Icons.favorite, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            interest.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                interest.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              if (interest.description != null &&
                                  interest.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  interest.description!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                            onPressed: () => _navigateToManage(interest),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToManage(),
          backgroundColor: const Color(0xFF1E88E5),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

