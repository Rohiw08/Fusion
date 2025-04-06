import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/dio_provider_coinmarketcap.dart';
import 'package:fusion/models/cmc_response_model.dart';
import 'package:fusion/models/crypto_listing_model.dart';

final cmcApiServiceProvider = Provider<CmcApiService>((ref) {
  // Provide the ref to the service constructor
  return CmcApiService(ref);
});

class CmcApiService {
  // Inject Ref to read the dioProvider
  final Ref _ref;
  CmcApiService(this._ref);

  // Endpoint path (base URL is now in dioProvider)
  final String _listingsEndpoint = "/v1/cryptocurrency/listings/latest";

  // Method to get listings using Dio
  Future<List<CryptoListing>> getLatestListings({int limit = 100}) async {
    // Read the Dio instance from the provider
    final Dio dio = _ref.read(dioProvider);

    try {
      final response = await dio.get(
        _listingsEndpoint,
        queryParameters: {
          'limit': limit,
          // Add other query parameters like 'start', 'convert' if needed
          // 'convert': 'USD' // Often needed if not default
        },
        // Headers like API Key and Accept are now set globally in dioProvider options
        // options: Options(headers: {...}) // Only needed for request-specific headers
      );

      // Dio automatically decodes JSON and throws DioException for bad status codes (based on validateStatus in provider)
      // So, if we reach here, statusCode is likely 2xx
      // The response data should already be a Map<String, dynamic>
      final jsonData = response.data as Map<String, dynamic>;
      final cmcResponse = CmcResponse.fromJson(jsonData);

      // Check for API-level errors indicated in the status object
      if (cmcResponse.status.errorCode != 0) {
        throw Exception(
            'CMC API Error (${cmcResponse.status.errorCode}): ${cmcResponse.status.errorMessage ?? "Unknown API error"}');
      }
      return cmcResponse.data;
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print(
          "DioException fetching CMC listings: ${e.message}"); // Log the error
      String errorMessage = 'Failed to fetch data.';

      if (e.response != null) {
        // Extract error details from API response if available
        errorMessage += ' Status Code: ${e.response?.statusCode}';
        try {
          // Try to parse error message from API response body
          final errorData = e.response?.data as Map<String, dynamic>?;
          final status = Status.fromJson(errorData?['status'] ?? {});
          if (status.errorMessage != null && status.errorMessage!.isNotEmpty) {
            errorMessage =
                'API Error: ${status.errorMessage}'; // Use API error message
          } else {
            errorMessage +=
                '\nResponse: ${e.response?.data}'; // Fallback to raw response
          }
        } catch (_) {
          errorMessage += '\nCould not parse error response body.';
        }
      } else {
        // Handle errors without a response (e.g., connection timeout)
        errorMessage += '\nError: ${e.message}';
      }
      throw Exception(errorMessage); // Re-throw a user-friendly exception
    } catch (e) {
      // Handle other generic errors (e.g., model parsing errors)
      print("Error fetching CMC listings: $e"); // Log the error
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
