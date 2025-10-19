import 'package:broomie/core/models/cart_item_model.dart';
import 'package:broomie/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          backgroundColor: AppColorsPage.secondaryColor,
        ),
        body: Center(
          child: Text(
            'Please sign in to view bookings',
            style: TextStyle(color: AppColorsPage.textColor, fontSize: 16),
          ),
        ),
      );
    }

    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (map, _) => map,
        );

    return Scaffold(
      backgroundColor: AppColorsPage.primaryColor,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: AppColorsPage.secondaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookingsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: TextStyle(color: AppColorsPage.textColor)),
            );
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: AppColorsPage.textColor, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, idx) {
              final d = docs[idx];
              final data = d.data();
              final ts = data['createdAt'] as Timestamp?;
              final created = ts?.toDate();
              final formatted = created != null
                  ? created.toLocal().toString().split('.').first
                  : 'Unknown';
              final itemsData = (data['items'] as List?) ?? [];
              final items = itemsData.map<CartItem>((e) {
                if (e is Map<String, dynamic>) {
                  return CartItem.fromDoc('', Map<String, dynamic>.from(e));
                }
                return CartItem.fromDoc('', <String, dynamic>{});
              }).toList();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: AppColorsPage.lightBlue,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking • $formatted',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColorsPage.textColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Items: ${items.length}',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColorsPage.textColor),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: items
                            .map((it) => Chip(
                                  backgroundColor: AppColorsPage.lightGreen,
                                  label: Text(
                                    '${it.name} x${it.quantity}',
                                    style: TextStyle(
                                        color: AppColorsPage.textColor),
                                  ),
                                ))
                            .toList(),
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
