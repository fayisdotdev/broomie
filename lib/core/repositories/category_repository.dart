
import 'package:broomie/core/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CategoryRepository {
  final _categoryRef = FirebaseFirestore.instance.collection('categories');

  Stream<List<Category>> getCategoriesStream() {
    return _categoryRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<void> addCategory(String name) async {
    await _categoryRef.add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
