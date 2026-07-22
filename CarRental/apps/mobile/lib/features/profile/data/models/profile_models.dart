
class BookingModel {
  const BookingModel({
    required this.id,
    required this.vehicleId,
    this.startDate,
    this.endDate,
    this.totalPrice,
    required this.status,
    this.createdAt,
    this.vehicle,
  });

  final int id;
  final int vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalPrice;
  final String status;
  final DateTime? createdAt;
  final BookingVehicleModel? vehicle;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? (json['vehicleId'] as num?)?.toInt() ?? 0,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : (json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'] as String) : (json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? (json['totalPrice'] as num?)?.toDouble(),
      status: (json['status'] as String?) ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null),
      vehicle: json['vehicle'] != null ? BookingVehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>) : null,
    );
  }
}

class BookingVehicleModel {
  const BookingVehicleModel({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    this.primaryImage,
  });

  final int id;
  final String name;
  final String model;
  final int year;
  final String? primaryImage;

  factory BookingVehicleModel.fromJson(Map<String, dynamic> json) {
    return BookingVehicleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2023,
      primaryImage: json['primaryImage'] as String?,
    );
  }
}

class FaqModel {
  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  final int id;
  final String question;
  final String answer;

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
    );
  }
}

class SiteSettingModel {
  const SiteSettingModel({
    required this.id,
    required this.key,
    required this.value,
    this.description,
  });

  final int id;
  final String key;
  final String value;
  final String? description;

  factory SiteSettingModel.fromJson(Map<String, dynamic> json) {
    return SiteSettingModel(
      id: json['id'] as int,
      key: (json['key'] as String?) ?? '',
      value: (json['value'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }
}
