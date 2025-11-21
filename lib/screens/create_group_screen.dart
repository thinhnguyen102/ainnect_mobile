import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/group_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _groupService = GroupService();
  final _imagePicker = ImagePicker();
  String _visibility = 'public_';
  File? _coverImage;
  bool _isLoading = false;
  final List<JoinQuestion> _joinQuestions = [];

  @override
  void initState() {
    super.initState();
    _addDefaultQuestions();
  }

  void _addDefaultQuestions() {
    setState(() {
      _joinQuestions.addAll([
        JoinQuestion(
          question: 'Bạn tham gia nhóm để làm gì?',
          isRequired: true,
          displayOrder: 1,
        ),
        JoinQuestion(
          question: 'Bạn biết nhóm qua đâu?',
          isRequired: false,
          displayOrder: 2,
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _joinQuestions.add(JoinQuestion(
        question: '',
        isRequired: false,
        displayOrder: _joinQuestions.length + 1,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _joinQuestions.removeAt(index);
      for (int i = 0; i < _joinQuestions.length; i++) {
        _joinQuestions[i] = JoinQuestion(
          question: _joinQuestions[i].question,
          isRequired: _joinQuestions[i].isRequired,
          displayOrder: i + 1,
        );
      }
    });
  }

  void _updateQuestion(int index, String question, bool isRequired) {
    setState(() {
      _joinQuestions[index] = JoinQuestion(
        question: question,
        isRequired: isRequired,
        displayOrder: _joinQuestions[index].displayOrder,
      );
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhóm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validQuestions = _joinQuestions
        .where((q) => q.question.trim().isNotEmpty)
        .map((q) => {
              'question': q.question.trim(),
              'isRequired': q.isRequired,
              'displayOrder': q.displayOrder,
            })
        .toList();

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final group = await _groupService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        visibility: _visibility,
        coverImage: _coverImage,
        joinQuestions: validQuestions,
        token: token,
      );

      if (group != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo nhóm thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, group);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo nhóm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo nhóm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Tạo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để tạo nhóm'),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          avatarUrl: user.avatarUrl,
                          displayName: user.displayName,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButton<String>(
                                value: _visibility,
                                isDense: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'public_',
                                    child: Row(
                                      children: [
                                        Icon(Icons.public, size: 16),
                                        SizedBox(width: 8),
                                        Text('Công khai'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'private',
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock, size: 16),
                                        SizedBox(width: 8),
                                        Text('Riêng tư'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _visibility = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhóm',
                        hintText: 'Nhập tên nhóm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên nhóm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Mô tả về nhóm của bạn',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ảnh bìa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh'),
                        ),
                      ],
                    ),
                    if (_coverImage != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _coverImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _coverImage = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Câu hỏi khi tham gia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm câu hỏi'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_joinQuestions.length, (index) {
                      final question = _joinQuestions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: question.question,
                                      decoration: InputDecoration(
                                        labelText: 'Câu hỏi ${question.displayOrder}',
                                        hintText: 'Nhập câu hỏi',
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _updateQuestion(index, value, question.isRequired);
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeQuestion(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                title: const Text('Bắt buộc trả lời'),
                                value: question.isRequired,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  _updateQuestion(
                                    index,
                                    question.question,
                                    value ?? false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Tạo nhóm',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class JoinQuestion {
  String question;
  bool isRequired;
  int displayOrder;

  JoinQuestion({
    required this.question,
    required this.isRequired,
    required this.displayOrder,
  });
}
