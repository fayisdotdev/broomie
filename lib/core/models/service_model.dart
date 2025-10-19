
class Service {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String duration;
  final double rating;
  final int ordersCount;
  final String imageUrl;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.duration,
    required this.rating,
    required this.ordersCount,
    required this.imageUrl,
  });

  factory Service.fromDoc(Map<String, dynamic> data, String docId) {
    return Service(
      id: docId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      ordersCount: (data['ordersCount'] ?? 0),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'duration': duration,
      'rating': rating,
      'ordersCount': ordersCount,
      'imageUrl': imageUrl,
    };
  }
}
