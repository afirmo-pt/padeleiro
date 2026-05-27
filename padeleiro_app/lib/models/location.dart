import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required String locationId,
    required String name,
    required String address,
    required bool isActive,
  }) = _Location;

  factory Location.fromMap(String id, Map<String, dynamic> data) {
    return Location(
      locationId: id,
      name: data['name'] as String,
      address: data['address'] as String,
      isActive: data['isActive'] as bool,
    );
  }
}

extension LocationMap on Location {
  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'name': name,
      'address': address,
      'isActive': isActive,
    };
  }
}
