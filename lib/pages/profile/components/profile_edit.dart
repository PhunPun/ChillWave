import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../themes/colors/colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>)? onSave;
  final String? userId; // Thêm userId để update Firebase

  const EditProfileScreen({
    Key? key,
    this.userData,
    this.onSave,
    this.userId,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.userData != null) {
      _usernameController.text = widget.userData!['username'] ?? '';
      _bioController.text = widget.userData!['bio'] ?? '';
      _emailController.text = widget.userData!['email'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(MyColor.pr4), // Hồng
                    Color(MyColor.se2), // Xanh
                    Color(MyColor.pr6), // Đỏ đậm
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(MyColor.pr4), // Hồng
                    Color(MyColor.se2), // Xanh
                    Color(MyColor.pr6), // Đỏ đậm
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
            ),
            if (widget.userData?['photoUrl'] != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Xoá ảnh hiện tại'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    // Set flag để xoá ảnh
                  });
                },
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String userId = widget.userId ?? _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      String fileName = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoUrl = widget.userData?['photoUrl'];
      
      // Upload ảnh mới nếu có
      if (_selectedImage != null) {
        photoUrl = await _uploadImageToFirebase(_selectedImage!);
        if (photoUrl == null) {
          throw Exception('Không thể tải ảnh lên');
        }
      }

      // Tạo data mới để lưu (chỉ username và bio)
      Map<String, dynamic> updatedData = {
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Thêm photoUrl nếu có
      if (photoUrl != null) {
        updatedData['photoUrl'] = photoUrl;
      }

      // Lấy userId
      String userId = widget.userId ?? _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Không tìm thấy user ID');
      }

      // Cập nhật Firebase Firestore
      await _firestore.collection('users').doc(userId).update(updatedData);

      // Gọi callback để cập nhật UI local
      if (widget.onSave != null) {
        updatedData['photoUrl'] = photoUrl; // Đảm bảo có photoUrl trong callback
        updatedData['email'] = _emailController.text; // Giữ email trong callback
        widget.onSave!(updatedData);
      }

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Color(MyColor.pr4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Quay lại màn hình trước
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(MyColor.pr4)),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(MyColor.pr4), // Hồng
                                  Color(MyColor.se2), // Xanh
                                  Color(MyColor.pr6), // Đỏ đậm
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(2), // Tạo viền gradient
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (widget.userData?['photoUrl'] != null
                                        ? NetworkImage(widget.userData!['photoUrl'])
                                        : null),
                                child: _selectedImage == null && widget.userData?['photoUrl'] == null
                                    ? Icon(Icons.person, size: 50, color: Color(MyColor.white))
                                    : null,
                                backgroundColor: Color(MyColor.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(MyColor.pr4), // Hồng
                                    Color(MyColor.se2), // Xanh
                                    Color(MyColor.pr6), // Đỏ đậm
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(MyColor.pr4), // Hồng
                          Color(MyColor.se2), // Xanh
                          Color(MyColor.pr6), // Đỏ đậm
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        'Nhấn để thay đổi ảnh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Form fields
                    SizedBox(
                      height: 56, // Chiều cao cố định cho tất cả input
                      child: _buildTextField(
                        controller: _usernameController,
                        label: 'Tên hiển thị',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên hiển thị';
                          }
                          if (value.trim().length < 2) {
                            return 'Tên hiển thị phải có ít nhất 2 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      height: 56, // Chiều cao cố định cho tất cả input
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Không thể chỉnh sửa
                      ),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      height: 120, // Chiều cao lớn hơn cho bio field (3 dòng)
                      child: _buildTextField(
                        controller: _bioController,
                        label: 'Giới thiệu bản thân',
                        icon: Icons.info_outline,
                        maxLines: 3,
                        maxLength: 150,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(MyColor.pr4), // Hồng
                              Color(MyColor.se2), // Xanh
                              Color(MyColor.pr6), // Đỏ đậm
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(MyColor.pr4).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(MyColor.pr4), // Hồng
              Color(MyColor.se2), // Xanh
              Color(MyColor.pr6), // Đỏ đậm
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Icon(icon, color: Colors.white),
        ),
        labelStyle: TextStyle(
          color: enabled ? Color(MyColor.se3) : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(MyColor.pr4), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}