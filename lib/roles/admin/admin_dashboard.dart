import 'package:care_mama1/provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../auth/Login_SignUpScreen/Login_Screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Tabs
  final List<String> tabs = ["Dashboard", "Approvals"];

  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(tabs[_selectedIndex]),
        backgroundColor: Colors.green[600],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],

      ),
      body: _selectedIndex == 0 ? const DashboardTab() : const ApprovalsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey[600],
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Approvals"),
        ],
      ),
    );
  }
}

// ---------------- Dashboard Tab ----------------
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Doctor')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        final doctors = snapshot.data!.docs;
        final verified = doctors.where((doc) => doc['verified'] == true).length;
        final pending = doctors.length - verified;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.green[50],
                child: ListTile(
                  leading: const Icon(Icons.people, size: 48, color: Colors.green),
                  title: const Text("Total Doctors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: Text("${doctors.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.orange[50],
                child: ListTile(
                  leading: const Icon(Icons.hourglass_bottom, size: 48, color: Colors.orange),
                  title: const Text("Pending Approvals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: Text("$pending", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.green[100],
                child: ListTile(
                  leading: const Icon(Icons.verified, size: 48, color: Colors.green),
                  title: const Text("Verified Doctors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: Text("$verified", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- Approvals Tab ----------------
class ApprovalsTab extends StatelessWidget {
  const ApprovalsTab({super.key});

  void _approveDoctor(String docId) {
    FirebaseFirestore.instance.collection('users').doc(docId).update({'verified': true});
  }

  void _rejectDoctor(String docId) {
    FirebaseFirestore.instance.collection('users').doc(docId).update({'verified': false});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Doctor')
          .where('verified', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        final pendingDoctors = snapshot.data!.docs;
        if (pendingDoctors.isEmpty) {
          return const Center(
            child: Text(
              "No pending approvals!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingDoctors.length,
          itemBuilder: (context, index) {
            final doc = pendingDoctors[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(data['specialization'] ?? "", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(data['email'] ?? "", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text("Hospital: ${data['hospital'] ?? '-'}", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => _approveDoctor(doc.id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text("Approve"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _rejectDoctor(doc.id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text("Reject"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
