
class ReviewModel {
  final String customerName;
  final String customerPhone;
  final String customerDeviceToken;
  final String customerId;
  final String feedback;
  final String ratings;
  final dynamic createdAt;

  ReviewModel({
    required this.customerName,
    required this.customerPhone,
    required this.customerDeviceToken,
    required this.customerId,
    required this.feedback,
    required this.ratings,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerDeviceToken': customerDeviceToken,
      'customerId': customerId,
      'feedback': feedback,
      'ratings': ratings,
      'createdAt': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> json) {
    return ReviewModel(
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerDeviceToken: json['customerDeviceToken'],
      customerId: json['customerId'],
      feedback: json['feedback'],
      ratings: json['ratings'],
      createdAt: json['createdAt'],
    );
  }
}
