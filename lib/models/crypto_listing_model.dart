import 'package:fusion/models/quote_model.dart';

class CryptoListing {
  final int id;
  final String name;
  final String symbol;
  final String slug;
  final int cmcRank;
  final double circulatingSupply;
  final double totalSupply;
  final double? maxSupply; // Can be null
  final String lastUpdated;
  final String dateAdded;
  final Quote quote; // Contains currency quotes like USD

  CryptoListing({
    required this.id,
    required this.name,
    required this.symbol,
    required this.slug,
    required this.cmcRank,
    required this.circulatingSupply,
    required this.totalSupply,
    this.maxSupply,
    required this.lastUpdated,
    required this.dateAdded,
    required this.quote,
  });

  factory CryptoListing.fromJson(Map<String, dynamic> json) {
    // Helper function to parse double safely
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to parse nullable double safely
    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return CryptoListing(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      symbol: json['symbol'] as String? ?? 'N/A',
      slug: json['slug'] as String? ?? 'n-a',
      cmcRank: json['cmc_rank'] as int? ?? 0,
      circulatingSupply: parseDouble(json['circulating_supply']),
      totalSupply: parseDouble(json['total_supply']),
      maxSupply: parseNullableDouble(json['max_supply']),
      lastUpdated: json['last_updated'] as String? ?? '',
      dateAdded: json['date_added'] as String? ?? '',
      // Assuming 'quote' exists and has a 'USD' key
      quote: Quote.fromJson(
          json['quote'] as Map<String, dynamic>? ?? {}), // Handle null quote
    );
  }
}
