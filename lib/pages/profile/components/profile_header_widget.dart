import 'package:chillwave/pages/profile/components/profile_edit.dart';
import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onUpdatePhoto;

  const ProfileHeaderWidget({
    Key? key,
    required this.userData,
    required this.onUpdatePhoto,
  }) : super(key: key);

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  late Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  void _handleSave(Map<String, dynamic> newData) {
    setState(() {
      _userData = newData;
    });
  }

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
                onTap: widget.onUpdatePhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _userData?['photoUrl'] != null
                          ? NetworkImage(_userData!['photoUrl'])
                          : null,
                      child: _userData?['photoUrl'] == null
                          ? Icon(Icons.person, size: 40, color: Color(MyColor.white))
                          : null,
                      backgroundColor: Color(MyColor.pr4),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(MyColor.se3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Color(MyColor.pr1),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userData?['username'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            userData: _userData,
                            onSave: _handleSave, // 👈 Gọi callback khi cập nhật
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, size: 25, color: Color(MyColor.pr4)),
                  ),
                ],
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
              if (_userData?['bio'] != null && _userData!['bio'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _userData!['bio'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(MyColor.se3)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
