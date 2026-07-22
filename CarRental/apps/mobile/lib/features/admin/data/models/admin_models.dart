class AdminStatsModel {
  const AdminStatsModel({
    required this.totalVehicles,
    required this.availableVehicles,
    required this.bookedVehicles,
    required this.totalUsers,
    required this.todayBookings,
    required this.totalTestimonials,
    required this.totalCategories,
    required this.totalBrands,
    required this.monthlyRevenue,
  });

  final int totalVehicles;
  final int availableVehicles;
  final int bookedVehicles;
  final int totalUsers;
  final int todayBookings;
  final int totalTestimonials;
  final int totalCategories;
  final int totalBrands;
  final double monthlyRevenue;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalVehicles: (json['totalVehicles'] as int?) ?? 0,
      availableVehicles: (json['availableVehicles'] as int?) ?? 0,
      bookedVehicles: (json['bookedVehicles'] as int?) ?? 0,
      totalUsers: (json['totalUsers'] as int?) ?? 0,
      todayBookings: (json['todayBookings'] as int?) ?? 0,
      totalTestimonials: (json['totalTestimonials'] as int?) ?? 0,
      totalCategories: (json['totalCategories'] as int?) ?? 0,
      totalBrands: (json['totalBrands'] as int?) ?? 0,
      monthlyRevenue: json['monthlyRevenue'] != null ? (json['monthlyRevenue'] as num).toDouble() : 0.0,
    );
  }
}

class AdminBookingModel {
  const AdminBookingModel({
    required this.id,
    this.userId,
    this.vehicleId,
    this.startDate,
    this.endDate,
    this.totalPrice,
    required this.status,
    this.createdAt,
    this.user,
    this.vehicle,
  });

  final int id;
  final int? userId;
  final int? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalPrice;
  final String status;
  final DateTime? createdAt;
  final AdminBookingUserModel? user;
  final AdminBookingVehicleModel? vehicle;

  factory AdminBookingModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? (json['user_id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num?)?.toInt() ?? (json['vehicle_id'] as num?)?.toInt(),
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      status: (json['status'] as String?) ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) 
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null),
      user: json['user'] != null ? AdminBookingUserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
      vehicle: json['vehicle'] != null ? AdminBookingVehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>) : null,
    );
  }
}

class AdminBookingUserModel {
  const AdminBookingUserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;

  String get displayName => (firstName?.isNotEmpty == true) 
      ? '$firstName ${lastName ?? ""}'.trim()
      : email.split('@').first;

  factory AdminBookingUserModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] as String?) ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String?,
      lastName: json['lastName'] as String? ?? json['last_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class AdminBookingVehicleModel {
  const AdminBookingVehicleModel({
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

  factory AdminBookingVehicleModel.fromJson(Map<String, dynamic> json) {
    return AdminBookingVehicleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2023,
      primaryImage: json['primaryImage'] as String?,
    );
  }
}

class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    required this.status,
  });

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final String status;

  String get displayName => (firstName?.isNotEmpty == true)
      ? '$firstName ${lastName ?? ""}'.trim()
      : email.split('@').first;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] as String?) ?? '',
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'USER',
      status: (json['status'] as String?) ?? 'active',
    );
  }
}
