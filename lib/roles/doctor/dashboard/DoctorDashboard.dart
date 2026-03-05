import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_home_page.dart';
import 'doctor_messages_page.dart';
import 'doctor_patients_page.dart';
import 'profile_page/doctor_profile_page.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isVerified = false;

  StreamSubscription<QuerySnapshot>? _verificationSub;

  @override
  void initState() {
    super.initState();
    _listenVerificationStatus();
  }

  void _listenVerificationStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _isLoading = false;
        _isVerified = false;
      });
      print("No logged in user or email is null");
      return;
    }

    final email = user.email!;
    print("Checking verification for email: $email");

    _verificationSub = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'Doctor')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        setState(() {
          _isVerified = false;
          _isLoading = false;
        });
        print("No doctor document found for email $email");
        return;
      }

      final data = snapshot.docs.first.data();
      bool verified = false;

      if (data.containsKey('isVerified')) {
        final field = data['isVerified'];
        if (field is bool) verified = field;
        else if (field is String) verified = field.toLowerCase() == 'true';
      }

      if (!verified && data.containsKey('verified')) {
        final field = data['verified'];
        if (field is bool) verified = field;
        else if (field is String) verified = field.toLowerCase() == 'true';
      }

      setState(() {
        _isVerified = verified;
        _isLoading = false;
      });

      print(
          "Firestore verification check: isVerified=${data['isVerified']}, verified=${data['verified']}, final=$verified");
    }, onError: (err) {
      setState(() {
        _isVerified = false;
        _isLoading = false;
      });
      print("Firestore verification error: $err");
    });
  }

  @override
  void dispose() {
    _verificationSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    await Future.wait([
      _refreshHome(),
      _refreshPatients(),
      _refreshMessages(),
      _refreshProfile(),
    ]);
  }

  Future<void> _refreshHome() async =>
      await Future.delayed(const Duration(seconds: 1));
  Future<void> _refreshPatients() async =>
      await Future.delayed(const Duration(seconds: 1));
  Future<void> _refreshMessages() async =>
      await Future.delayed(const Duration(seconds: 1));
  Future<void> _refreshProfile() async =>
      await Future.delayed(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              "Loading your dashboard...",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      )
          : _isVerified
          ? RefreshIndicator(
        color: const Color(0xFF4CAF50),
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                DoctorHomePage(),
                DoctorPatientsPage(),
                DoctorMessagesPage(),
                DoctorProfilePage(),
              ],
            ),
          ),
        ),
      )
          : Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: Colors.orange[50],
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.hourglass_empty,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  "Your account is still pending verification",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Once verified by the admin, you can access your dashboard.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
