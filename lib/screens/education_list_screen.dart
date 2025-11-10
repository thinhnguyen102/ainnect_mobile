import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/url_helper.dart';
import 'manage_education_screen.dart';

class EducationListScreen extends StatefulWidget {
  const EducationListScreen({Key? key}) : super(key: key);

  @override
  State<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends State<EducationListScreen> {
  final ProfileService _profileService = ProfileService();
  List<Education> _educations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEducations();
  }

  Future<void> _loadEducations() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final educations = await _profileService.getEducations(token);

      if (mounted) {
        setState(() {
          _educations = educations;
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

  Future<void> _navigateToManage([Education? education]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageEducationScreen(education: education),
      ),
    );

    if (result == true) {
      _loadEducations(); // Reload list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học vấn'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _educations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có học vấn nào',
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
                  itemCount: _educations.length,
                  itemBuilder: (context, index) {
                    final education = _educations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: education.imageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  UrlHelper.fixImageUrl(education.imageUrl!),
                                ),
                                radius: 28,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.school),
                                radius: 28,
                              ),
                        title: Text(
                          education.schoolName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${education.degree} - ${education.fieldOfStudy}'),
                            const SizedBox(height: 4),
                            Text(
                              education.isCurrent 
                                  ? 'Hiện tại' 
                                  : (education.startDate ?? 'Chưa rõ'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                          onPressed: () => _navigateToManage(education),
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
    );
  }
}
