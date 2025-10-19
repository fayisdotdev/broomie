class DurationModel {
  final String id;
  final String value;

  DurationModel({required this.id, required this.value});

  factory DurationModel.fromDoc(String id, Map<String, dynamic> data) {
    return DurationModel(
      id: id,
      value: data['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
    };
  }
}
