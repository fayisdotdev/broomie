import 'package:broomie/core/providers/category_provider.dart';
import 'package:broomie/core/providers/service_provider.dart';
import 'package:broomie/features/services/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoriesProvider);

    return categoryAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Scaffold(body: Center(child: Text('No categories found.')));
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
                final servicesAsync = ref.watch(servicesByCategoryProvider(category.name));

                return servicesAsync.when(
                  data: (services) => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(service: services[index]);
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error loading categories'))),
    );
  }
}
