// lib/features/token_profiles/providers/token_profiles_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/dio_providers_dex.dart';
import 'package:fusion/models/token_profile.dart';

// FutureProvider to fetch the list of token profiles
final tokenProfilesProvider = FutureProvider<List<TokenProfile>>((ref) async {
  // Get Dio instance from provider
  final dio = ref.watch(dioProvider);
  // Define the API endpoint path
  const String endpoint = "/token-profiles/latest/v1";

  try {
    // Make the GET request
    final response = await dio.get(endpoint);

    // Check if the response data is a List
    if (response.data is List) {
      final List<dynamic> responseData = response.data as List<dynamic>;
      // Map the list of JSON objects to a list of TokenProfile objects
      final profiles = responseData
          .where(
              (item) => item is Map<String, dynamic>) // Ensure items are Maps
          .map((item) => TokenProfile.fromJson(item as Map<String, dynamic>))
          .toList();
      return profiles;
    } else {
      // Throw error if response data is not the expected list format
      throw Exception('Unexpected API response format: Expected a List.');
    }
  } on DioException catch (e) {
    // Handle Dio errors (network, status codes, etc.)
    String errorMessage = 'Failed to fetch data.';
    if (e.response != null) {
      errorMessage +=
          ' Status: ${e.response?.statusCode}, Data: ${e.response?.data}';
    } else {
      errorMessage += ' Error: ${e.message}';
    }
    print("DioException fetching profiles: $errorMessage"); // Log error
    throw Exception(errorMessage); // Re-throw for the provider error state
  } catch (e) {
    // Handle other errors (e.g., parsing)
    print("Error fetching profiles: $e"); // Log error
    throw Exception('An unexpected error occurred: $e');
  }
});
