import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
class VehicleSpecs with _$VehicleSpecs {
  const factory VehicleSpecs({
    String? engine,
    String? power,
    String? torque,
    String? range,
    String? zeroToSixty,
    String? topSpeed,
    required int seats,
    required String transmission,
    required String fuel,
    int? year,
    int? doors,
  }) = _VehicleSpecs;

  factory VehicleSpecs.fromJson(Map<String, dynamic> json) =>
      _$VehicleSpecsFromJson(json);
}

@freezed
class VehicleImages with _$VehicleImages {
  const factory VehicleImages({
    required List<String> exterior,
    required List<String> interior,
    required String thumbnail,
  }) = _VehicleImages;

  factory VehicleImages.fromJson(Map<String, dynamic> json) =>
      _$VehicleImagesFromJson(json);
}

@freezed
class VehicleColor with _$VehicleColor {
  const factory VehicleColor({
    required String name,
    required String hex,
  }) = _VehicleColor;

  factory VehicleColor.fromJson(Map<String, dynamic> json) =>
      _$VehicleColorFromJson(json);
}

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required int id,
    required String slug,
    required String name,
    required String tagline,
    required String category,
    required double pricePerDay,
    double? pricePerWeek,
    required VehicleSpecs specs,
    required VehicleImages images,
    required List<VehicleColor> colors,
    required List<String> features,
    required bool featured,
    required bool available,
    String? badge,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}
