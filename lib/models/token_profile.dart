// lib/models/token_profile.dart
import 'package:flutter/foundation.dart' show immutable;

@immutable
class TokenProfile {
  final String url;
  final String chainId;
  final String tokenAddress;
  final String? icon;
  final String? header;
  final String? openGraph;
  final String? description;

  const TokenProfile({
    required this.url,
    required this.chainId,
    required this.tokenAddress,
    this.icon,
    this.header,
    this.openGraph,
    this.description,
  });

  factory TokenProfile.fromJson(Map<String, dynamic> json) {
    return TokenProfile(
      url: json['url'] as String? ?? '',
      chainId: json['chainId'] as String? ?? 'unknown',
      tokenAddress: json['tokenAddress'] as String? ?? 'unknown',
      icon: json['icon'] as String?,
      header: json['header'] as String?,
      openGraph: json['openGraph'] as String?,
      description: json['description'] as String?,
    );
  }

  // Optional: Add copyWith, toString, hashCode, == if needed
}
