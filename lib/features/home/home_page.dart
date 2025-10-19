// lib/features/home/screens/home_screen.dart
import 'package:broomie/features/cart/presentation/carts.dart';
import 'package:broomie/features/services/add_services.dart';
import 'package:broomie/features/services/list_Services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Map category name to icon
  static const Map<String, IconData> categoryIcons = {
    'Residential': Icons.home,
    'Commercial': Icons.apartment,
    'Specialized': Icons.cleaning_services,
  };

  final TextEditingController topSearchController = TextEditingController();
  final TextEditingController serviceSearchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    serviceSearchController.addListener(() {
      setState(() {
        searchQuery = serviceSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Top Search + Cart ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: topSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------------- Banner Placeholder ----------------
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Banner Placeholder',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Search Field (functional) ----------------
              TextField(
                controller: serviceSearchController,
                decoration: InputDecoration(
                  hintText: 'Search services by name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Welcome ----------------
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

              // ---------------- Service Management ----------------
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

              const SizedBox(height: 30),

              // ---------------- Cleaning Services Section (Carousel with Search) ----------------
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

                  final services = snapshot.data!.docs.where((service) {
                    final name = (service['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  if (services.isEmpty) {
                    return const Text('No matching services found.');
                  }

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
                          width: 160, // ~2 per viewport
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
