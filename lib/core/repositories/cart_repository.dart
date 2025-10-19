import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCartRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  Future<void> addOrUpdateCartItem(String uid, CartItem item) async {
    final ref = _userCartRef(uid);
    // If item id is provided and exists update, else add new
    if (item.id.isNotEmpty) {
      await ref.doc(item.id).set(item.toMap(), SetOptions(merge: true));
    } else {
      await ref.add(item.toMap());
    }
  }

  Future<void> removeCartItem(String uid, String itemId) async {
    await _userCartRef(uid).doc(itemId).delete();
  }

  Stream<List<CartItem>> cartItemsStream(String uid) {
    return _userCartRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CartItem.fromDoc(d.id, d.data())).toList(),
        );
  }

  Future<void> clearCart(String uid) async {
    final batch = _firestore.batch();
    final snap = await _userCartRef(uid).get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Create a booking document from current cart items and clear cart
  Future<void> createBookingFromCart(
    String uid,
    Map<String, dynamic> bookingMeta,
  ) async {
    final cartSnap = await _userCartRef(uid).get();
    final items = cartSnap.docs.map((d) => d.data()).toList();
    final bookingRef = _firestore.collection('bookings').doc();
    await bookingRef.set({
      'userId': uid,
      'items': items,
      ...bookingMeta,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // clear cart
    await clearCart(uid);
  }
}
