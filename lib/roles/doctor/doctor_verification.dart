import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard/DoctorDashboard.dart';

class DoctorVerificationScreen extends StatefulWidget {
  const DoctorVerificationScreen({super.key});

  @override
  State<DoctorVerificationScreen> createState() =>
      _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _bmdc = TextEditingController();
  final TextEditingController _specialization = TextEditingController();
  final TextEditingController _hospital = TextEditingController();

  bool loading = false;

  Future<void> _submitVerification() async {
    if (_name.text.isEmpty ||
        _bmdc.text.isEmpty ||
        _specialization.text.isEmpty ||
        _hospital.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("সব তথ্য দিন")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "name": _name.text,
        "bmdcNumber": _bmdc.text,
        "specialization": _specialization.text,
        "hospital": _hospital.text,
        "isVerified": false, // pending
        "profileCompleted": true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _field(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Verification")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(_name, "Full Name"),
            _field(_bmdc, "BMDC Registration Number"),
            _field(_specialization, "Specialization"),
            _field(_hospital, "Hospital / Clinic Name"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Certificate"),
              onPressed: () {
                // TODO: implement image picker + firebase storage
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _submitVerification,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit for Verification"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
