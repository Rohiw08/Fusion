import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/models/asset.dart';
import 'package:fusion/services/zapper_service.dart';

final defaultWalletAddress = dotenv.env['ZAPPERWALLETADDRESS']!;

final portfolioDataProvider = FutureProvider<PortfolioData>((ref) async {
  final zapperService = ref.watch(zapperServiceProvider);
  return zapperService.getPortfolioData(defaultWalletAddress);
});
