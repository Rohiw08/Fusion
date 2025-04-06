// lib/core/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the base Dio instance
final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: "https://api.dexscreener.com", // Base URL for DexScreener
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
  );
  return Dio(options);
});
