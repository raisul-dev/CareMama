import 'package:care_mama1/auth/Login_SignUpScreen/Login_Screen.dart';
import 'package:care_mama1/provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
         
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Profile",  style: GoogleFonts.poppins(fontSize: 22,color: Colors.grey),),
                  SizedBox(height: 20,),
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                  ),
                  const SizedBox(height: 20),
                  Text(userProvider.name ?? "Patient",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(userProvider.email ?? ""),

                ],
              ),
            ),
            //Edit Profile
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_2_outlined),
                    SizedBox(width: 10,),
                    Text("Edit Profile"),
                  ],
                ),
               Icon(Icons.chevron_right)

              ],
            ),
            //Favorite
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_outline_outlined),
                    SizedBox(width: 10,),
                    Text("Favorite"),
                  ],
                ),
                Icon(Icons.chevron_right)

              ],
            ),
           //Notifications
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_outlined),
                    SizedBox(width: 10,),
                    Text("Notifications"),
                  ],
                ),
                Icon(Icons.chevron_right)

              ],
            ),
            //Settings

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 10,),
                    Text("Settings"),
                  ],
                ),
                Icon(Icons.chevron_right)

              ],
            ),
            const SizedBox(height: 20),
            //Help and Support
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outlined),
                    SizedBox(width: 10,),
                    Text("Help and Support"),
                  ],
                ),
                Icon(Icons.chevron_right)

              ],
            ),
            const SizedBox(height: 20),
            //Terms and Conditions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 10,),
                    Text("Terms and Conditions"),
                  ],
                ),
                Icon(Icons.chevron_right)

              ],
            ),
            //Log Out
            const SizedBox(height: 20),
            InkWell(
              onTap: ()async{
                await userProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10,),
                      Text("Log Out"),
                    ],
                  ),
                  Icon(Icons.chevron_right)

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
