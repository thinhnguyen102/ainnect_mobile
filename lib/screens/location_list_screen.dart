import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/url_helper.dart';
import 'manage_location_screen.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({Key? key}) : super(key: key);

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  final ProfileService _profileService = ProfileService();
  List<UserLocation> _locations = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }
      final locations = await _profileService.getLocations(token);
      if (mounted) {
        setState(() {
          _locations = locations;
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

  Future<void> _navigateToManage([UserLocation? location]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageLocationScreen(location: location),
      ),
    );
    if (result == true) {
      _hasChanges = true;
      _loadLocations();
    }
  }

  void _closeScreen() {
    Navigator.pop(context, _hasChanges);
  }

  Widget _buildSubtitle(UserLocation location) {
    final lines = <String>[];
    lines.add(location.address);
    lines.add(location.locationType);
    if (location.isCurrent) {
      lines.add('Địa điểm hiện tại');
    }
    if (location.description != null && location.description!.isNotEmpty) {
      lines.add(location.description!);
    }
    
    if (location.latitude != null && location.longitude != null) {
      lines.add('Lat: ${location.latitude}, Lng: ${location.longitude}');
    }

    return Text(
      lines.join('\n'),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 13,
      ),
    );
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
          title: const Text('Địa điểm'),
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeScreen,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _locations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có địa điểm nào',
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
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final location = _locations[index];
                      final imageUrl = UrlHelper.fixImageUrl(location.imageUrl);
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
                                ? const Icon(Icons.location_city, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            location.locationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: _buildSubtitle(location),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                            onPressed: () => _navigateToManage(location),
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

