import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository());

/// Stream of cart items for the current user
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  final repo = ref.watch(cartRepositoryProvider);
  return repo.cartItemsStream(user.uid);
});

class CartController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addItem(CartItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.addOrUpdateCartItem(user.uid, item);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.removeCartItem(user.uid, itemId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.clearCart(user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createBooking(Map<String, dynamic> bookingMeta) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.createBookingFromCart(user.uid, bookingMeta);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, void>(
  () => CartController(),
);
