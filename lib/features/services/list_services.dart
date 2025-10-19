// lib/features/services/screens/services_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      _isLoadingCategories = false;
    });
  }

  // Map category name to icons
  static const Map<String, IconData> categoryIcons = {
    'Residential': Icons.home,
    'Commercial': Icons.apartment,
    'Specialized': Icons.cleaning_services,
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No categories available.')),
      );
    }

    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Services'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: TabBarView(
          children: _categories.map((category) {
            // For each tab, show services filtered by this category
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .where('category', isEqualTo: category)
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
                    final serviceDoc = services[index];
                    final serviceData =
                        serviceDoc.data() as Map<String, dynamic>? ?? {};

                    final name = serviceData['name'] ?? 'Unnamed Service';
                    final price = serviceData['price'] ?? 0;
                    final description =
                        serviceData['description'] ?? 'No description';
                    final imageUrl = serviceData['imageUrl'] ?? '';
                    final duration = serviceData['duration'] ?? 'Not specified';
                    final rating = serviceData['rating'] ?? 0.0;
                    final ordersCount = serviceData['ordersCount'] ?? 0;
                    final categoryIcon =
                        categoryIcons[category] ?? Icons.cleaning_services;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image left
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Details right
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category
                                  Row(
                                    children: [
                                      Icon(categoryIcon,
                                          size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 6),
                                      Text(
                                        category,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Service name
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),

                                  // Description
                                  Text(
                                    description,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Price & Duration
                                  Row(
                                    children: [
                                      Text(
                                        'Price: \$${price.toString()}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Duration: $duration',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Rating & Orders
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toString(),
                                        style:
                                            const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Orders: $ordersCount',
                                        style:
                                            const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
