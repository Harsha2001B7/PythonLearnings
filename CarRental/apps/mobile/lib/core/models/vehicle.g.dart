// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleSpecsImpl _$$VehicleSpecsImplFromJson(Map<String, dynamic> json) =>
    _$VehicleSpecsImpl(
      engine: json['engine'] as String?,
      power: json['power'] as String?,
      torque: json['torque'] as String?,
      range: json['range'] as String?,
      zeroToSixty: json['zeroToSixty'] as String?,
      topSpeed: json['topSpeed'] as String?,
      seats: (json['seats'] as num).toInt(),
      transmission: json['transmission'] as String,
      fuel: json['fuel'] as String,
      year: (json['year'] as num?)?.toInt(),
      doors: (json['doors'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$VehicleSpecsImplToJson(_$VehicleSpecsImpl instance) =>
    <String, dynamic>{
      'engine': instance.engine,
      'power': instance.power,
      'torque': instance.torque,
      'range': instance.range,
      'zeroToSixty': instance.zeroToSixty,
      'topSpeed': instance.topSpeed,
      'seats': instance.seats,
      'transmission': instance.transmission,
      'fuel': instance.fuel,
      'year': instance.year,
      'doors': instance.doors,
    };

_$VehicleImagesImpl _$$VehicleImagesImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImagesImpl(
      exterior:
          (json['exterior'] as List<dynamic>).map((e) => e as String).toList(),
      interior:
          (json['interior'] as List<dynamic>).map((e) => e as String).toList(),
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$$VehicleImagesImplToJson(_$VehicleImagesImpl instance) =>
    <String, dynamic>{
      'exterior': instance.exterior,
      'interior': instance.interior,
      'thumbnail': instance.thumbnail,
    };

_$VehicleColorImpl _$$VehicleColorImplFromJson(Map<String, dynamic> json) =>
    _$VehicleColorImpl(
      name: json['name'] as String,
      hex: json['hex'] as String,
    );

Map<String, dynamic> _$$VehicleColorImplToJson(_$VehicleColorImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'hex': instance.hex,
    };

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      category: json['category'] as String,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      pricePerWeek: (json['pricePerWeek'] as num?)?.toDouble(),
      specs: VehicleSpecs.fromJson(json['specs'] as Map<String, dynamic>),
      images: VehicleImages.fromJson(json['images'] as Map<String, dynamic>),
      colors: (json['colors'] as List<dynamic>)
          .map((e) => VehicleColor.fromJson(e as Map<String, dynamic>))
          .toList(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      featured: json['featured'] as bool,
      available: json['available'] as bool,
      badge: json['badge'] as String?,
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'tagline': instance.tagline,
      'category': instance.category,
      'pricePerDay': instance.pricePerDay,
      'pricePerWeek': instance.pricePerWeek,
      'specs': instance.specs,
      'images': instance.images,
      'colors': instance.colors,
      'features': instance.features,
      'featured': instance.featured,
      'available': instance.available,
      'badge': instance.badge,
    };
