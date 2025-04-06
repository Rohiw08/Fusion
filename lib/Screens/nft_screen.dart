import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/crypto_listing_provider.dart';
import 'package:intl/intl.dart';

class CryptoListingsScreen extends ConsumerWidget {
  const CryptoListingsScreen({super.key});

  // Helper to format numbers nicely
  String _formatNumber(double number) {
    if (number > 1) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2)
          .format(number);
    } else {
      // Show more precision for prices less than $1
      return NumberFormat.currency(symbol: '\$', decimalDigits: 6)
          .format(number);
    }
  }

  // Helper to format large numbers (like market cap)
  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '\$${(number / 1e12).toStringAsFixed(2)} T'; // Trillion
    } else if (number >= 1e9) {
      return '\$${(number / 1e9).toStringAsFixed(2)} B'; // Billion
    } else if (number >= 1e6) {
      return '\$${(number / 1e6).toStringAsFixed(2)} M'; // Million
    } else {
      return _formatNumber(
          number); // Use standard formatting for smaller numbers
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the async state
    final listingsAsyncValue = ref.watch(cryptoListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crypto Listings',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: listingsAsyncValue.when(
        // --- Loading State ---
        loading: () => const Center(child: CircularProgressIndicator()),
        // --- Error State ---
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading data:\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        // --- Data State ---
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('No cryptocurrency data found.'));
          }
          return RefreshIndicator(
            // Add pull-to-refresh
            onRefresh: () => ref.refresh(cryptoListingsProvider.future),
            child: ListView.builder(
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final crypto = listings[index];
                final usdQuote = crypto.quote.usd; // Access USD quote data
                final priceChange24h = usdQuote.percentChange24h;
                final priceColor =
                    priceChange24h >= 0 ? Colors.green : Colors.red;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    // Ideally, load crypto icon URL here if available
                    child: Text(
                      crypto.cmcRank.toString(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text('${crypto.name} (${crypto.symbol})'),
                  subtitle:
                      Text('MCap: ${_formatLargeNumber(usdQuote.marketCap)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatNumber(usdQuote.price), // Format price
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${priceChange24h.toStringAsFixed(2)}%',
                        style: TextStyle(color: priceColor, fontSize: 12),
                      ),
                    ],
                  ),
                  // Optional: Add onTap for navigation to detail screen
                  // onTap: () { /* Navigate to detail page */ },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
