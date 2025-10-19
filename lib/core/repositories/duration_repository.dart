import 'package:broomie/core/models/duration_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DurationRepository {
  final _durationRef = FirebaseFirestore.instance.collection('durations');

  Stream<List<DurationModel>> getDurationsStream() {
    return _durationRef
        .orderBy('value')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DurationModel.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<void> addDuration(String value) async {
    await _durationRef.add({
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
