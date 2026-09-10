class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.isOffline = false,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final bool isOffline;
  final Map<String, List<String>> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  String? firstFieldError(String field) {
    final values = fieldErrors[field];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  @override
  String toString() => message;
}
