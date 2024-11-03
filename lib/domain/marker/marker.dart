import 'package:json_annotation/json_annotation.dart';

part 'marker.g.dart';

@JsonSerializable()
class Marker {
  final int iconIndex;
  final String name;
  final int latitude;
  final int longitude;

  Marker({
    required this.iconIndex,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Marker.defaultInstance() {
    return Marker(
      iconIndex: -1,
      name: 'test',
      latitude: 0,
      longitude: 0,
    );
  }

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);

  Map<String, dynamic> toJson() => _$MarkerToJson(this);

  factory Marker.fromFirestore(Map<String, dynamic> firestoreData) {
    return Marker(
      iconIndex: firestoreData['iconIndex'] as int,
      name: firestoreData['name'] as String,
      latitude: firestoreData['latitude'] as int,
      longitude: firestoreData['longitude'] as int,
    );
  }
}