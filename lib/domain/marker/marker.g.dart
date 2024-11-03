// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Marker _$MarkerFromJson(Map<String, dynamic> json) => Marker(
      iconIndex: (json['iconIndex'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toInt(),
      longitude: (json['longitude'] as num).toInt(),
    );

Map<String, dynamic> _$MarkerToJson(Marker instance) => <String, dynamic>{
      'iconIndex': instance.iconIndex,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
