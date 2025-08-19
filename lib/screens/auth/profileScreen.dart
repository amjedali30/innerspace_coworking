import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerspace_coworking/constatnt/colors.dart';
import '../../models/userModel.dart';
import '../booking/myBookingScreen.dart';
import '../notification/notificationScreen.dart';
import 'loginScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect if not logged in
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final appUser = AppUser.fromFirebaseUser(user);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorsData.primaryColor,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ---- User Info Section ----
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: ColorsData.primaryColor,
                  backgroundImage: appUser.photoUrl != null
                      ? NetworkImage(appUser.photoUrl!)
                      : null,
                  child: appUser.photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appUser.displayName ?? "Guest User",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorsData.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        appUser.email ?? "",
                        style: TextStyle(
                          color: ColorsData.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---- Options List ----
          _buildListTile(Icons.notifications, "Notifications", () {
            // dummy action
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()));
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Notifications tapped")),
            // );
          }),
          _buildListTile(Icons.book, "My Bookings", () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingHistoryScreen()));
          }),
          _buildListTile(Icons.help_center, "Help Center", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Help Center tapped")),
            );
          }),
          _buildListTile(Icons.settings, "Settings", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings tapped")),
            );
          }),

          const Divider(),

          // ---- Logout ----
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Helper for options
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: ColorsData.primaryColor,
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
