import 'package:broomie/core/models/cart_item_model.dart';
import 'package:broomie/core/providers/cart_provider.dart';
import 'package:broomie/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';



class CartsScreen extends ConsumerStatefulWidget {
  const CartsScreen({super.key});

  @override
  ConsumerState<CartsScreen> createState() => _CartsScreenState();
}

class _CartsScreenState extends ConsumerState<CartsScreen> {
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Carts'),
          backgroundColor: AppColorsPage.secondaryColor,
        ),
        body: Center(
          child: Text(
            'Please sign in to view your cart',
            style: TextStyle(color: AppColorsPage.textColor, fontSize: 16),
          ),
        ),
      );
    }

    final cartAsync = ref.watch(cartItemsProvider);
    final cartCtrl = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColorsPage.primaryColor,
      appBar: AppBar(
        title: const Text('My Carts'),
        backgroundColor: AppColorsPage.secondaryColor,
        elevation: 0,
      ),
      body: cartAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                        fontSize: 18, color: AppColorsPage.textColor),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPage.secondaryColor,
                    ),
                    child: const Text('Browse Services'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final it = items[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppColorsPage.lightBlue,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        leading: it.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  it.imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: AppColorsPage.lightGreen,
                                child: Text(
                                  it.name.isNotEmpty ? it.name[0] : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                        title: Text(
                          it.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsPage.textColor),
                        ),
                        subtitle: Text(
                          '₹${it.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: AppColorsPage.textColor),
                        ),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: AppColorsPage.secondaryColor),
                                onPressed: () async {
                                  if (it.quantity > 1) {
                                    final updated = CartItem(
                                      id: it.id,
                                      serviceId: it.serviceId,
                                      name: it.name,
                                      price: it.price,
                                      quantity: it.quantity - 1,
                                      imageUrl: it.imageUrl,
                                    );
                                    await cartCtrl.addItem(updated);
                                  } else {
                                    await cartCtrl.removeItem(it.id);
                                  }
                                },
                              ),
                              Text('${it.quantity}',
                                  style: TextStyle(
                                      color: AppColorsPage.textColor)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: AppColorsPage.secondaryColor),
                                onPressed: () async {
                                  final updated = CartItem(
                                    id: it.id,
                                    serviceId: it.serviceId,
                                    name: it.name,
                                    price: it.price,
                                    quantity: it.quantity + 1,
                                    imageUrl: it.imageUrl,
                                  );
                                  await cartCtrl.addItem(updated);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red.shade400),
                                onPressed: () async {
                                  await cartCtrl.removeItem(it.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CartSummary(items: items),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error: $e',
              style: TextStyle(color: AppColorsPage.textColor)),
        ),
      ),
    );
  }
}

class CartSummary extends ConsumerWidget {
  final List<CartItem> items;

  const CartSummary({super.key, required this.items});

  double get total => items.fold(0.0, (s, it) => s + it.price * it.quantity);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColorsPage.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items: ${items.length}',
                  style: TextStyle(color: AppColorsPage.textColor),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: ₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorsPage.textColor),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final meta = {'notes': 'Booked from cart'};
                final ctrl = ref.read(cartControllerProvider.notifier);
                try {
                  await ctrl.createBooking(meta);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking created')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPage.secondaryColor),
              child: const Text('Create Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
