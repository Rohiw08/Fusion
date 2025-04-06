// providers/portfolio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/models/asset.dart';
import 'package:fusion/services/zapper_service.dart';

const defaultWalletAddress =
    '0x3d280fde2ddb59323c891cf30995e1862510342f'; // Your target address

final portfolioDataProvider = FutureProvider<PortfolioData>((ref) async {
  final zapperService = ref.watch(zapperServiceProvider);
  return zapperService.getPortfolioData(defaultWalletAddress);
});
