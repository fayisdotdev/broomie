// lib/features/home/screens/home_screen.dart
import 'package:broomie/core/providers/auth_provider.dart';
import 'package:broomie/features/services/add_services.dart';
import 'package:broomie/features/services/list_Services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? 'User'} 👋',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email != null
                  ? 'Email: ${user!.email}'
                  : user?.phoneNumber != null
                      ? 'Phone: ${user!.phoneNumber}'
                      : 'Signed in anonymously or unknown method',
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 30),

            /// ---------------- Service Management Section ----------------
            const Text(
              "Service Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddServiceScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Service'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServicesListScreen()),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Services'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
