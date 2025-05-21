import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../views/auth/register_view.dart'; // Make sure this path is correct

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => const RegisterView()); // Updated to RegistrationScreen
        Get.snackbar(
          'Registration Required',
          'Please register to access your profile',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _UserProfileContent(authController: authController);
  }
}

class _UserProfileContent extends StatefulWidget {
  final AuthController authController;

  const _UserProfileContent({required this.authController});

  @override
  State<_UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<_UserProfileContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.authController.currentUser.value;
    _nameController = TextEditingController(text: user?['full_name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    try {
      await widget.authController.updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        image: _profileImage, // Added image parameter
      );
      
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() => _isSaving = false);
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing) IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null 
                        ? FileImage(_profileImage!) 
                        : (widget.authController.currentUser.value?['photoUrl'] != null
                            ? NetworkImage(widget.authController.currentUser.value!['photoUrl']) as ImageProvider
                            : null),
                    child: _profileImage == null && widget.authController.currentUser.value?['photoUrl'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                if (_isEditing) TextButton(
                  onPressed: _pickImage,
                  child: const Text('Change Photo'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: false,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isEditing = false;
                      // Reset changes if cancelled
                      final user = widget.authController.currentUser.value;
                      _nameController.text = user?['full_name'] ?? '';
                      _phoneController.text = user?['phone'] ?? '';
                      _profileImage = null;
                    }),
                    child: const Text('Cancel'),
                  ),
                ],
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => widget.authController.logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}