import 'package:care_mama1/roles/patient/Booking/Book_Appoinment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorId; // Receive doctorId from UserServiceListScreen

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title:  Text(
          'Doctor Details',
          style:  GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor_services')
            .doc(doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Doctor data not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final doctorName = data['doctorName'] ?? 'No Name';
          final category = data['category'] ?? '';
          final imageUrl = data['imageUrl'] ?? '';
          final price = data['price'] ?? 0;
          final duration = data['duration'] ?? '';
          final experience = data['experience'] ?? 'N/A';
          final qualification = data['qualification'] ?? 'N/A';
          final patientCount = data['patientCount'] ?? '0';
          final rating = data['rating'] ?? 0.0;
          final description = data['description'] ?? 'No description provided';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Doctor Header Card ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/image/default_doctor.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctorName,
                                  style:  GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(category,
                                  style:  GoogleFonts.poppins(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people_alt,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text("$patientCount patients",
                                      style:  GoogleFonts.poppins(
                                          color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
            
                  // --- Stats Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.verified, experience, "experience"),
                      _buildStatItem(Icons.star, rating.toString(), "rating"),
                      _buildStatItem(Icons.money, "৳$price", "fee"),
                      _buildStatItem(Icons.access_time, duration, "duration"),
                    ],
                  ),
                  const SizedBox(height: 25),
            
                  // --- About Me Section ---
                 Text('About me',
                      style:
                      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(description, style:  GoogleFonts.poppins(color: Colors.grey)),
                  const SizedBox(height: 25),
            
                  // --- Reviews Section (static for now) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('Reviews',
                          style:  GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {},
                          child: const Text('See All',
                              style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                        backgroundImage:
                        NetworkImage('https://via.placeholder.com/50')),
                    title: const Text('Emily Anderson',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                              5,
                                  (index) => const Icon(Icons.star,
                                  color: Colors.orange, size: 16)),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                            "Dr. Patel is a true professional who genuinely cares about his patients. I highly recommend...",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
            
                  // --- Book Appointment Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScheduleScreen(
                              doctorId: doctorId,
                              userId: userId,
                            ),
                          ),
                        );


                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2633),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child:  Text('Book Appointment',
                          style:  GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF1B2633)),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
