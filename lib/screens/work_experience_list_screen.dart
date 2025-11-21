import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/url_helper.dart';
import 'manage_work_experience_screen.dart';

class WorkExperienceListScreen extends StatefulWidget {
  const WorkExperienceListScreen({Key? key}) : super(key: key);

  @override
  State<WorkExperienceListScreen> createState() => _WorkExperienceListScreenState();
}

class _WorkExperienceListScreenState extends State<WorkExperienceListScreen> {
  final ProfileService _profileService = ProfileService();
  List<WorkExperience> _workExperiences = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkExperiences();
  }

  Future<void> _loadWorkExperiences() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final experiences = await _profileService.getWorkExperiences(token);

      if (mounted) {
        setState(() {
          _workExperiences = experiences;
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

  Future<void> _navigateToManage([WorkExperience? workExperience]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageWorkExperienceScreen(workExperience: workExperience),
      ),
    );

    if (result == true) {
      _loadWorkExperiences(); // Reload list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinh nghiệm làm việc'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workExperiences.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có kinh nghiệm làm việc nào',
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
                  itemCount: _workExperiences.length,
                  itemBuilder: (context, index) {
                    final work = _workExperiences[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Builder(
                          builder: (context) {
                            final imageUrl = UrlHelper.fixImageUrl(work.imageUrl);
                            if (imageUrl == null) {
                              return const CircleAvatar(
                                child: Icon(Icons.work),
                                radius: 28,
                              );
                            }
                            return CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              radius: 28,
                            );
                          },
                        ),
                        title: Text(
                          work.position,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(work.companyName),
                            const SizedBox(height: 4),
                            Text(
                              work.isCurrent 
                                  ? 'Hiện tại' 
                                  : (work.startDate ?? 'Chưa rõ'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                          onPressed: () => _navigateToManage(work),
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

