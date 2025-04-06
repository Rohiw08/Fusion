// lib/core/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: dotenv.env['DEXSCREENERAPI']!,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
  );
  return Dio(options);
});
