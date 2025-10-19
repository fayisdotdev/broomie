import 'package:broomie/core/models/duration_model.dart';
import 'package:broomie/core/repositories/duration_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Repository provider
final durationRepositoryProvider = Provider((ref) => DurationRepository());

// Stream provider
final durationsProvider = StreamProvider<List<DurationModel>>((ref) {
  final repository = ref.watch(durationRepositoryProvider);
  return repository.getDurationsStream();
});

// Add duration logic (if needed)
final addDurationProvider = Provider.family<Future<void>, String>((ref, value) {
  final repo = ref.read(durationRepositoryProvider);
  return repo.addDuration(value);
});
