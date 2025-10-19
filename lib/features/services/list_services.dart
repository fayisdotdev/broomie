// lib/features/services/screens/services_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesListScreen extends StatelessWidget {
  const ServicesListScreen({super.key});

  // Map category name to icons
  static const Map<String, IconData> categoryIcons = {
    'Residential': Icons.home,
    'Commercial': Icons.apartment,
    'Specialized': Icons.cleaning_services,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services available.'));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final name = service['name'] ?? '';
              final price = service['price'] ?? 0;
              final description = service['description'] ?? '';
              final imageUrl = service['imageUrl'] ?? '';
              final category = service['category'] ?? 'Uncategorized';
              final categoryIcon =
                  categoryIcons[category] ?? Icons.cleaning_services;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Category row
                      Row(
                        children: [
                          Icon(categoryIcon, size: 20, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Service name
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),

                      // Price
                      Text(
                        'Price: \$${price.toString()}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
