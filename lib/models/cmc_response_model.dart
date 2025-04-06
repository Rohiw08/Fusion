import 'package:fusion/models/crypto_listing_model.dart';

class CmcResponse {
  final Status status;
  final List<CryptoListing> data;

  CmcResponse({required this.status, required this.data});

  factory CmcResponse.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'data' might be null or not a list
    var dataList = <CryptoListing>[];
    if (json['data'] != null && json['data'] is List) {
      dataList = (json['data'] as List)
          .map((item) => CryptoListing.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return CmcResponse(
      status: Status.fromJson(
          json['status'] as Map<String, dynamic>? ?? {}), // Handle null status
      data: dataList,
    );
  }
}

class Status {
  final String timestamp;
  final int errorCode;
  final String? errorMessage; // Can be null
  final int elapsed;
  final int creditCount;
  final String? notice; // Can be null

  Status({
    required this.timestamp,
    required this.errorCode,
    this.errorMessage,
    required this.elapsed,
    required this.creditCount,
    this.notice,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      timestamp: json['timestamp'] as String? ?? '',
      errorCode: json['error_code'] as int? ?? -1, // Use default error code
      errorMessage: json['error_message'] as String?,
      elapsed: json['elapsed'] as int? ?? 0,
      creditCount: json['credit_count'] as int? ?? 0,
      notice: json['notice'] as String?,
    );
  }
}
