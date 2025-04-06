import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/models/crypto_listing_model.dart';
import 'package:fusion/services/cmc_api_service.dart';

final cryptoListingsProvider = FutureProvider<List<CryptoListing>>((ref) async {
  final apiService = ref.watch(cmcApiServiceProvider);
  return apiService.getLatestListings();
});
