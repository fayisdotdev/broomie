import 'package:broomie/core/models/category_model.dart';
import 'package:broomie/core/repositories/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Repository provider
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

// Stream provider
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoriesStream();
});

// Add category logic (if needed)
final addCategoryProvider = Provider.family<Future<void>, String>((ref, name) {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.addCategory(name);
});
