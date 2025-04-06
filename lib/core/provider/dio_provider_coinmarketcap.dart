import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final String baseUrl = dotenv.env['COINMARKETCAPBASEURI']!;
  final String apiKey = dotenv.env['COINMARKETCAPAPIKEY']!;

  final options = BaseOptions(
    baseUrl: baseUrl, // Use the corrected base URL
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'X-CMC_PRO_API_KEY': apiKey,
    },
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
  );

  final dio = Dio(options);

  return dio;
});
