import 'package:care_mama1/provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/DoctorDetailsScreen.dart';

class UserServiceListScreen extends StatefulWidget {
  const UserServiceListScreen({super.key});

  @override
  State<UserServiceListScreen> createState() =>
      _UserServiceListScreenState();
}

class _UserServiceListScreenState
    extends State<UserServiceListScreen> {
  String selectedCategory = "All";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 User Name
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                           TextSpan(
                            text: 'Welcome, ',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: userProvider.name ?? 'User',
                            style:  GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.blue, // Primary color for name
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  IconButton(
                    icon: const Icon(
                        Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Search Bar (WORKING)
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery =
                        value.toLowerCase().trim();
                  });
                },
                decoration: InputDecoration(
                  hintText:
                  "Search doctor, category, qualification...",
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon:
                  const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Banner
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(
                        "assets/image/BannerImage.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                child:  Text(
                  "Looking for Services?\nBook your appointments now!",
                  style:GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Categories
               Text("Categories",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryItem(
                        "All",
                        Icons.medical_services,
                        Colors.pink),
                    _categoryItem(
                        "Dental",
                        Icons.favorite,
                        Colors.green),
                    _categoryItem(
                        "Pulmonology",
                        Icons.local_hospital,
                        Colors.orange),
                    _categoryItem(
                        "General",
                        Icons.healing,
                        Colors.purple),
                    _categoryItem(
                        "Neurology",
                        Icons.psychology,
                        Colors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Services
              Text("Available Services",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // 🔹 Firestore (ALL DATA → FILTER LOCALLY)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctor_services')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return  Center(
                        child:
                        Text("No services available",style: GoogleFonts.poppins(),));
                  }

                  // 🔹 FILTER LOGIC
                  final filteredDocs =
                  snapshot.data!.docs.where((doc) {
                    final data = doc.data()
                    as Map<String, dynamic>;

                    final name =
                    (data['doctorName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final category =
                    (data['category'] ?? '')
                        .toString()
                        .toLowerCase();
                    final qualification =
                    (data['qualification'] ?? '')
                        .toString()
                        .toLowerCase();

                    final matchSearch =
                        name.contains(searchQuery) ||
                            category
                                .contains(searchQuery) ||
                            qualification
                                .contains(searchQuery);

                    final matchCategory =
                        selectedCategory == "All" ||
                            category ==
                                selectedCategory
                                    .toLowerCase();

                    return matchSearch &&
                        matchCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return  Center(
                      child: Text(
                          "No matching services found",style: GoogleFonts.poppins()),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                      filteredDocs[index].data()
                      as Map<String, dynamic>;

                      final doctorName =
                          data['doctorName'] ??
                              'No Name';
                      final category =
                          data['category'] ?? 'Unknown';
                      final qualification =
                          data['qualification'] ?? '';
                      final imageUrl =
                          data['imageUrl'] ?? '';
                      final price = data['price'] ?? 0;
                      final doctorId = filteredDocs[index].id;


                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorDetailsScreen(
                                      doctorId:
                                      doctorId),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(
                              bottom: 16),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                16),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius
                                      .circular(12),
                                  child: imageUrl
                                      .isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit
                                        .cover,
                                  )
                                      : Image.asset(
                                    'assets/image/default_doctor.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit
                                        .cover,
                                  ),
                                ),
                                const SizedBox(
                                    width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(doctorName,
                                          style:
                                           GoogleFonts.poppins(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize:
                                              16)),
                                      const SizedBox(
                                          height: 4),
                                      Text(category,
                                          style:
                                          GoogleFonts.poppins(
                                              color: Colors
                                                  .blueGrey,
                                              fontSize:
                                              13)),
                                      const SizedBox(
                                          height: 4),
                                      Text(qualification,
                                          style:
                                          GoogleFonts.poppins(
                                              color: Colors
                                                  .grey)),
                                      const SizedBox(
                                          height: 8),
                                      Text(
                                        "Session / ৳$price",
                                        style:
                                        GoogleFonts.poppins(
                                            color: Colors
                                                .green,
                                            fontWeight:
                                            FontWeight
                                                .w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Category Item
  Widget _categoryItem(
      String title, IconData icon, Color color) {
    final isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color:
          isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
              isSelected ? color : Colors.transparent,
              width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                isSelected ? Colors.white : color,
                size: 28),
            const SizedBox(height: 8),
            Text(title,
                style:  GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
