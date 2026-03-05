import 'package:care_mama1/auth/Login_SignUpScreen/Service/Forgot_Password.dart';
import 'package:care_mama1/provider/UserProvider.dart';
import 'package:care_mama1/roles/doctor/dashboard/DoctorDashboard.dart';
import 'package:care_mama1/roles/patient/User_Home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Service/auth_service.dart';
import 'SignUp_Screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ===================== SERVICES =====================
  final AuthService _authService = AuthService();

  // ===================== CONTROLLERS =====================
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ===================== STATE =====================
  bool _isLoading = false;
  bool isPasswordHidden = true;

  @override
  void initState() {
    super.initState(); // ✅ auto login REMOVED
  }

  // ===================== LOGIN FUNCTION =====================
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      String? result = await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result == 'Doctor' || result == 'User') {
        final userProvider =
        Provider.of<UserProvider>(context, listen: false);

        await userProvider.getUserDetails();

        if (!mounted) return;

        if (result == 'Doctor') {
          bool isVerified = userProvider.isVerified ?? false;

          if (isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DoctorDashboard(),
              ),
            );
          } else {
            _showSnack("Doctor account not verified yet");
          }
        } else if (result == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UserScreen(),
            ),
          );
        }
      } else {
        _showSnack(result ?? "Login failed");
      }
    } catch (e) {
      _showSnack("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ===================== SNACKBAR =====================
  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ===================== DISPOSE =====================
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===================== UI (UNCHANGED) =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Column(
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    size: 50,
                    color: Color(0xFF1E2A3A),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "DoctorHub",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2A3A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                "Hi, Welcome Back!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hope you're doing fine.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Your Email",
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: isPasswordHidden,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2A3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  "Forgot password?",
                  style:
                  GoogleFonts.poppins(color: const Color(0xFF3B82F6)),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account yet? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupPage()),
                      );
                    },
                    child: Text(
                      "Sign up",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
