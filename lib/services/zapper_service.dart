// services/zapper_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart'; // Adjust import path

class ZapperService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://public.zapper.xyz/graphql';
  final String _apiKey = '83db6aab-9418-4883-83d6-8eca87d317d7';

  Future<PortfolioData> getPortfolioData(String address) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-zapper-api-key': _apiKey,
          },
        ),
        data: {
          "query":
              "query PortfolioV2(\$addresses: [Address!]!, \$networks: [Network!]) { portfolioV2(addresses: \$addresses, networks: \$networks) { tokenBalances { byToken { edges { node { balance balanceRaw balanceUSD symbol name } } } } } }",
          "variables": {
            "addresses": [address], // Use the provided address
            "networks": ["ETHEREUM_MAINNET"]
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['portfolioV2']['tokenBalances']
            ['byToken']['edges'] as List<dynamic>;
        List<Asset> assets = data.map((item) {
          final node = item['node'] as Map<String, dynamic>?;
          return Asset(
            name: node?['name'] as String?,
            symbol: node?['symbol'] as String?,
            balance: node?['balance'] != null
                ? double.tryParse(node!['balance'].toString())
                : null,
            value: node?['balanceUSD'] != null
                ? double.tryParse(node!['balanceUSD'].toString())
                : null,
            // The imageUrl might not be directly available in this specific query.
            // You might need a different query or endpoint to fetch token logos.
          );
        }).toList();

        double totalValue =
            assets.fold(0, (sum, asset) => sum + (asset.value ?? 0));

        return PortfolioData(assets: assets, totalValue: totalValue);
      } else {
        print(
            'Zapper API Error: ${response.statusCode} - ${response.statusMessage}');
        print(response.data); // Log the error response
        throw Exception('Failed to load portfolio data');
      }
    } catch (error) {
      print('Error fetching portfolio data: $error');
      throw error;
    }
  }
}

// Provider for the ZapperService
final zapperServiceProvider = Provider<ZapperService>((ref) => ZapperService());
