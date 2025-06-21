import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailModel {
  final String email;
  final String otpCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  EmailModel({
    required this.email,
    required this.otpCode,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  /// Generate random 6-digit OTP
  static String generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  /// Factory constructor from Firestore document
  factory EmailModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmailModel(
      email: data['email'] ?? '',
      otpCode: data['otpCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isUsed: data['isUsed'] ?? false,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otpCode': otpCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isUsed': isUsed,
    };
  }

  /// Check if OTP is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// Check if OTP is valid (not expired and not used)
  bool get isValid => !isExpired && !isUsed;

  /// Create new OTP with 60 seconds expiration
  static EmailModel createNewOTP(String email) {
    final now = DateTime.now();
    return EmailModel(
      email: email,
      otpCode: generateOTP(),
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 60)),
      isUsed: false,
    );
  }

  /// Copy with used flag
  EmailModel copyWith({bool? isUsed}) {
    return EmailModel(
      email: email,
      otpCode: otpCode,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}