import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final _servicesRef = FirebaseFirestore.instance.collection('services');

  Future<String?> uploadImage(
    String serviceName, {
    Uint8List? webImage,
    File? mobileImage,
  }) async {
    if (webImage == null && mobileImage == null) {
      return null;
    }
    final safeServiceName = serviceName.replaceAll(' ', '_');
    final fileName = mobileImage != null
        ? mobileImage.path.split('/').last
        : DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(
      'services/$safeServiceName/$fileName',
    );
    UploadTask uploadTask;
    if (webImage != null) {
      uploadTask = ref.putData(webImage);
    } else {
      uploadTask = ref.putFile(mobileImage!);
    }
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> addService(Service service) async {
    await _servicesRef.add({
      ...service.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream services filtered by category
  Stream<List<Service>> getServicesByCategoryStream(String category) {
    return _servicesRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Service.fromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Service>> getServicesByCategory(String category) {
    return getServicesByCategoryStream(category);
  }
}
