import 'dart:io';

import 'package:broomie/core/providers/category_provider.dart';
import 'package:broomie/core/providers/duration_provider.dart';
import 'package:broomie/core/providers/service_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddServiceScreen extends ConsumerStatefulWidget {
  const AddServiceScreen({super.key});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _ratingController = TextEditingController();
  final _ordersController = TextEditingController();

  Uint8List? _webImage;
  File? _mobileImage;

  String? _selectedCategory;
  String? _selectedDuration;

  @override
  void initState() {
    super.initState();
    // categories and durations are loaded via providers; no manual fetch
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    if (kIsWeb) {
      setState(() => _webImage = result.files.first.bytes);
    } else {
      setState(() => _mobileImage = File(result.files.first.path!));
    }
  }

  Future<void> _saveService() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final desc = _descController.text.trim();
    final category = _selectedCategory;
    final duration = _selectedDuration;
    final rating = double.tryParse(_ratingController.text.trim()) ?? 0.0;
    final orders = int.tryParse(_ordersController.text.trim()) ?? 0;

    if (name.isEmpty || price <= 0 || category == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final notifier = ref.read(addServiceProvider.notifier);
    await notifier.addService(
      name: name,
      price: price,
      description: desc,
      category: category,
      duration: duration,
      rating: rating,
      ordersCount: orders,
      webImage: _webImage,
      mobileImage: _mobileImage,
    );

    ref.listen<AsyncValue<void>>(addServiceProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Service "$name" added successfully')),
          );
          Navigator.pop(context);
        },
        loading: () {
          // maybe show loading indicator
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving service: $e')),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final durationsAsync = ref.watch(durationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              durationsAsync.when(
                data: (durations) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        items: durations.map((d) {
                          return DropdownMenuItem<String>(
                            value: d.value,
                            child: Text(d.value),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedDuration = v),
                        decoration: const InputDecoration(
                          labelText: 'Select Duration',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final durationController = TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Add New Duration'),
                            content: TextField(
                              controller: durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (e.g., 30 mins)',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final val = durationController.text.trim();
                                  Navigator.pop(context);
                                  ref.read(addDurationProvider(val));
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading durations: $e'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (Optional, 0‑5)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ordersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Orders Count (Optional)'),
              ),
              const SizedBox(height: 10),

              categoriesAsync.when(
                data: (categories) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.name,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final nameController = TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Add New Category'),
                            content: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: 'Category Name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final val = nameController.text.trim();
                                  Navigator.pop(context);
                                  ref.read(addCategoryProvider(val));
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image (Optional)'),
              ),
              if (_webImage != null) Image.memory(_webImage!, height: 150),
              if (_mobileImage != null) Image.file(_mobileImage!, height: 150),
              const SizedBox(height: 20),

              Consumer(builder: (context, ref, _) {
                final state = ref.watch(addServiceProvider);
                return state.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveService,
                        child: const Text('Save Service'),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
