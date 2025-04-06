import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/dio_providers_dex.dart';
import 'package:fusion/models/token_profile.dart';

final tokenProfilesProvider = FutureProvider<List<TokenProfile>>((ref) async {
  final dio = ref.watch(dioProvider);
  final String endpoint = dotenv.env['CMCENDPOINT2']!;

  try {
    final response = await dio.get(endpoint);
    if (response.data is List) {
      final List<dynamic> responseData = response.data as List<dynamic>;
      final profiles = responseData
          .where(
              (item) => item is Map<String, dynamic>) // Ensure items are Maps
          .map((item) => TokenProfile.fromJson(item as Map<String, dynamic>))
          .toList();
      return profiles;
    } else {
      throw Exception('Unexpected API response format: Expected a List.');
    }
  } on DioException catch (e) {
    String errorMessage = 'Failed to fetch data.';
    if (e.response != null) {
      errorMessage +=
          ' Status: ${e.response?.statusCode}, Data: ${e.response?.data}';
    } else {
      errorMessage += ' Error: ${e.message}';
    }
    print("DioException fetching profiles: $errorMessage"); // Log error
    throw Exception(errorMessage);
  } catch (e) {
    print("Error fetching profiles: $e"); // Log error
    throw Exception('An unexpected error occurred: $e');
  }
});
