import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  // 🔹 USER DATA
  User? _user;
  String? _role;
  String? _name;
  String? _email;
  String? _phone;
  String? _doctorImageUrl;
  bool _profileCompleted = false;
  bool _isVerified = false;

  // 🔹 FIREBASE
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 GETTERS
  User? get user => _user;
  String? get role => _role;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get doctorImageUrl => _doctorImageUrl;
  bool get profileCompleted => _profileCompleted;
  bool get isVerified => _isVerified;

  // =========================================================
  // 🔹 FETCH USER DETAILS
  // =========================================================
  Future<void> getUserDetails() async {
    try {
      _user = _auth.currentUser;
      if (_user == null) return;

      final doc =
      await _firestore.collection('users').doc(_user!.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _role = data['role'];
        _name = data['name'];
        _email = data['email'];
        _phone = data['phone'];
        _doctorImageUrl = data['doctorImageUrl'];
        _profileCompleted = data['profileCompleted'] ?? false;

        if (_role == 'Doctor') {
          _isVerified = data['isVerified'] ?? false;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("getUserDetails Error: $e");
    }
  }

  // =========================================================
  // 🔹 UPDATE PHONE
  // =========================================================
  Future<void> updatePhoneOnly({required String phone}) async {
    try {
      _user = _auth.currentUser;
      if (_user == null) throw Exception("Not logged in");

      await _firestore.collection('users').doc(_user!.uid).set({
        'phone': phone,
        'profileCompleted': true,
      }, SetOptions(merge: true));

      _phone = phone;
      _profileCompleted = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // 🔹 GET DOCTOR SERVICE (FOR EDIT MODE)
  // =========================================================
  Future<Map<String, dynamic>?> getMyDoctorService() async {
    _user = _auth.currentUser;
    if (_user == null) return null;

    final doc = await _firestore
        .collection('doctor_services')
        .doc(_user!.uid)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // =========================================================
  // 🔹 ADD / UPDATE DOCTOR SERVICE (ONLY ONE)
  // =========================================================
  Future<void> addDoctorService({
    required String category,
    required String subCategory,
    required String service,
    required String title,
    required String description,
    required int price,
    required String duration,
    required String qualification,
    required String experience,
    required String patientCount,
    required String imageUrl,
  }) async {
    try {
      _user = _auth.currentUser;
      if (_user == null) throw Exception("User not logged in");

      final uid = _user!.uid;

      await _firestore
          .collection('doctor_services')
          .doc(uid) // 🔥 ONE SERVICE PER DOCTOR
          .set({
        'doctorId': uid,
        'doctorName': _name ?? 'Unknown Doctor',
        'category': category,
        'subCategory': subCategory,
        'service': service,
        'title': title,
        'description': description,
        'price': price,
        'duration': duration,
        'qualification': qualification,
        'experience': experience,
        'patientCount': patientCount,
        'imageUrl': imageUrl,
        'rating': 4.9,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // ✅ ADD + EDIT

      // update profile image
      await _firestore.collection('users').doc(uid).set({
        'doctorImageUrl': imageUrl,
      }, SetOptions(merge: true));

      _doctorImageUrl = imageUrl;
      notifyListeners();
    } catch (e) {
      debugPrint("addDoctorService Error: $e");
      rethrow;
    }
  }

  //Booking Appoinment
  Future<void> bookAppointment({
    required String doctorId,
    required String userId,
    required DateTime date,
    required String time,
  }) async {
    final String dateStr =
        "${date.year}-${date.month}-${date.day}";
    final String slotId = "${dateStr}_$time";

    final slotRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('schedules')
        .doc(slotId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(slotRef);

      if (snapshot.exists) {
        throw Exception("Slot already booked");
      }

      transaction.set(slotRef, {
        'userId': userId,
        'date': dateStr,
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }


  //  LOGOUT

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _role = null;
    _name = null;
    _email = null;
    _phone = null;
    _doctorImageUrl = null;
    _profileCompleted = false;
    _isVerified = false;
    notifyListeners();
  }
}
