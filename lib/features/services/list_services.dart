import 'package:broomie/core/providers/category_provider.dart';
import 'package:broomie/core/providers/service_provider.dart';
import 'package:broomie/core/providers/cart_provider.dart';
import 'package:broomie/core/models/cart_item_model.dart';
import 'package:broomie/styles/app_colors.dart';
import 'package:broomie/features/services/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

final _selectionProvider = StateProvider<Map<String, int>>((ref) => {});

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoriesProvider);

    return categoryAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Scaffold(
            backgroundColor: AppColorsPage.primaryColor,
            body: Center(
              child: Text(
                'No categories found.',
                style: TextStyle(color: AppColorsPage.mutedText, fontSize: 16),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            backgroundColor: AppColorsPage.primaryColor,
            appBar: AppBar(
              title: const Text('Services'),
              backgroundColor: AppColorsPage.secondaryColor,
              elevation: 0,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColorsPage.accentColor,
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ServiceCard(service: service),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: qty > 0
                                              ? AppColorsPage.secondaryColor
                                              : Colors.grey.shade400,
                                        ),
                                        onPressed: qty > 0
                                            ? () {
                                                final map =
                                                    Map<String, int>.from(
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
                                      Text(
                                        '$qty',
                                        style: TextStyle(
                                          color: AppColorsPage.mutedText,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: AppColorsPage.secondaryColor,
                                        ),
                                        onPressed: () {
                                          final map = Map<String, int>.from(
                                            selections,
                                          );
                                          map[service.id ?? service.name] =
                                              (map[service.id ??
                                                      service.name] ??
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
                              ],
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            'Error loading services',
                            style: TextStyle(color: AppColorsPage.mutedText),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsPage.secondaryLight,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (context, r, _) {
                                final sel = r.watch(_selectionProvider);
                                double total = 0;
                                int count = 0;
                                final sAsync = r.watch(
                                  servicesByCategoryProvider(category.name),
                                );
                                sAsync.whenData((slist) {
                                  for (final s in slist) {
                                    final q = sel[s.id ?? s.name] ?? 0;
                                    if (q > 0) {
                                      count += q;
                                      total += s.price * q;
                                    }
                                  }
                                });
                                return Text(
                                  'Items: $count   Total: \$${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsPage.mutedText,
                                  ),
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
                                final foundIndex = sList.indexWhere(
                                  (s) => (s.id ?? s.name) == entry.key,
                                );
                                if (foundIndex == -1) continue;
                                final found = sList[foundIndex];
                                final item = CartItem(
                                  id: '',
                                  serviceId: found.id ?? '',
                                  name: found.name,
                                  price: found.price,
                                  quantity: entry.value,
                                  imageUrl: found.imageUrl,
                                );
                                await controller.addItem(item);
                              }
                              ref.read(_selectionProvider.notifier).state = {};
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorsPage.secondaryColor,
                            ),
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
      loading: () => Scaffold(
        backgroundColor: AppColorsPage.primaryColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColorsPage.primaryColor,
        body: Center(
          child: Text(
            'Error loading categories',
            style: TextStyle(color: AppColorsPage.mutedText),
          ),
        ),
      ),
    );
  }
}
