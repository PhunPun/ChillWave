import 'package:flutter/material.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final int profileCompletionCount;
  final Map<String, dynamic>? userData;
  final VoidCallback onUpdatePhoto;
  final VoidCallback onUpdateBio;
  final VoidCallback onUpdateInterests;

  const ProfileCompletionWidget({
    Key? key,
    required this.profileCompletionCount,
    required this.userData,
    required this.onUpdatePhoto,
    required this.onUpdateBio,
    required this.onUpdateInterests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete your profile',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$profileCompletionCount of 3 COMPLETE',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildProfileCompletionItem(
                  'Add your photo',
                  Icons.camera_alt,
                  userData?['photoUrl'] != null,
                  onUpdatePhoto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildProfileCompletionItem(
                  'Add your bio',
                  Icons.description,
                  userData?['bio'] != null && userData!['bio'].toString().isNotEmpty,
                  onUpdateBio,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildProfileCompletionItem(
                  'Add interests',
                  Icons.favorite,
                  userData?['interests'] != null,
                  onUpdateInterests,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionItem(
    String title, 
    IconData icon, 
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey[300]!,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 30,
              color: isCompleted ? Colors.green : null,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              isCompleted ? 'Completed' : 'Add',
              style: TextStyle(
                fontSize: 12, 
                color: isCompleted ? Colors.green : Colors.blue,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}