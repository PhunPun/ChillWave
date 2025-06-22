import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'components/profile_header_widget.dart';
import 'components/profile_completion_widget.dart';
import 'components/playlists_section_widget.dart';
import 'components/favorites_section_widget.dart';
import 'components/user_profile_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserProfileService _profileService = UserProfileService();
  
  User? _user;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _playlists = [];
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  int _profileCompletionCount = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _profileService.fetchUserData();
      
      setState(() {
        _user = result.user;
        _userData = result.userData;
        _playlists = result.playlists;
        _favorites = result.favorites;
        _profileCompletionCount = result.profileCompletionCount;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      await _profileService.pickAndUploadProfileImage();
      await _getUserData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (e) {
      print('Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile photo: $e')),
      );
    }
  }
  
  Future<void> _updateBio() async {
    String? currentBio = _userData?['bio'];
    final TextEditingController bioController = TextEditingController(text: currentBio);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Your Bio'),
        content: TextField(
          controller: bioController,
          decoration: const InputDecoration(
            hintText: 'Enter something about yourself...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (bioController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  await _profileService.updateUserBio(bioController.text.trim());
                  await _getUserData(); // Refresh data
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bio updated successfully')),
                  );
                } catch (e) {
                  print('Error updating bio: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating bio: $e')),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      color: Colors.white, // Đổi từ gradient sang nền trắng
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserProfile(),
    ),
  );
}

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderWidget(
            userData: _userData,
            onUpdatePhoto: _pickAndUploadImage,
          ),
          ProfileCompletionWidget(
            profileCompletionCount: _profileCompletionCount,
            userData: _userData,
            onUpdatePhoto: _pickAndUploadImage,
            onUpdateBio: _updateBio,
            onUpdateInterests: () {
              // Will be implemented in future
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          const SizedBox(height: 10),
          PlaylistsSectionWidget(),
          const SizedBox(height: 20),
          FavoritesSectionWidget(userId: _user?.uid ?? ''),
        ],
      ),
    );
  }
}