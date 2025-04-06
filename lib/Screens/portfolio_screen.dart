// widgets/portfolio_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/portfolio_provider.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioData = ref.watch(portfolioDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
      ),
      body: portfolioData.when(
        data: (data) {
          if (data.assets == null || data.assets!.isEmpty) {
            return const Center(child: Text('No assets found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(portfolioDataProvider.future),
            child: ListView.builder(
              itemCount: data.assets!.length,
              itemBuilder: (context, index) {
                final asset = data.assets![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (asset.imageUrl != null)
                          Image.network(
                            asset.imageUrl!,
                            width: 30,
                            height: 30,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.monetization_on_outlined);
                            },
                          )
                        else
                          const Icon(Icons.monetization_on_outlined),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(asset.name ?? 'Unknown Asset',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(asset.symbol ?? ''),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(asset.balance?.toStringAsFixed(4) ?? '0'),
                            Text(
                                '\$${asset.value?.toStringAsFixed(2) ?? '0.00'}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: portfolioData.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Value: \$${data.totalValue?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
