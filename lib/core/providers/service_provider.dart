import 'package:broomie/core/models/service_model.dart';
import 'package:broomie/core/repositories/service_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Repository Provider
final serviceRepositoryProvider = Provider((ref) => ServiceRepository());

// Stream of services by category
final servicesByCategoryProvider = StreamProvider.family<List<Service>, String>((ref, category) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServicesByCategory(category);
});
