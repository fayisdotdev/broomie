import 'package:broomie/core/providers/category_provider.dart';
import 'package:broomie/core/providers/service_provider.dart';
import 'package:broomie/core/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:broomie/core/providers/cart_provider.dart';
import 'package:broomie/core/models/cart_item_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final _selectionProvider = StateProvider<Map<String, int>>((ref) => {});

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoriesProvider);

    return categoryAsync.when(
      data: (List<Category> categories) {
        if (categories.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No categories found.')),
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Services'),
              bottom: TabBar(
                isScrollable: true,
                tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
              ),
            ),
            body: TabBarView(
              children: categories.map((category) {
                final servicesAsync = ref.watch(
                  servicesByCategoryProvider(category.name),
                );

                return Column(
                  children: [
                    Expanded(
                      child: servicesAsync.when(
                        data: (services) => ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            final selections = ref.watch(_selectionProvider);
                            final qty =
                                selections[service.id ?? service.name] ?? 0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: service.imageUrl.isNotEmpty
                                    ? Image.network(
                                        service.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(width: 64, height: 64),
                                title: Text(service.name),
                                subtitle: Text(
                                  '\$${service.price.toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: qty > 0
                                          ? () {
                                              final map = Map<String, int>.from(
                                                selections,
                                              );
                                              final newQty =
                                                  (map[service.id ??
                                                          service.name] ??
                                                      0) -
                                                  1;
                                              if (newQty <= 0) {
                                                map.remove(
                                                  service.id ?? service.name,
                                                );
                                              } else {
                                                map[service.id ??
                                                        service.name] =
                                                    newQty;
                                              }
                                              ref
                                                      .read(
                                                        _selectionProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  map;
                                            }
                                          : null,
                                    ),
                                    Text('$qty'),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () {
                                        final map = Map<String, int>.from(
                                          selections,
                                        );
                                        map[service.id ?? service.name] =
                                            (map[service.id ?? service.name] ??
                                                0) +
                                            1;
                                        ref
                                                .read(
                                                  _selectionProvider.notifier,
                                                )
                                                .state =
                                            map;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                    // Bottom summary and add to cart
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (c, r, _) {
                                final sel = r.watch(_selectionProvider);
                                double total = 0;
                                int count = 0;
                                final sAsync = r.watch(
                                  servicesByCategoryProvider(category.name),
                                );
                                sAsync.whenData((slist) {
                                  for (final s in slist) {
                                    final q = (sel[s.id ?? s.name] ?? 0);
                                    if (q > 0) {
                                      count += q;
                                      total += s.price * q;
                                    }
                                  }
                                });
                                return Text(
                                  'Items: $count   Total: \$${total.toStringAsFixed(2)}',
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login first'),
                                  ),
                                );
                                return;
                              }
                              final sel = ref.read(_selectionProvider);
                              if (sel.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No services selected'),
                                  ),
                                );
                                return;
                              }
                              final sAsync = ref.read(
                                servicesByCategoryProvider(category.name),
                              );
                              final sList = sAsync.asData?.value ?? [];
                              final controller = ref.read(
                                cartControllerProvider.notifier,
                              );
                              for (final entry in sel.entries) {
                                // ignore: avoid_init_to_null
                                var found = null;
                                for (final s in sList) {
                                  if ((s.id ?? s.name) == entry.key) {
                                    found = s;
                                    break;
                                  }
                                }
                                if (found == null) continue;
                                final service = found;
                                final item = CartItem(
                                  id: '',
                                  serviceId: service.id ?? '',
                                  name: service.name,
                                  price: service.price,
                                  quantity: entry.value,
                                  imageUrl: service.imageUrl,
                                );
                                await controller.addItem(item);
                              }
                              ref.read(_selectionProvider.notifier).state = {};
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            },
                            child: const Text('Add to cart'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error loading categories'))),
    );
  }
}
