class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.userId,
    required this.senderType,
    required this.title,
    required this.message,
    required this.notificationType,
    this.imageUrl,
    this.bookingId,
    this.vehicleId,
    this.vehicleName,
    this.vehicleImage,
    this.bookingReference,
    required this.status,
    required this.priority,
    required this.isRead,
    this.actionRoute,
    this.actionPayload,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String senderType;
  final String title;
  final String message;
  final String notificationType;
  final String? imageUrl;
  final int? bookingId;
  final int? vehicleId;
  final String? vehicleName;
  final String? vehicleImage;
  final String? bookingReference;
  final String status;
  final String priority;
  final bool isRead;
  final String? actionRoute;
  final String? actionPayload;
  final DateTime createdAt;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? (json['userId'] as num?)?.toInt() ?? 0,
      senderType: (json['sender_type'] as String?) ?? (json['senderType'] as String?) ?? 'system',
      title: (json['title'] as String?) ?? 'Notification',
      message: (json['message'] as String?) ?? '',
      notificationType: (json['notification_type'] as String?) ?? (json['notificationType'] as String?) ?? 'general',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      bookingId: (json['booking_id'] as num?)?.toInt() ?? (json['bookingId'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? (json['vehicleId'] as num?)?.toInt(),
      vehicleName: json['vehicle_name'] as String? ?? json['vehicleName'] as String?,
      vehicleImage: json['vehicle_image'] as String? ?? json['vehicleImage'] as String?,
      bookingReference: json['booking_reference'] as String? ?? json['bookingReference'] as String?,
      status: (json['status'] as String?) ?? 'sent',
      priority: (json['priority'] as String?) ?? 'high',
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      actionRoute: json['action_route'] as String? ?? json['actionRoute'] as String?,
      actionPayload: json['action_payload'] as String? ?? json['actionPayload'] as String?,
      createdAt: json['created_at'] != null 
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()) : DateTime.now()),
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      userId: userId,
      senderType: senderType,
      title: title,
      message: message,
      notificationType: notificationType,
      imageUrl: imageUrl,
      bookingId: bookingId,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      vehicleImage: vehicleImage,
      bookingReference: bookingReference,
      status: status,
      priority: priority,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      createdAt: createdAt,
    );
  }
}
