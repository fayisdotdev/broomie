// lib/features/home/screens/home_screen.dart
import 'package:broomie/core/providers/auth_provider.dart';
import 'package:broomie/features/services/add_services.dart';
import 'package:broomie/features/services/list_Services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Map category name to icon
  static const Map<String, IconData> categoryIcons = {
    'Residential': Icons.home,
    'Commercial': Icons.apartment,
    'Specialized': Icons.cleaning_services,
  };

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'Welcome, ${user?.displayName ?? 'User'} 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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

              // Service Management
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
                          MaterialPageRoute(
                            builder: (_) => const AddServiceScreen(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const ServicesListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Services'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ---------------- Available Services Section ----------------
              const Text(
                "Available Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No categories available.');
                  }

                  // Extract unique categories
                  final categories = snapshot.data!.docs
                      .map((doc) => doc['category'] ?? 'Uncategorized')
                      .toSet()
                      .toList();

                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1, // +1 for "See All"
                      itemBuilder: (context, index) {
                        if (index == categories.length) {
                          // Last item = See All
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ServicesListScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircleAvatar(
                                    radius: 24,
                                    child: Icon(Icons.arrow_forward),
                                  ),
                                  SizedBox(height: 8),
                                  Text('See All', textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }

                        final category = categories[index];
                        final icon =
                            categoryIcons[category] ?? Icons.cleaning_services;

                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                child: Icon(icon, size: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // Inside your HomeScreen Column, replacing the previous Cleaning Services GridView
              const SizedBox(height: 30),

              // ---------------- Cleaning Services Section (Carousel) ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cleaning Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServicesListScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No services available.');
                  }

                  final services = snapshot.data!.docs;

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      padding: const EdgeInsets.only(left: 16),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final name = service['name'] ?? '';
                        final imageUrl = service['imageUrl'] ?? '';

                        return Container(
                          width: 160, // ~2 per viewport on typical phone
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                          ),
                                          child: const Icon(
                                            Icons.cleaning_services,
                                            size: 40,
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
