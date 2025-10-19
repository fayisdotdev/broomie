import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

// Provide the repository
final serviceRepositoryProvider = Provider((ref) => ServiceRepository());

// A notifier/provider for adding a service
class AddServiceNotifier extends AsyncNotifier<void> {
  AddServiceNotifier();

  @override
  Future<void> build() async {
    // nothing in build
  }

  Future<void> addService({
    required String name,
    required double price,
    required String description,
    required String category,
    required String duration,
    required double rating,
    required int ordersCount,
    Uint8List? webImage,
    File? mobileImage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(serviceRepositoryProvider);
      final imageUrl =
          await repo.uploadImage(
            name,
            webImage: webImage,
            mobileImage: mobileImage,
          ) ??
          '';
      final service = Service(
        name: name,
        price: price,
        description: description,
        category: category,
        duration: duration,
        rating: rating,
        ordersCount: ordersCount,
        imageUrl: imageUrl,
      );
      await repo.addService(service);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final addServiceProvider = AsyncNotifierProvider<AddServiceNotifier, void>(
  () => AddServiceNotifier(),
);

// Stream provider for services filtered by category
final servicesByCategoryProvider = StreamProvider.family<List<Service>, String>(
  (ref, category) {
    final repo = ref.watch(serviceRepositoryProvider);
    return repo.getServicesByCategoryStream(category);
  },
);
