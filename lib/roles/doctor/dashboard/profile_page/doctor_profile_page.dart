import 'package:care_mama1/roles/doctor/dashboard/profile_page/DoctorEditProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:care_mama1/provider/UserProvider.dart';
import 'package:care_mama1/auth/Login_SignUpScreen/Login_Screen.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  void _showLogoutSheet(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text("Are you sure you want to log out?"),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await userProvider.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (_) => false,
                          );
                        }
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final name = userProvider.name;
    final phone = userProvider.phone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF1F2937),
              child: Text(
                name != null && name.isNotEmpty
                    ? name[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name ?? "Guest User",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              phone ?? "No number added",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _menuItem(
              Icons.person_outline,
              "Edit Profile",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorEditProfilePage(),
                  ),
                );
              },
            ),

            _menuItem(Icons.settings_outlined, "Settings", () {}),
            _menuItem(Icons.help_outline, "Help & Support", () {}),

            _menuItem(
              Icons.logout,
              "Logout",
              () => _showLogoutSheet(context),
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: isLogout
              ? null
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        if (!isLogout) const Divider(height: 1),
      ],
    );
  }
}
