// lib/models/address_model.dart

import 'package:uuid/uuid.dart';

class AddressModel {
  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String rt;
  final String rw;
  final String kelurahan;
  final String kecamatan;
  final String city;
  final String province;
  final String postalCode;
  final double? lat;
  final double? lng;
  final bool isDefault;

  AddressModel({
    String? id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    this.rt = '',
    this.rw = '',
    this.kelurahan = '',
    this.kecamatan = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.lat,
    this.lng,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'fullAddress': fullAddress,
      'rt': rt,
      'rw': rw,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      label: map['label'] ?? '',
      recipientName: map['recipientName'] ?? '',
      phone: map['phone'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      rt: map['rt'] ?? '',
      rw: map['rw'] ?? '',
      kelurahan: map['kelurahan'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      lat: map['lat'] != null ? (map['lat'] as num).toDouble() : null,
      lng: map['lng'] != null ? (map['lng'] as num).toDouble() : null,
      isDefault: map['isDefault'] == true,
    );
  }

  /// Friendly single-line representation for list subtitle
  String toFriendlyString() {
    final parts = <String>[];
    if (recipientName.isNotEmpty) parts.add(recipientName);
    if (phone.isNotEmpty) parts.add(phone);
    if (fullAddress.isNotEmpty) parts.add(fullAddress);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(' • ');
  }

  AddressModel copyWith({
    String? label,
    String? recipientName,
    String? phone,
    String? fullAddress,
    String? rt,
    String? rw,
    String? kelurahan,
    String? kecamatan,
    String? city,
    String? province,
    String? postalCode,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      kelurahan: kelurahan ?? this.kelurahan,
      kecamatan: kecamatan ?? this.kecamatan,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
