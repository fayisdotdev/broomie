import 'dart:io';
import 'package:broomie/core/providers/category_provider.dart';
import 'package:broomie/core/providers/duration_provider.dart';
import 'package:broomie/core/providers/service_provider.dart';
import 'package:broomie/styles/app_colors.dart';
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
        loading: () {},
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving service: $e')),
          );
        },
      );
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsPage.secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsPage.secondaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final durationsAsync = ref.watch(durationsProvider);

    return Scaffold(
      backgroundColor: AppColorsPage.primaryColor,
      appBar: AppBar(
        title: const Text('Add Service'),
        backgroundColor: AppColorsPage.secondaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Service Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Price'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: _inputDecoration('Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            durationsAsync.when(
              data: (durations) => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      items: durations
                          .map((d) => DropdownMenuItem<String>(
                                value: d.value,
                                child: Text(d.value),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDuration = v),
                      decoration: _inputDecoration('Select Duration'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColorsPage.secondaryColor),
                    onPressed: () async {
                      final controller = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Add New Duration'),
                          content: TextField(
                            controller: controller,
                            decoration: _inputDecoration('Duration (e.g., 30 mins)'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                final val = controller.text.trim();
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
            const SizedBox(height: 12),
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Rating (Optional, 0‑5)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ordersController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Orders Count (Optional)'),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem<String>(
                                value: c.name,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      decoration: _inputDecoration('Select Category'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColorsPage.secondaryColor),
                    onPressed: () async {
                      final controller = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Add New Category'),
                          content: TextField(
                            controller: controller,
                            decoration: _inputDecoration('Category Name'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                final val = controller.text.trim();
                                Navigator.pop(context);
                                ref.read(addCategoryProvider(val));
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
              error: (e, _) => Text('Error loading categories: $e'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image (Optional)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPage.secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (_webImage != null) Image.memory(_webImage!, height: 150),
            if (_mobileImage != null) Image.file(_mobileImage!, height: 150),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(addServiceProvider);
              return state.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveService,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColorsPage.secondaryColor,
                      ),
                      child: const Text('Save Service'),
                    );
            }),
          ],
        ),
      ),
    );
  }
}
