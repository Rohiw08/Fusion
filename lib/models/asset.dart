// models/asset.dart
class Asset {
  final String? name;
  final String? symbol;
  final double? balance;
  final double? value; // Value in some currency (e.g., USD)
  final String? imageUrl;

  Asset({this.name, this.symbol, this.balance, this.value, this.imageUrl});

  factory Asset.fromJson(Map<String, dynamic> json) {
    final node = json['node'] as Map<String, dynamic>?;
    return Asset(
      name: node?['name'] as String?,
      symbol: node?['symbol'] as String?,
      balance: node?['balance'] != null
          ? double.tryParse(node!['balance'].toString())
          : null,
      value: node?['balanceUSD'] != null
          ? double.tryParse(node!['balanceUSD'].toString())
          : null,
      imageUrl: null, // Image URL might not be in this query
    );
  }
}

class PortfolioData {
  final List<Asset>? assets;
  final double? totalValue;

  PortfolioData({this.assets, this.totalValue});

  factory PortfolioData.fromJson(List<dynamic> jsonList) {
    List<Asset> assets = jsonList
        .map((item) => Asset.fromJson(item as Map<String, dynamic>))
        .toList();

    double totalValue =
        assets.fold(0, (sum, asset) => sum + (asset.value ?? 0));

    return PortfolioData(assets: assets, totalValue: totalValue);
  }
}
