class Quote {
  final UsdQuote usd; // Assuming we always want USD data

  Quote({required this.usd});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      // Assume USD key exists, provide default if not
      usd: UsdQuote.fromJson(
          json['USD'] as Map<String, dynamic>? ?? {}), // Handle null USD quote
    );
  }
}

class UsdQuote {
  final double price;
  final double volume24h;
  final double percentChange1h;
  final double percentChange24h;
  final double percentChange7d;
  final double marketCap;
  final double fullyDilutedMarketCap;
  final String lastUpdated;

  UsdQuote({
    required this.price,
    required this.volume24h,
    required this.percentChange1h,
    required this.percentChange24h,
    required this.percentChange7d,
    required this.marketCap,
    required this.fullyDilutedMarketCap,
    required this.lastUpdated,
  });

  factory UsdQuote.fromJson(Map<String, dynamic> json) {
    // Helper function to parse double safely
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return UsdQuote(
      price: parseDouble(json['price']),
      volume24h: parseDouble(json['volume_24h']),
      percentChange1h: parseDouble(json['percent_change_1h']),
      percentChange24h: parseDouble(json['percent_change_24h']),
      percentChange7d: parseDouble(json['percent_change_7d']),
      marketCap: parseDouble(json['market_cap']),
      fullyDilutedMarketCap: parseDouble(json['fully_diluted_market_cap']),
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }
}
