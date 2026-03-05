import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= SIGN UP =================
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // Doctor / User
        'phone': phone.trim(),
        'verified': false,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Signup failed";
    }
  }

  // ================= LOGIN =================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return "User not found";

      DocumentSnapshot doc =
      await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return "User data not found";
      }

      final data = doc.data() as Map<String, dynamic>;

      if (!data.containsKey('role')) {
        return "Role missing";
      }

      return data['role']; // Doctor / User
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Login failed";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
