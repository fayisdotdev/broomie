import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String serviceId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromDoc(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      serviceId: data['serviceId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 1),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
