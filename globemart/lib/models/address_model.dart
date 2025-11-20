import 'package:uuid/uuid.dart';

class AddressModel {
  final String id;
  final String label;
  final String fullAddress;
  final double? lat;
  final double? lng;

  AddressModel({
    String? id,
    required this.label,
    required this.fullAddress,
    this.lat,
    this.lng,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'lat': lat,
      'lng': lng,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      label: map['label'],
      fullAddress: map['fullAddress'],
      lat: map['lat'],
      lng: map['lng'],
    );
  }
}
