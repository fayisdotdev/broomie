// lib/features/services/screens/add_service_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  Uint8List? _webImage; // for web
  File? _mobileImage; // for mobile
  String? _uploadedImageUrl;

  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = []; // {name: '', icon: IconData}
  Map<String, IconData> _defaultIcons = {
    'Residential': Icons.home,
    'Commercial': Icons.apartment,
    'Specialized': Icons.cleaning_services,
  };
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'icon': _defaultIcons[doc['name']] ?? Icons.cleaning_services
        };
      }).toList();
    });
  }

  Future<void> _addNewCategory(String name) async {
    if (name.isEmpty) return;
    final icon = _defaultIcons[name] ?? Icons.cleaning_services;
    await FirebaseFirestore.instance.collection('categories').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {
      _categories.add({'name': name, 'icon': icon});
      _selectedCategory = name;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    if (kIsWeb) {
      setState(() => _webImage = result.files.first.bytes);
      debugPrint('Web image selected, size: ${_webImage?.lengthInBytes}');
    } else {
      setState(() => _mobileImage = File(result.files.first.path!));
      debugPrint('Mobile image selected: ${_mobileImage!.path}');
    }
  }

  Future<String?> _uploadImage(String serviceName) async {
    try {
      if (_webImage == null && _mobileImage == null) {
        debugPrint('No image selected, skipping upload.');
        return null;
      }

      final safeServiceName = serviceName.replaceAll(' ', '_');
      final fileName = kIsWeb
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _mobileImage!.path.split('/').last;

      final ref = FirebaseStorage.instance
          .ref()
          .child('services/$safeServiceName/$fileName');

      debugPrint('Uploading image to path: services/$safeServiceName/$fileName');

      UploadTask uploadTask;
      if (kIsWeb && _webImage != null) {
        uploadTask = ref.putData(_webImage!);
      } else if (!kIsWeb && _mobileImage != null) {
        uploadTask = ref.putFile(_mobileImage!);
      } else {
        return null;
      }

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully! URL: $url');
      return url;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _saveService() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final desc = _descController.text.trim();
    final category = _selectedCategory;

    if (name.isEmpty || price.isEmpty || category == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      _uploadedImageUrl = await _uploadImage(name);

      debugPrint('Saving service "$name" to Firestore...');
      await FirebaseFirestore.instance.collection('services').add({
        'name': name,
        'price': double.tryParse(price) ?? 0,
        'description': desc,
        'category': category,
        'imageUrl': _uploadedImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Service "$name" added successfully')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Firestore error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error saving service')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Service name, price, description
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

              // Category dropdown with add option
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['name'] as String,
                          child: Row(
                            children: [
                              Icon(c['icon'], size: 20),
                              const SizedBox(width: 8),
                              Text(c['name'] as String),
                            ],
                          ),
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
                            decoration: const InputDecoration(
                              labelText: 'Category Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                Navigator.pop(context);
                                _addNewCategory(name);
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
              const SizedBox(height: 10),

              // Image picker
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image (Optional)'),
              ),
              if (_webImage != null) Image.memory(_webImage!, height: 150),
              if (_mobileImage != null) Image.file(_mobileImage!, height: 150),
              const SizedBox(height: 20),

              // Save button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveService,
                      child: const Text('Save Service'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
