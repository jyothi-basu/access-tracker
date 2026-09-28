/// Parses backend timestamps consistently across browser timezones.
DateTime parseBackendDateTime(String value) {
  final hasTimezone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
  final parsed = DateTime.parse(hasTimezone ? value : '${value}Z');
  return parsed.toUtc();
}
