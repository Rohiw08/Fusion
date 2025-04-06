import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the base Dio instance
final dioProvider = Provider<Dio>((ref) {
  // Correct base URL for the CoinMarketCap Pro API
  const String baseUrl = "https://pro-api.coinmarketcap.com"; // Corrected

  const String apiKey = "97c8f49e-dace-45ca-9c1d-7356af50614f"; // Your API Key

  final options = BaseOptions(
    baseUrl: baseUrl, // Use the corrected base URL
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      // Common headers for all requests using this Dio instance
      'Accept': 'application/json',
      'X-CMC_PRO_API_KEY': apiKey,
    },
    // Automatically checks if status code is 2xx
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
  );

  final dio = Dio(options);

  // Optional: Add interceptors for logging, error handling, etc.
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
