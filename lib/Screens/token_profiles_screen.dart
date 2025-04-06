// lib/features/token_profiles/view/token_profiles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/provider/token_profiles_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TokenProfilesScreen extends ConsumerWidget {
  const TokenProfilesScreen({super.key});

  // Function to launch URL safely
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return; // Don't try to launch empty URLs
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          // Check if widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      print("Error launching URL $urlString: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the async state (loading, data, error)
    final profilesAsyncValue = ref.watch(tokenProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DexScreener Latest Profiles'),
      ),
      body: profilesAsyncValue.when(
        // --- Loading State ---
        loading: () => const Center(child: CircularProgressIndicator()),

        // --- Error State ---
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading profiles:\n$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  // Invalidate the provider to trigger a refetch
                  onPressed: () => ref.invalidate(tokenProfilesProvider),
                )
              ],
            ),
          ),
        ),

        // --- Data State ---
        data: (profiles) {
          if (profiles.isEmpty) {
            return const Center(child: Text('No token profiles found.'));
          }
          // Display data in a ListView
          return RefreshIndicator(
            // Use invalidate for simpler refetching
            onRefresh: () async => ref.invalidate(tokenProfilesProvider),
            child: ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return Card(
                  child: ListTile(
                    // Display Icon if available
                    leading: profile.icon != null && profile.icon!.isNotEmpty
                        ? ClipOval(
                            // Make icon circular
                            child: Image.network(
                              profile.icon!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              // Add error handling for images
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.token_outlined, size: 40),
                            ),
                          )
                        : const CircleAvatar(
                            // Placeholder if no icon
                            radius: 20,
                            child: Icon(Icons.token_outlined, size: 24),
                          ),
                    // Display Chain ID
                    title: Text(
                      profile.chainId,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    // Display Token Address and Description
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Addr: ${profile.tokenAddress}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Only show description if it exists and is not empty
                        if (profile.description != null &&
                            profile.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              profile.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                    // Button to open DexScreener URL
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new, size: 20),
                      tooltip: 'Open on DexScreener',
                      onPressed: profile.url.isNotEmpty
                          ? () => _launchUrl(context, profile.url)
                          : null, // Disable if no URL
                    ),
                    // Adjust based on whether description exists
                    isThreeLine: (profile.description != null &&
                        profile.description!.isNotEmpty),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
