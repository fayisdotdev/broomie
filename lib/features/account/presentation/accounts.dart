import 'package:broomie/styles/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColorsPage.primaryColor,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColorsPage.secondaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColorsPage.lightGreen,
                  child: Text(
                    user?.displayName != null
                        ? user!.displayName![0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Fathima Ebrahim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPage.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? '+91 908 786 4233',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColorsPage.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            AccountOption(
              title: 'Wallet',
              subtitle: 'Balance 125',
              icon: Icons.account_balance_wallet,
            ),
            AccountOption(title: 'Edit Profile', icon: Icons.edit),
            AccountOption(title: 'Saved Address', icon: Icons.location_on),
            AccountOption(title: 'Terms & Conditions', icon: Icons.article),
            AccountOption(title: 'Privacy Policy', icon: Icons.privacy_tip),
            AccountOption(title: 'Refer a Friend', icon: Icons.group_add),
            AccountOption(title: 'Customer Support', icon: Icons.support_agent),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPage.secondaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const AccountOption(
      {required this.title, this.subtitle, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColorsPage.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColorsPage.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColorsPage.textColor),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColorsPage.textColor),
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
