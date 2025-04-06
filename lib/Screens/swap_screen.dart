import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Updated tokens to match CoinGecko API requirements
const Map<String, String> availableTokens = {
  'Bitcoin': 'bitcoin',
  'Ethereum': 'ethereum',
  'Solana': 'solana',
  'USDC': 'usd-coin',
  'Tether': 'tether',
};

class SwapCalculatorState {
  final String fromTokenId;
  final String toTokenId;
  final double? outputAmount;
  final bool isLoading;
  final String? error;

  SwapCalculatorState({
    this.fromTokenId = 'bitcoin',
    this.toTokenId = 'usd-coin',
    this.outputAmount,
    this.isLoading = false,
    this.error,
  });

  SwapCalculatorState copyWith({
    String? fromTokenId,
    String? toTokenId,
    double? outputAmount,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearOutput = false,
  }) {
    return SwapCalculatorState(
      fromTokenId: fromTokenId ?? this.fromTokenId,
      toTokenId: toTokenId ?? this.toTokenId,
      outputAmount: clearOutput ? null : outputAmount ?? this.outputAmount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SwapCalculatorNotifier extends StateNotifier<SwapCalculatorState> {
  final Ref _ref;

  SwapCalculatorNotifier(this._ref) : super(SwapCalculatorState());

  void setFromToken(String tokenId) {
    if (tokenId == state.toTokenId) return;
    state = state.copyWith(
        fromTokenId: tokenId, clearOutput: true, clearError: true);
  }

  void setToToken(String tokenId) {
    if (tokenId == state.fromTokenId) return;
    state =
        state.copyWith(toTokenId: tokenId, clearOutput: true, clearError: true);
  }

  // Fixed to handle proper conversion between cryptocurrencies
  Future<void> calculateSwap(String amountString) async {
    final double? inputAmount = double.tryParse(amountString);
    if (inputAmount == null || inputAmount <= 0) {
      state = state.copyWith(
          error: "Please enter a valid amount",
          isLoading: false,
          clearOutput: true);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, clearOutput: true);

    final dio = _ref.read(dioProvider);
    final String fromId = state.fromTokenId;
    final String toId = state.toTokenId;

    try {
      // First get the USD price of the "from" token
      final fromResponse = await dio.get(
        "https://api.coingecko.com/api/v3/simple/price",
        queryParameters: {
          'ids': fromId,
          'vs_currencies': 'usd',
        },
      );

      // Then get the USD price of the "to" token
      final toResponse = await dio.get(
        "https://api.coingecko.com/api/v3/simple/price",
        queryParameters: {
          'ids': toId,
          'vs_currencies': 'usd',
        },
      );

      if (fromResponse.statusCode == 200 && toResponse.statusCode == 200) {
        final fromData = fromResponse.data as Map;
        final toData = toResponse.data as Map;

        if (fromData.containsKey(fromId) &&
            (fromData[fromId] as Map).containsKey('usd') &&
            toData.containsKey(toId) &&
            (toData[toId] as Map).containsKey('usd')) {
          final double fromUsdRate =
              ((fromData[fromId] as Map)['usd'] as num).toDouble();
          final double toUsdRate =
              ((toData[toId] as Map)['usd'] as num).toDouble();

          // Calculate the conversion rate between the two tokens via USD
          final double conversionRate = fromUsdRate / toUsdRate;
          final double outputAmount = inputAmount * conversionRate;

          state = state.copyWith(outputAmount: outputAmount, isLoading: false);
        } else {
          throw Exception("Price data not found in API response");
        }
      } else {
        throw Exception(
            "Failed to fetch prices: Status ${fromResponse.statusCode} / ${toResponse.statusCode}");
      }
    } on DioException catch (e) {
      // Improved error handling, especially for rate limiting
      String errorMessage = "Error fetching rate: ${e.message}";
      if (e.response?.statusCode == 429) {
        errorMessage = "Rate limit exceeded. Please try again in a moment.";
      }
      print("DioException: $errorMessage");
      state = state.copyWith(error: errorMessage, isLoading: false);
    } catch (e) {
      print("Error calculating swap: $e");
      state = state.copyWith(
          error: "Calculation error: ${e.toString()}", isLoading: false);
    }
  }
}

final swapCalculatorProvider =
    StateNotifierProvider<SwapCalculatorNotifier, SwapCalculatorState>((ref) {
  return SwapCalculatorNotifier(ref);
});

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  );
  return Dio(options);
});

class SwapCalculatorScreen extends ConsumerStatefulWidget {
  const SwapCalculatorScreen({super.key});

  @override
  ConsumerState<SwapCalculatorScreen> createState() =>
      _SwapCalculatorScreenState();
}

class _SwapCalculatorScreenState extends ConsumerState<SwapCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Improved number formatting to handle very small crypto values better
  String formatOutputAmount(double? amount) {
    if (amount == null) return '-';

    if (amount.abs() < 0.0001) {
      // Use scientific notation for very small values
      return amount.toStringAsExponential(6);
    } else if (amount.abs() < 0.01) {
      return amount.toStringAsFixed(8);
    } else if (amount.abs() < 1) {
      return amount.toStringAsFixed(6);
    } else if (amount.abs() < 1000) {
      return amount.toStringAsFixed(4);
    } else {
      // Use commas for thousands separators for larger values
      return NumberFormat.decimalPattern('en_US')
          .format(amount.roundToDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(swapCalculatorProvider);
    final calcNotifier = ref.read(swapCalculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crypto Swap Calculator',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("From:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: calcState.fromTokenId,
              onChanged: (value) {
                if (value != null) calcNotifier.setFromToken(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Swap',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}')),
              ],
              onChanged: (_) {
                if (calcState.outputAmount != null || calcState.error != null) {
                  ref.read(swapCalculatorProvider.notifier).state =
                      calcState.copyWith(clearOutput: true, clearError: true);
                }
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert, size: 30),
                tooltip: "Swap Currencies",
                onPressed: () {
                  final currentFrom = calcState.fromTokenId;
                  final currentTo = calcState.toTokenId;
                  calcNotifier.setFromToken(currentTo);
                  calcNotifier.setToToken(currentFrom);
                  _amountController.clear();
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("To:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: calcState.toTokenId,
              onChanged: (value) {
                if (value != null) calcNotifier.setToToken(value);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: calcState.isLoading
                  ? null
                  : () {
                      calcNotifier.calculateSwap(_amountController.text);
                      FocusScope.of(context).unfocus();
                    },
              child: calcState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white))
                  : const Text('Calculate Estimate'),
            ),
            const SizedBox(height: 30),
            if (calcState.outputAmount != null)
              Column(
                children: [
                  const Text(
                    "Estimated Amount You Receive:",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatOutputAmount(calcState.outputAmount),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    availableTokens.entries
                        .firstWhere((e) => e.value == calcState.toTokenId,
                            orElse: () => const MapEntry('Unknown', ''))
                        .key,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "(Market rate estimate - excludes fees and slippage)",
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            if (calcState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Error: ${calcState.error}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: availableTokens.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.value,
          child: Text(entry.key),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      isExpanded: true,
    );
  }
}
