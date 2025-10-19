
import 'dart:typed_data';
import 'package:broomie/core/models/service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ServiceRepository {
  final _serviceRef = FirebaseFirestore.instance.collection('services');

  Stream<List<Service>> getServicesByCategory(String category) {
    return _serviceRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Service.fromDoc(doc.data(), doc.id))
            .toList());
  }

  Future<void> addService(Service service) {
    return _serviceRef.add({
      ...service.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadServiceImage(String serviceName, Uint8List data) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('services/$serviceName/$fileName');

    await ref.putData(data);
    return ref.getDownloadURL();
  }
}
