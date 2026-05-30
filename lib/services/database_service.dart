import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user info during registration
  Future<void> createUser(String uid, String email, String role) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'role': role, // 'admin' or 'user'
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return (doc.data() as Map<String, dynamic>)['role'] ?? 'user';
    }
    return 'user';
  }

  // Save local video metadata to Firestore
  Future<void> saveVideoMetadata(String title, String localPath, String userId) async {
    await _db.collection('videos').add({
      'title': title,
      'localPath': localPath, // Path to local phone memory
      'uploadedBy': userId,
      'isApproved': true, // Requires Admin approval
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}