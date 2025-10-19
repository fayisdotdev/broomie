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
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ),
      );
    }

    final cartAsync = ref.watch(cartItemsProvider);
    final cartCtrl = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPage.secondaryColor,
                    ),
                    child: const Text(
                      'Browse Services',
                      style: TextStyle(color: Colors.white),
                    ),
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
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // image
                            if (it.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  it.imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              CircleAvatar(
                                backgroundColor: AppColorsPage.secondaryLight,
                                child: Text(
                                  it.name.isNotEmpty ? it.name[0] : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 12),

                            // name and price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    it.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${it.price.toStringAsFixed(2)}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            // quantity controls
                            Flexible(
                              flex: 0,
                              child: Wrap(
                                spacing: 0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColorsPage.secondaryColor,
                                    ),
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
                                  Text(
                                    '${it.quantity}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: AppColorsPage.secondaryColor,
                                    ),
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
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () async {
                                      await cartCtrl.removeItem(it.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          child: Text(
            'Error: $e',
            style: TextStyle(color: AppColorsPage.textColor),
          ),
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
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 350;
            return isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _summaryTexts(context),
                      const SizedBox(height: 12),
                      _actionButton(context, ref),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryTexts(context),
                      _actionButton(context, ref),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _summaryTexts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items: ${items.length}',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(
          'Total: ₹${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
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
        backgroundColor: AppColorsPage.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text('Create Booking', style: TextStyle(color: Colors.white)),
    );
  }
}
