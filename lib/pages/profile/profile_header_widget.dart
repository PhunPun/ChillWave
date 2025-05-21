import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onUpdatePhoto;

  const ProfileHeaderWidget({
    Key? key,
    required this.userData,
    required this.onUpdatePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 10),
      child: Column(
        children: [
          // Profile avatar
          Column(
            children: [
              GestureDetector(
                onTap: onUpdatePhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: userData?['photoUrl'] != null
                          ? NetworkImage(userData!['photoUrl'])
                          : null,
                      child: userData?['photoUrl'] == null
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                      backgroundColor: Color(0xFF9E1946),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userData?['username'] ?? 'User',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('0 Followers'),
                  SizedBox(width: 10),
                  Text('0 Following'),
                ],
              ),
              if (userData?['bio'] != null && userData!['bio'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    userData!['bio'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}