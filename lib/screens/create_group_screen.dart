import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/group_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _visibility = 'public_';
  File? _coverImage;
  final List<Map<String, dynamic>> _joinQuestions = [
    {
      'question': 'Bạn tham gia nhóm để làm gì?',
      'isRequired': true,
      'displayOrder': 1,
    },
    {
      'question': 'Bạn biết nhóm qua đâu?',
      'isRequired': false,
      'displayOrder': 2,
    },
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate() ) {
      try {
        final authToken = await Provider.of<AuthProvider>(context, listen: false).token;
        final response = await GroupService().createGroup(
          name: _nameController.text,
          description: _descriptionController.text,
          visibility: _visibility,
          coverImage: _coverImage!,
          joinQuestions: _joinQuestions,
          token: authToken!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Group Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _visibility,
                  items: [
                    DropdownMenuItem(value: 'public_', child: Text('Public')),
                    DropdownMenuItem(value: 'private', child: Text('Private')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _visibility = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Visibility'),
                ),
                SizedBox(height: 16),
                Text('Cover Image:'),
                SizedBox(height: 8),
                _coverImage == null
                    ? Text('No image selected')
                    : Image.file(_coverImage!, height: 150),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Select Image'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createGroup,
                  child: Text('Create Group'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}