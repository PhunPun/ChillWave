import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileResult {
  final User? user;
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>> playlists;
  final List<Map<String, dynamic>> favorites;
  final int profileCompletionCount;

  UserProfileResult({
    required this.user,
    required this.userData,
    required this.playlists,
    required this.favorites,
    required this.profileCompletionCount,
  });
}

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<UserProfileResult> fetchUserData() async {
    User? user = _auth.currentUser;
    Map<String, dynamic>? userData;
    List<Map<String, dynamic>> playlists = [];
    List<Map<String, dynamic>> favorites = [];
    int profileCompletionCount = 0;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>?;
        
        // Calculate profile completion count
        profileCompletionCount = 0;
        if (userData?['photoUrl'] != null) profileCompletionCount++;
        if (userData?['bio'] != null && userData!['bio'].toString().isNotEmpty) profileCompletionCount++;
        if (userData?['interests'] != null) profileCompletionCount++;
      }

      QuerySnapshot playlistsSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('playlists')
              .get();

      playlists =
          playlistsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      QuerySnapshot favoritesSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .get();

      favorites =
          favoritesSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
    }

    return UserProfileResult(
      user: user,
      userData: userData,
      playlists: playlists,
      favorites: favorites,
      profileCompletionCount: profileCompletionCount,
    );
  }

  Future<void> pickAndUploadProfileImage() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null) {
      throw Exception('No image selected');
    }
    
    File imageFile = File(pickedFile.path);
    
    // Create a reference to user profile photo with userId
    final storageRef = _storage
        .ref()
        .child('user_profile_photos')
        .child('${user.uid}.jpg');
    
    // Upload file
    await storageRef.putFile(imageFile);
    
    // Get download URL
    String downloadUrl = await storageRef.getDownloadURL();
    
    // Update Firestore user document
    await _firestore.collection('users').doc(user.uid).update({
      'photoUrl': downloadUrl,
    });
    
    // Update Firebase Auth user profile
    await user.updatePhotoURL(downloadUrl);
  }

  Future<void> updateUserBio(String bio) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    
    // Update Firestore user document
    await _firestore.collection('users').doc(user.uid).update({
      'bio': bio,
    });
  }
}