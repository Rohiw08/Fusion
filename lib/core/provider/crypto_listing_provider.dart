// lib/providers/crypto_provider.dart (or your preferred location)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/models/crypto_listing_model.dart';
import 'package:fusion/services/cmc_api_service.dart';

// --- Crypto Listings Provider ---
// This FutureProvider fetches the list of crypto listings using the CmcApiService.
// It automatically handles loading/error/data states for the UI.

final cryptoListingsProvider = FutureProvider<List<CryptoListing>>((ref) async {
  // 1. Watch the CmcApiService provider to get an instance of the service.
  //    Using watch means if the service provider were to rebuild (e.g., config change),
  //    this provider would also refetch. Use read if you only need it once.
  final apiService = ref.watch(cmcApiServiceProvider);

  // 2. Call the method on the service to fetch the data.
  //    The Future returned by getLatestListings will be managed by the FutureProvider.
  //    You can pass parameters like limit here if needed: apiService.getLatestListings(limit: 50)
  return apiService.getLatestListings();
});
