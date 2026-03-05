// lib/screens/splash_screen.dart
import 'package:care_mama1/auth/Login_SignUpScreen/Login_Screen.dart';
import 'package:care_mama1/provider/UserProvider.dart';
import 'package:care_mama1/roles/admin/admin_dashboard.dart';
import 'package:care_mama1/roles/doctor/dashboard/DoctorDashboard.dart';
import 'package:care_mama1/roles/patient/User_Home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // splash 2 seconds delay, then check user
    Future.delayed(const Duration(seconds: 2), () {
      checkUser();
    });
  }

  void checkUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.getUserDetails();
    } catch (e) {
      debugPrint("Error in getUserDetails: $e");
    }

    if (!mounted) return;

    // ---------- NOT LOGGED IN ----------
    if (userProvider.user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // ---------- ROLE BASED NAVIGATION ----------
    switch (userProvider.role) {
      case 'Admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
        break;

        case 'User':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserScreen()),
            );
            break;

      case 'Doctor':
        if (userProvider.isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        break;


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              // child: Image.asset("assets/image/SplashScreen.gif"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Care Mama",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // 🔹 Loading indicator
          ],
        ),
      ),
    );
  }
}
