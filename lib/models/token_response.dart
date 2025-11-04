/// Token information from authentication response
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
  });

  /// Create TokenResponse from JSON
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Convert TokenResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get full authorization header value
  String get authorizationHeader => '$tokenType $accessToken';

  @override
  String toString() {
    return 'TokenResponse(accessToken: ${accessToken.substring(0, 20)}..., '
        'tokenType: $tokenType, expiresAt: $expiresAt)';
  }
}
